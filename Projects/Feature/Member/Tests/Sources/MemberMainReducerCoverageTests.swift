//
//  MemberMainReducerCoverageTests.swift
//  MemberTests
//
//  MemberMainFeature 리듀서의 view / inner / async / delegate / vote 스코프 분기를 모두 태운다.
//

import ComposableArchitecture
import DDDDesignKit
import Testing

@testable import Member

@MainActor
@Suite("MemberMainFeature 커버리지")
struct MemberMainReducerCoverageTests {
  // MARK: - View 액션

  @Test("onAppear 는 프로필·출석·일정·투표 조회를 모두 마치고 화면 상태를 채운다")
  func onAppear_모든조회성공_상태를채운다() async {
    let store = makeStore(
      dependencies: {
        $0.stubMemberUseCases(
          vote: StubVoteUseCase(activeVote: .success(MemberTestFixture.activeVote))
        )
      }
    )
    store.exhaustivity = .off

    await store.send(.view(.onAppear))
    await store.finish()
    await store.skipReceivedActions(strict: false)

    #expect(store.state.didAppear)
    #expect(store.state.member == MemberTestFixture.profile)
    #expect(store.state.presentCount == 8)
    #expect(store.state.lateCount == 1)
    #expect(store.state.absentCount == 2)
    #expect(store.state.showsAttendanceWarningIcon)
    #expect(Array(store.state.schedules) == MemberTestFixture.schedules)
    #expect(store.state.startDate == "2026.9.2")
    #expect(store.state.endDate == "2026.11.30")
    #expect(store.state.isVoteMenuAvailable)
    #expect(store.state.viewState == .loaded)
  }

  @Test("이미 onAppear 를 처리했다면 두 번째 onAppear 는 아무 효과도 만들지 않는다")
  func onAppear_이미노출됨_효과없음() async {
    var state = MemberMainFeature.State()
    state.didAppear = true

    let store = makeStore(state: state)

    await store.send(.view(.onAppear))
  }

  @Test("onDisappear 는 다음 진입에서 데이터를 다시 불러올 수 있게 한다")
  func onDisappear_노출상태초기화() async {
    var state = MemberMainFeature.State()
    state.didAppear = true

    let store = makeStore(state: state)

    await store.send(.view(.onDisappear)) {
      $0.didAppear = false
    }
  }

  @Test("결석 경고 아이콘이 없으면 결석 버튼을 눌러도 알럿이 열리지 않는다")
  func didTapAbesentButton_경고아이콘없음_알럿미표시() async {
    let store = makeStore()

    await store.send(.view(.didTapAbesentButton))
    #expect(!store.state.isAttendanceWarningAlertPresented)
  }

  @Test("결석 경고 아이콘이 있으면 결석 버튼이 알럿을 열고 닫기 버튼이 다시 닫는다")
  func didTapAbesentButton_경고아이콘있음_알럿토글() async {
    var state = MemberMainFeature.State()
    state.absentCount = 1

    let store = makeStore(state: state)

    await store.send(.view(.didTapAbesentButton)) {
      $0.isAttendanceWarningAlertPresented = true
    }
    await store.send(.view(.didTapDismissAlertButton)) {
      $0.isAttendanceWarningAlertPresented = false
    }
  }

  @Test("toggleDropDown 은 드롭다운을 토글하고 closeDropDown 은 항상 닫는다")
  func dropDown_토글과닫기() async {
    let store = makeStore()

    await store.send(.view(.toggleDropDown)) {
      $0.isExpandedDropDown = true
    }
    await store.send(.view(.toggleDropDown)) {
      $0.isExpandedDropDown = false
    }
    await store.send(.view(.toggleDropDown)) {
      $0.isExpandedDropDown = true
    }
    await store.send(.view(.closeDropDown)) {
      $0.isExpandedDropDown = false
    }
  }

  @Test("투표 메뉴가 비활성이면 투표 탭 선택이 거부되고 드롭다운만 닫힌다")
  func selectHomeTab_투표비활성_탭전환거부() async {
    var state = MemberMainFeature.State()
    state.isExpandedDropDown = true

    let store = makeStore(state: state)

    await store.send(.view(.selectHomeTab(.vote))) {
      $0.isExpandedDropDown = false
    }
    #expect(store.state.selectedHomeTab == .attendance)
  }

  @Test("투표 메뉴가 활성이면 투표 탭으로 전환되고 다시 출석 탭으로 돌아올 수 있다")
  func selectHomeTab_투표활성_탭전환성공() async {
    var state = MemberMainFeature.State()
    state.isVoteMenuAvailable = true
    state.isExpandedDropDown = true

    let store = makeStore(state: state)

    await store.send(.view(.selectHomeTab(.vote))) {
      $0.selectedHomeTab = .vote
      $0.isExpandedDropDown = false
    }
    await store.send(.view(.selectHomeTab(.attendance))) {
      $0.selectedHomeTab = .attendance
    }
  }

  @Test("투표 작성 중 뒤로가기는 투표 리듀서에 종료 요청을 전달한다")
  func didTapVoteBackButton_투표종료요청전달() async {
    var state = MemberMainFeature.State()
    state.isVoteMenuAvailable = true
    state.selectedHomeTab = .vote

    let store = makeStore(state: state)
    store.exhaustivity = .off

    await store.send(.view(.didTapVoteBackButton))
    await store.finish()
    await store.skipReceivedActions(strict: false)

    // step 이 .loading 이므로 곧바로 exitVote 로 이어져 출석 탭으로 되돌아온다.
    #expect(store.state.selectedHomeTab == .attendance)
    #expect(store.state.vote == MemberVoteFeature.State())
  }

  @Test("바인딩 액션은 상태를 그대로 반영한다")
  func binding_드롭다운상태반영() async {
    let store = makeStore()

    await store.send(.binding(.set(\.isExpandedDropDown, true))) {
      $0.isExpandedDropDown = true
    }
  }

  // MARK: - Inner 액션

  @Test("프로필 조회 성공은 멤버를 저장하고 실패는 멤버를 비운다")
  func onFetchUserResponse_성공과실패() async {
    var state = MemberMainFeature.State()
    state.member = MemberTestFixture.profile

    let store = makeStore(state: state)

    await store.send(.inner(.onFetchUserResponse(.failure(.profileNotFound)))) {
      $0.member = nil
      $0.attendanceViewState = .loaded
    }
    await store.send(.inner(.onFetchUserResponse(.success(MemberTestFixture.profile)))) {
      $0.member = MemberTestFixture.profile
    }
  }

  @Test("결석이 없는 출석 요약은 경고 아이콘을 켜지 않는다")
  func onFetchAttendanceSummaryResponse_결석없음_경고아이콘꺼짐() async {
    let store = makeStore()

    await store.send(
      .inner(.onFetchAttendanceSummaryResponse(.success(MemberTestFixture.cleanAttendanceSummary)))
    ) {
      $0.attendanceViewState = .loaded
      $0.presentCount = 10
      $0.lateCount = 0
      $0.absentCount = 0
    }
    #expect(!store.state.showsAttendanceWarningIcon)
  }

  @Test("출석 요약 조회 실패는 카운트를 변경하지 않는다")
  func onFetchAttendanceSummaryResponse_실패_상태유지() async {
    let store = makeStore()

    await store.send(.inner(.onFetchAttendanceSummaryResponse(.failure(.unknown)))) {
      $0.attendanceViewState = .loaded
    }
    #expect(store.state.presentCount == .zero)
  }

  @Test("일정이 비어 있으면 활동 기간 문구를 만들지 않는다")
  func onFetchSchedulesResponse_빈배열_기간문구없음() async {
    let store = makeStore()

    await store.send(.inner(.onFetchSchedulesResponse(.success([]))))
    #expect(store.state.startDate.isEmpty)
    #expect(store.state.endDate.isEmpty)
  }

  @Test("일정 조회 실패는 기존 일정 목록을 유지한다")
  func onFetchSchedulesResponse_실패_상태유지() async {
    let store = makeStore()

    await store.send(.inner(.onFetchSchedulesResponse(.failure(.unknown))))
    #expect(store.state.schedules.isEmpty)
  }

  @Test("진행 중 투표 조회 성공은 투표 메뉴를 활성화한다")
  func onFetchActiveVoteResponse_성공_투표메뉴활성화() async {
    let store = makeStore()

    await store.send(.inner(.onFetchActiveVoteResponse(.success(MemberTestFixture.activeVote)))) {
      $0.isVoteMenuAvailable = true
    }
  }

  @Test("투표 탭에서 진행 중 투표 조회가 실패하면 출석 탭으로 되돌리고 투표 상태를 초기화한다")
  func onFetchActiveVoteResponse_실패_투표탭이탈() async {
    var state = MemberMainFeature.State()
    state.isVoteMenuAvailable = true
    state.selectedHomeTab = .vote
    state.isExpandedDropDown = true
    state.vote.step = .teamSelect

    let store = makeStore(state: state)

    await store.send(.inner(.onFetchActiveVoteResponse(.failure(.noActiveVote)))) {
      $0.isVoteMenuAvailable = false
      $0.selectedHomeTab = .attendance
      $0.vote = MemberVoteFeature.State()
      $0.isExpandedDropDown = false
    }
  }

  @Test("onResume 은 기존 화면을 유지한 채 출석 현황만 다시 조회한다")
  func onResume_출석현황만재조회() async {
    var state = MemberMainFeature.State()
    state.viewState = .loaded
    state.attendanceViewState = .loaded
    state.member = MemberTestFixture.profile
    state.schedules = .init(uniqueElements: MemberTestFixture.schedules)

    let store = makeStore(state: state)

    await store.send(.inner(.onResume)) {
      $0.attendanceViewState = .loading
    }
    await store.receive(\.async)
    await store.receive(\.inner) {
      $0.attendanceViewState = .loaded
      $0.presentCount = 8
      $0.lateCount = 1
      $0.absentCount = 2
    }

    #expect(store.state.member == MemberTestFixture.profile)
    #expect(store.state.schedules.count == 3)
    #expect(store.state.viewState == .loaded)
    #expect(store.state.attendanceViewState == .loaded)
    #expect(store.state.presentCount == 8)
    #expect(store.state.lateCount == 1)
    #expect(store.state.absentCount == 2)
    #expect(store.state.showsAttendanceWarningIcon)
  }

  // MARK: - Async 실패 경로

  @Test("모든 원격 조회가 실패하면 화면은 초기값을 유지하고 투표 메뉴가 잠긴다")
  func onAppear_모든조회실패_초기값유지() async {
    let store = makeStore(
      dependencies: {
        $0.stubMemberUseCases(
          profile: .failure(.loadFailed),
          attendances: .failure(.loadFailed),
          schedules: .failure(.loadFailed),
          vote: StubVoteUseCase(activeVote: .failure(.requestFailed))
        )
      }
    )
    store.exhaustivity = .off

    await store.send(.view(.onAppear))
    await store.finish()
    await store.skipReceivedActions(strict: false)

    #expect(store.state.member == nil)
    #expect(store.state.schedules.isEmpty)
    #expect(!store.state.isVoteMenuAvailable)
    #expect(store.state.viewState == .loaded)
    #expect(store.state.attendanceViewState == .loaded)
  }

  @Test("멤버 홈은 프로필·출석·일정·투표 조회가 모두 끝날 때까지 로딩을 유지한다")
  func loading_모든필수조회완료후종료() async {
    var state = MemberMainFeature.State()
    state.pendingLoadingResources = [.profileAndAttendance, .schedule, .activeVote]

    let store = makeStore(state: state)

    await store.send(.inner(.onFetchSchedulesResponse(.success([])))) {
      $0.pendingLoadingResources.remove(.schedule)
    }
    await store.send(.inner(.onFetchActiveVoteResponse(.success(MemberTestFixture.activeVote)))) {
      $0.pendingLoadingResources.remove(.activeVote)
      $0.isVoteMenuAvailable = true
    }
    await store.send(
      .inner(.onFetchAttendanceSummaryResponse(.success(MemberTestFixture.attendanceSummary)))
    ) {
      $0.pendingLoadingResources.remove(.profileAndAttendance)
      $0.viewState = .loaded
      $0.attendanceViewState = .loaded
      $0.presentCount = 8
      $0.lateCount = 1
      $0.absentCount = 2
    }
    #expect(store.state.showsAttendanceWarningIcon)
  }

  // MARK: - Delegate 액션

  @Test("QR·프로필 라우팅 델리게이트는 드롭다운을 닫는다")
  func delegate_라우팅_드롭다운닫힘() async {
    var state = MemberMainFeature.State()
    state.isExpandedDropDown = true

    let store = makeStore(state: state)

    await store.send(.delegate(.routeToQRCode)) {
      $0.isExpandedDropDown = false
    }
    await store.send(.binding(.set(\.isExpandedDropDown, true))) {
      $0.isExpandedDropDown = true
    }
    await store.send(.delegate(.routeToProfile)) {
      $0.isExpandedDropDown = false
    }
  }

  // MARK: - Vote 스코프 액션

  @Test("투표 리듀서가 종료를 알리면 출석 탭으로 돌아가고 투표 상태를 초기화한다")
  func voteDelegate_exitVote_투표상태초기화() async {
    var state = MemberMainFeature.State()
    state.selectedHomeTab = .vote
    state.isExpandedDropDown = true
    state.vote.step = .feedback

    let store = makeStore(state: state)

    await store.send(.vote(.delegate(.exitVote))) {
      $0.selectedHomeTab = .attendance
      $0.isExpandedDropDown = false
      $0.vote = MemberVoteFeature.State()
    }
  }

  @Test("피드백 이탈 확인은 중간 view 액션 없이 팀 선택 단계로 바로 돌아간다")
  func voteExitAlert_feedback_팀선택으로직접복귀() async {
    var state = MemberMainFeature.State()
    state.selectedHomeTab = .vote
    state.vote.step = .feedback

    let store = makeStore(state: state)

    await store.send(.vote(.view(.requestExit))) {
      $0.vote.exitAlert = .exitWriting()
    }
    await store.send(.vote(.scope(.exitAlert(.presented(.cancelTapped))))) {
      $0.vote.exitAlert = nil
      $0.vote.step = .teamSelect
    }
  }

  @Test("투표 리듀서의 진행 중 투표 조회 실패는 상위 투표 메뉴도 잠근다")
  func voteInner_activeVoteResponse실패_투표메뉴잠금() async {
    var state = MemberMainFeature.State()
    state.isVoteMenuAvailable = true
    state.selectedHomeTab = .vote
    state.isExpandedDropDown = true

    let store = makeStore(state: state)
    store.exhaustivity = .off

    await store.send(.vote(.inner(.activeVoteResponse(.failure(.noActiveVote)))))
    await store.finish()
    await store.skipReceivedActions(strict: false)

    #expect(!store.state.isVoteMenuAvailable)
    #expect(store.state.selectedHomeTab == .attendance)
    #expect(!store.state.isExpandedDropDown)
    #expect(store.state.vote.step == .empty)
  }

  @Test("그 밖의 투표 액션은 상위 상태를 바꾸지 않는다")
  func vote_기타액션_상위상태유지() async {
    var state = MemberMainFeature.State()
    state.isVoteMenuAvailable = true
    state.selectedHomeTab = .vote
    state.vote.step = .feedback

    let store = makeStore(state: state)

    await store.send(.vote(.view(.backToTeamSelect))) {
      $0.vote.step = .teamSelect
    }
    #expect(store.state.selectedHomeTab == .vote)
  }

  // MARK: - 파생 상태

  @Test("투표 작성 네비게이션 바는 투표 탭의 작성 단계에서만 사용된다")
  func usesVoteWritingNavigationBar_단계별판정() {
    var state = MemberMainFeature.State()

    state.selectedHomeTab = .attendance
    state.vote.step = .teamSelect
    #expect(!state.usesVoteWritingNavigationBar)

    state.selectedHomeTab = .vote
    for step in [MemberVoteFeature.Step.loading, .teamSelect, .feedback] {
      state.vote.step = step
      #expect(state.usesVoteWritingNavigationBar)
    }
    for step in [MemberVoteFeature.Step.empty, .alreadyVoted, .completed] {
      state.vote.step = step
      #expect(!state.usesVoteWritingNavigationBar)
    }
  }

  @Test("홈 탭은 출석현황과 투표 두 가지이며 각각 한글 제목을 가진다")
  func homeTab_전체케이스와제목() {
    #expect(MemberMainFeature.HomeTab.allCases == [.attendance, .vote])
    #expect(MemberMainFeature.HomeTab.attendance.title == "출석현황")
    #expect(MemberMainFeature.HomeTab.vote.title == "투표")
    #expect(MemberMainFeature.HomeTab.attendance.rawValue == "attendance")
  }
}

// MARK: - Store 헬퍼

private extension MemberMainReducerCoverageTests {
  func makeStore(
    state: MemberMainFeature.State = MemberMainFeature.State(),
    dependencies: @escaping (inout DependencyValues) -> Void = { $0.stubMemberUseCases() }
  ) -> TestStoreOf<MemberMainFeature> {
    TestStore(initialState: state) {
      MemberMainFeature()
    } withDependencies: {
      dependencies(&$0)
    }
  }
}
