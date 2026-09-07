//
//  ManagementVoteFeatureTests.swift
//  ManagementTests
//
//  Created by DDD on 2026-09-03.
//
//  VoteFeature 의 view / async / inner / scope / binding 분기를 TestStore 로 훑는다.
//  기존 VoteFeatureReducerTests 가 다루지 않는 성공·경계·실패 경로를 채운다.
//

import Testing

@testable import Management
import VoteDomainInterface

import ComposableArchitecture

/// presentError 가 만드는 알럿과 동일한 값. AlertState 의 Equatable 은 id 를 비교하지 않는다.
private func voteRetryAlert(
  error: VoteError,
  retry: VoteFeature.AsyncAction
) -> AlertState<VoteFeature.AlertAction> {
  AlertState {
    TextState("요청을 처리하지 못했어요")
  } actions: {
    ButtonState(action: .retry(retry)) {
      TextState("재시도")
    }
    ButtonState(role: .cancel, action: .cancel) {
      TextState("닫기")
    }
  } message: {
    TextState(error.errorDescription ?? "알 수 없는 오류가 발생했어요")
  }
}

@MainActor
@Suite("ManagementVoteFeature")
struct ManagementVoteFeatureTests {
  // MARK: - 투표 목록 조회

  /// 진행 중 투표를 받으면 폴링 스트림을 열고 첫 참여 현황을 상태에 반영하는지 본다.
  @Test("진행 중 투표를 받으면 참여 스트림을 시작해 참여 현황을 채운다")
  func fetchVotesInProgressStartsParticipationStream() async {
    let participation = VoteParticipation(
      voteId: 7,
      status: .inProgress,
      totalMembers: 20,
      respondedMembers: 8,
      participationRate: 40
    )
    var stub = ManagementVoteUseCaseStub()
    stub.votes = [Vote(id: 7, title: "3주차 투표", status: .inProgress)]
    stub.streamValues = [participation]

    let store = TestStore(initialState: VoteFeature.State()) {
      VoteFeature()
    } withDependencies: {
      $0.voteUseCase = stub
    }

    await store.send(.view(.onAppear)) {
      $0.hasFetchedVotes = true
    }
    await store.receive(\.async.fetchVotes)
    await store.receive(\.inner.votesResponse) {
      $0.viewState = .loaded
      $0.voteId = 7
      $0.voteStatus = .inProgress
    }
    await store.receive(\.async.startParticipationStream)
    await store.receive(\.inner.participationResponse) {
      $0.participation = participation
    }
  }

  /// 종료된 투표는 스트림 대신 단건 조회로 최종 집계를 가져온다.
  @Test("종료된 투표를 받으면 참여 현황을 단건 조회한다")
  func fetchVotesAfterFetchesParticipationOnce() async {
    let participation = VoteParticipation(
      voteId: 3,
      status: .after,
      totalMembers: 20,
      respondedMembers: 19,
      participationRate: 95
    )
    var stub = ManagementVoteUseCaseStub()
    stub.votes = [Vote(id: 3, title: "2주차 투표", status: .after)]
    stub.participation = participation

    let store = TestStore(initialState: VoteFeature.State()) {
      VoteFeature()
    } withDependencies: {
      $0.voteUseCase = stub
    }

    await store.send(.view(.onAppear)) {
      $0.hasFetchedVotes = true
    }
    await store.receive(\.async.fetchVotes)
    await store.receive(\.inner.votesResponse) {
      $0.viewState = .loaded
      $0.voteId = 3
      $0.voteStatus = .after
    }
    await store.receive(\.async.fetchParticipation)
    await store.receive(\.inner.participationResponse) {
      $0.participation = participation
    }
  }

  /// 아직 시작하지 않은 투표는 후속 이펙트 없이 id 만 기억한다.
  @Test("투표 전 상태의 투표는 후속 이펙트 없이 id 만 저장한다")
  func fetchVotesBeforeStoresIdOnly() async {
    var stub = ManagementVoteUseCaseStub()
    stub.votes = [Vote(id: 5, title: "4주차 투표", status: .before)]

    let store = TestStore(initialState: VoteFeature.State()) {
      VoteFeature()
    } withDependencies: {
      $0.voteUseCase = stub
    }

    await store.send(.view(.onAppear)) {
      $0.hasFetchedVotes = true
    }
    await store.receive(\.async.fetchVotes)
    await store.receive(\.inner.votesResponse) {
      $0.viewState = .loaded
      $0.voteId = 5
    }
  }

  /// 목록 조회가 실패하면 재시도 버튼이 달린 알럿이 뜬다.
  @Test("투표 목록 조회 실패는 재시도 알럿을 띄운다")
  func fetchVotesFailurePresentsRetryAlert() async {
    var stub = ManagementVoteUseCaseStub()
    stub.votesError = .managerOnly

    let store = TestStore(initialState: VoteFeature.State()) {
      VoteFeature()
    } withDependencies: {
      $0.voteUseCase = stub
    }

    await store.send(.view(.onAppear)) {
      $0.hasFetchedVotes = true
    }
    await store.receive(\.async.fetchVotes)
    await store.receive(\.inner.votesResponse) {
      $0.viewState = .loaded
      $0.alert = voteRetryAlert(error: .managerOnly, retry: .fetchVotes)
    }
  }

  // MARK: - 커스텀 알럿

  /// 시작 버튼은 확인 팝업만 띄우고 네트워크를 건드리지 않는다.
  @Test("투표 시작 버튼은 시작 확인 커스텀 알럿을 띄운다")
  func tappedStartVoteButtonPresentsStartAlert() async {
    let store = TestStore(initialState: VoteFeature.State()) {
      VoteFeature()
    }

    await store.send(.view(.tappedStartVoteButton)) {
      $0.customAlert = .startVote()
    }
  }

  /// 종료 버튼도 마찬가지로 확인 팝업만 띄운다.
  @Test("투표 종료 버튼은 종료 확인 커스텀 알럿을 띄운다")
  func tappedEndVoteButtonPresentsEndAlert() async {
    var state = VoteFeature.State()
    state.voteStatus = .inProgress

    let store = TestStore(initialState: state) {
      VoteFeature()
    }

    await store.send(.view(.tappedEndVoteButton)) {
      $0.customAlert = .endVote()
    }
  }

  /// 시작 팝업의 우측(cancelTapped) 버튼이 실제 투표 시작 액션이다.
  @Test("시작 알럿의 cancelTapped 는 투표를 열고 참여 스트림을 시작한다")
  func startAlertCancelTappedOpensVote() async {
    var state = VoteFeature.State()
    state.voteId = 9
    state.customAlert = .startVote()

    let store = TestStore(initialState: state) {
      VoteFeature()
    } withDependencies: {
      $0.voteUseCase = ManagementVoteUseCaseStub()
    }

    await store.send(.scope(.customAlert(.presented(.cancelTapped)))) {
      $0.customAlert = nil
    }
    await store.receive(\.async.openVote)
    await store.receive(\.inner.openVoteResponse) {
      $0.voteStatus = .inProgress
    }
    await store.receive(\.async.startParticipationStream)
  }

  /// 종료 팝업의 우측 버튼은 투표를 닫고 최종 집계를 다시 불러온다.
  @Test("종료 알럿의 cancelTapped 는 투표를 닫고 참여 현황을 다시 조회한다")
  func endAlertCancelTappedClosesVote() async {
    let participation = VoteParticipation(
      voteId: 9,
      status: .after,
      totalMembers: 12,
      respondedMembers: 12,
      participationRate: 100
    )
    var stub = ManagementVoteUseCaseStub()
    stub.participation = participation

    var state = VoteFeature.State()
    state.voteId = 9
    state.voteStatus = .inProgress
    state.customAlert = .endVote()

    let store = TestStore(initialState: state) {
      VoteFeature()
    } withDependencies: {
      $0.voteUseCase = stub
    }

    await store.send(.scope(.customAlert(.presented(.cancelTapped)))) {
      $0.customAlert = nil
    }
    await store.receive(\.async.closeVote)
    await store.receive(\.inner.closeVoteResponse) {
      $0.voteStatus = .after
    }
    await store.receive(\.async.fetchParticipation)
    await store.receive(\.inner.participationResponse) {
      $0.participation = participation
    }
  }

  /// 좌측(confirmTapped) 버튼은 닫기 전용이라 후속 이펙트가 없다.
  @Test("confirmTapped 는 커스텀 알럿만 닫는다")
  func confirmTappedOnlyDismissesCustomAlert() async {
    var state = VoteFeature.State()
    state.customAlert = .startVote()

    let store = TestStore(initialState: state) {
      VoteFeature()
    }

    await store.send(.scope(.customAlert(.presented(.confirmTapped)))) {
      $0.customAlert = nil
    }
  }

  /// 약관 링크 액션은 이 화면에서 쓰이지 않으므로 상태가 그대로여야 한다.
  @Test("policyTapped 는 상태를 바꾸지 않는다")
  func policyTappedKeepsState() async {
    var state = VoteFeature.State()
    state.customAlert = .startVote()

    let store = TestStore(initialState: state) {
      VoteFeature()
    }

    await store.send(.scope(.customAlert(.presented(.policyTapped))))
  }

  /// 바깥 탭 등으로 내려가는 dismiss 경로.
  @Test("customAlert dismiss 는 알럿을 닫는다")
  func customAlertDismissClearsState() async {
    var state = VoteFeature.State()
    state.customAlert = .startVote()

    let store = TestStore(initialState: state) {
      VoteFeature()
    }

    await store.send(.scope(.customAlert(.dismiss))) {
      $0.customAlert = nil
    }
  }

  // MARK: - voteId 가 없는 경계

  /// 투표 id 가 없는 상태에서 시작/종료를 누르면 "진행 중 투표 없음" 알럿이 떠야 한다.
  @Test("voteId 가 없으면 투표 시작은 진행 중 투표 없음 알럿을 띄운다")
  func openVoteWithoutVoteIdPresentsAlert() async {
    let store = TestStore(initialState: VoteFeature.State()) {
      VoteFeature()
    }

    await store.send(.async(.openVote)) {
      $0.viewState = .loaded
      $0.alert = voteRetryAlert(error: .noActiveVote, retry: .fetchVotes)
    }
  }

  @Test("voteId 가 없으면 투표 종료는 진행 중 투표 없음 알럿을 띄운다")
  func closeVoteWithoutVoteIdPresentsAlert() async {
    let store = TestStore(initialState: VoteFeature.State()) {
      VoteFeature()
    }

    await store.send(.async(.closeVote)) {
      $0.viewState = .loaded
      $0.alert = voteRetryAlert(error: .noActiveVote, retry: .fetchVotes)
    }
  }

  /// 미참여자 조회는 실패 시 열려 있던 모달까지 닫아야 한다.
  @Test("voteId 가 없으면 미참여자 조회는 모달을 닫고 알럿을 띄운다")
  func fetchNonRespondersWithoutVoteIdClosesModal() async {
    var state = VoteFeature.State()
    state.isNonParticipantsPresented = true
    state.isNonParticipantsLoading = true

    let store = TestStore(initialState: state) {
      VoteFeature()
    }

    await store.send(.async(.fetchNonResponders)) {
      $0.viewState = .loaded
      $0.isNonParticipantsPresented = false
      $0.isNonParticipantsLoading = false
      $0.alert = voteRetryAlert(error: .noActiveVote, retry: .fetchVotes)
    }
  }

  /// 참여 현황 조회 계열은 voteId 가 없으면 조용히 종료된다.
  @Test("voteId 가 없으면 참여 현황 조회와 스트림은 아무 일도 하지 않는다")
  func participationActionsWithoutVoteIdDoNothing() async {
    let store = TestStore(initialState: VoteFeature.State()) {
      VoteFeature()
    }

    await store.send(.async(.fetchParticipation))
    await store.send(.async(.startParticipationStream))
  }

  // MARK: - 미참여자 모달

  /// 버튼 탭 → 목록 초기화 + 로딩 표시 → 응답 반영까지의 전체 흐름.
  @Test("미참여자 확인 버튼은 모달을 열고 명단을 채운다")
  func tappedCheckNonParticipantsLoadsMembers() async {
    var stub = ManagementVoteUseCaseStub()
    stub.nonResponders = ManagementVoteFixture.nonParticipants

    var state = VoteFeature.State()
    state.voteId = 4
    state.voteStatus = .inProgress

    let store = TestStore(initialState: state) {
      VoteFeature()
    } withDependencies: {
      $0.voteUseCase = stub
    }

    await store.send(.view(.tappedCheckNonParticipants)) {
      $0.isNonParticipantsLoading = true
      $0.isNonParticipantsPresented = true
    }
    await store.receive(\.async.fetchNonResponders)
    await store.receive(\.inner.nonRespondersResponse) {
      $0.isNonParticipantsLoading = false
      $0.nonParticipants = ManagementVoteFixture.nonParticipants
    }
  }

  /// 명단 조회가 실패하면 모달을 닫고 알럿으로 넘긴다.
  @Test("미참여자 조회 실패는 모달을 닫고 재시도 알럿을 띄운다")
  func nonRespondersFailureClosesModalAndPresentsAlert() async {
    var stub = ManagementVoteUseCaseStub()
    stub.nonRespondersError = .notFound

    var state = VoteFeature.State()
    state.voteId = 4

    let store = TestStore(initialState: state) {
      VoteFeature()
    } withDependencies: {
      $0.voteUseCase = stub
    }

    await store.send(.view(.tappedCheckNonParticipants)) {
      $0.isNonParticipantsLoading = true
      $0.isNonParticipantsPresented = true
    }
    await store.receive(\.async.fetchNonResponders)
    await store.receive(\.inner.nonRespondersResponse) {
      $0.viewState = .loaded
      $0.isNonParticipantsLoading = false
      $0.isNonParticipantsPresented = false
      $0.alert = voteRetryAlert(error: .notFound, retry: .fetchNonResponders)
    }
  }

  @Test("미참여자 모달 닫기는 표시 플래그만 내린다")
  func tappedCloseNonParticipantsHidesModal() async {
    var state = VoteFeature.State()
    state.isNonParticipantsPresented = true
    state.nonParticipants = ManagementVoteFixture.nonParticipants

    let store = TestStore(initialState: state) {
      VoteFeature()
    }

    await store.send(.view(.tappedCloseNonParticipants)) {
      $0.isNonParticipantsPresented = false
    }
  }

  // MARK: - 개별 실패 경로

  @Test("투표 시작 실패는 openVote 재시도 알럿을 띄운다")
  func openVoteFailurePresentsRetryAlert() async {
    var stub = ManagementVoteUseCaseStub()
    stub.openError = .invalidStatus

    var state = VoteFeature.State()
    state.voteId = 9

    let store = TestStore(initialState: state) {
      VoteFeature()
    } withDependencies: {
      $0.voteUseCase = stub
    }

    await store.send(.async(.openVote))
    await store.receive(\.inner.openVoteResponse) {
      $0.viewState = .loaded
      $0.alert = voteRetryAlert(error: .invalidStatus, retry: .openVote)
    }
  }

  @Test("투표 종료 실패는 closeVote 재시도 알럿을 띄운다")
  func closeVoteFailurePresentsRetryAlert() async {
    var stub = ManagementVoteUseCaseStub()
    stub.closeError = .requestFailed

    var state = VoteFeature.State()
    state.voteId = 9
    state.voteStatus = .inProgress

    let store = TestStore(initialState: state) {
      VoteFeature()
    } withDependencies: {
      $0.voteUseCase = stub
    }

    await store.send(.async(.closeVote))
    await store.receive(\.inner.closeVoteResponse) {
      $0.viewState = .loaded
      $0.alert = voteRetryAlert(error: .requestFailed, retry: .closeVote)
    }
  }

  @Test("참여 현황 조회 실패는 fetchParticipation 재시도 알럿을 띄운다")
  func participationFailurePresentsRetryAlert() async {
    var stub = ManagementVoteUseCaseStub()
    stub.participationError = .invalidResponse

    var state = VoteFeature.State()
    state.voteId = 9

    let store = TestStore(initialState: state) {
      VoteFeature()
    } withDependencies: {
      $0.voteUseCase = stub
    }

    await store.send(.async(.fetchParticipation))
    await store.receive(\.inner.participationResponse) {
      $0.viewState = .loaded
      $0.alert = voteRetryAlert(error: .invalidResponse, retry: .fetchParticipation)
    }
  }

  // MARK: - 시스템 알럿 / 기타

  /// 알럿의 재시도 버튼은 알럿을 닫고 원래 async 액션을 다시 보낸다.
  @Test("알럿 재시도 버튼은 알럿을 닫고 원래 액션을 다시 보낸다")
  func alertRetryResendsAsyncAction() async {
    var state = VoteFeature.State()
    state.alert = voteRetryAlert(error: .unknown, retry: .fetchVotes)

    let store = TestStore(initialState: state) {
      VoteFeature()
    } withDependencies: {
      $0.voteUseCase = ManagementVoteUseCaseStub()
    }

    await store.send(.scope(.alert(.presented(.retry(.fetchVotes))))) {
      $0.alert = nil
    }
    await store.receive(\.async.fetchVotes)
    await store.receive(\.inner.votesResponse) {
      $0.viewState = .loaded
    }
  }

  @Test("알럿 닫기 버튼은 후속 이펙트 없이 알럿만 닫는다")
  func alertCancelOnlyDismisses() async {
    var state = VoteFeature.State()
    state.alert = voteRetryAlert(error: .unknown, retry: .fetchVotes)

    let store = TestStore(initialState: state) {
      VoteFeature()
    }

    await store.send(.scope(.alert(.presented(.cancel)))) {
      $0.alert = nil
    }
  }

  @Test("알럿 dismiss 도 알럿을 닫는다")
  func alertDismissClearsState() async {
    var state = VoteFeature.State()
    state.alert = voteRetryAlert(error: .unknown, retry: .fetchVotes)

    let store = TestStore(initialState: state) {
      VoteFeature()
    }

    await store.send(.scope(.alert(.dismiss))) {
      $0.alert = nil
    }
  }

  @Test("onDisappear 는 참여 스트림을 취소하고 상태를 유지한다")
  func onDisappearCancelsStream() async {
    var state = VoteFeature.State()
    state.voteId = 9
    state.voteStatus = .inProgress

    let store = TestStore(initialState: state) {
      VoteFeature()
    }

    await store.send(.view(.onDisappear))
  }

  @Test("바인딩 액션은 상태를 그대로 반영한다")
  func bindingActionUpdatesState() async {
    let store = TestStore(initialState: VoteFeature.State()) {
      VoteFeature()
    }

    await store.send(.binding(.set(\.isNonParticipantsPresented, true))) {
      $0.isNonParticipantsPresented = true
    }
  }
}
