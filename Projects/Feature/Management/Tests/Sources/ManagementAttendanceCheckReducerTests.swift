//
//  ManagementAttendanceCheckReducerTests.swift
//  ManagementTests
//
//  Created by DDD on 2026-09-03.
//
//  AttendanceCheckFeature 의 view / async / inner / destination / modal 분기를 TestStore 로 훑는다.
//

import AttendanceDomainInterface
import ComposableArchitecture
import OnBoardingDomainInterface
import Testing

@testable import Management

@MainActor
@Suite("ManagementAttendanceCheck")
struct ManagementAttendanceCheckReducerTests {
  // MARK: - View

  @Test("tapSelectDate 는 일정 모달을 띄우고 closeModal 은 닫는다")
  func tapSelectDatePresentsScheduleModal() async {
    let store = TestStore(initialState: AttendanceCheckFeature.State()) {
      AttendanceCheckFeature()
    }

    await store.send(.view(.tapSelectDate)) {
      $0.destination = .scheduleModal(.init())
    }

    await store.send(.view(.closeModal)) {
      $0.destination = nil
    }
  }

  @Test("showEditAttendanceModal 은 수정 대상과 관리자 모달을 세팅한다")
  func showEditAttendanceModalStoresTarget() async {
    var state = AttendanceCheckFeature.State()
    state.availableStatuses = .init(uniqueElements: ManagementSupportFixture.statuses)

    let store = TestStore(initialState: state) {
      AttendanceCheckFeature()
    }

    await store.send(.view(.showEditAttendanceModal(id: 100, userId: "user-1"))) {
      $0.attendanceModal = .adminStatusChangeWithAvailable(
        availableStatuses: ManagementSupportFixture.statuses,
        currentStatus: .attended
      )
      $0.editTarget = .init(attendanceID: 100, userID: "user-1")
    }
  }

  @Test("selectPartButton 은 선택 팀을 바꾸고 출석 조회를 요청한다")
  func selectPartButtonUpdatesTeamAndRequestsAttendance() async {
    let store = TestStore(initialState: AttendanceCheckFeature.State()) {
      AttendanceCheckFeature()
    }

    await store.send(.view(.selectPartButton(selectPart: ManagementSupportFixture.teams[1]))) {
      $0.selectedTeamID = 2
      $0.settledTeamID = 2
    }

    // scheduleID 가 0 이라 fetchAttendance 는 가드에 걸려 아무 것도 하지 않는다.
    await store.receive(\.async)
  }

  @Test("팀 정렬과 페이지 배열은 State 파생값 하나를 사용한다")
  func stateOwnsOrderedUniquePages() {
    var state = AttendanceCheckFeature.State()
    state.teams = .init(uniqueElements: [
      SelectTeamEntity(teamId: 3, teams: .web2),
      SelectTeamEntity(teamId: 1, teams: .ios1),
      SelectTeamEntity(teamId: 4, teams: .ios2),
      SelectTeamEntity(teamId: 2, teams: .web1)
    ])
    state.selectedTeamID = 1
    state.settledTeamID = 1

    #expect(state.orderedTeams.map(\.teamId) == [1, 2, 3, 4])
    #expect(state.pageTeams.map(\.teamId) == [4, 1, 2, 3])
    #expect(Array(state.pageTeams.ids) == [4, 1, 2, 3])
  }

  @Test("팀 선택은 배열 위치가 아닌 비연속 teamID를 사용한다")
  func selectPartButtonUsesStableTeamID() async {
    let selectedTeam = SelectTeamEntity(teamId: 30, teams: .web1)
    let store = TestStore(initialState: AttendanceCheckFeature.State()) {
      AttendanceCheckFeature()
    }

    await store.send(.view(.selectPartButton(selectPart: selectedTeam))) {
      $0.selectedTeamID = 30
      $0.settledTeamID = 30
    }
    await store.receive(\.async)
  }

  @Test("페이지 전환이 끝난 뒤에만 선택 팀을 중심으로 배열한다")
  func pageChangeRotatesAfterTransition() async {
    let clock = TestClock()
    var state = AttendanceCheckFeature.State()
    state.teams = .init(uniqueElements: [
      SelectTeamEntity(teamId: 1, teams: .ios1),
      SelectTeamEntity(teamId: 2, teams: .web1),
      SelectTeamEntity(teamId: 3, teams: .web2),
      SelectTeamEntity(teamId: 4, teams: .ios2)
    ])
    state.selectedTeamID = 1
    state.settledTeamID = 1

    #expect(state.pageSelection == 1)

    let store = TestStore(initialState: state) {
      AttendanceCheckFeature()
    } withDependencies: {
      $0.continuousClock = clock
    }

    await store.send(.view(.pageChanged(teamID: 2))) {
      $0.selectedTeamID = 2
    }
    await store.receive(\.async)

    #expect(store.state.pageTeams.map(\.teamId) == [4, 1, 2, 3])

    await clock.advance(by: .milliseconds(350))
    await store.receive(\.inner.pageTransitionFinished) {
      $0.settledTeamID = 2
    }

    #expect(store.state.pageTeams.map(\.teamId) == [1, 2, 3, 4])
  }

  @Test("onAppear 는 최초 1회만 전체 로딩을 돌리고 이후에는 새로고침만 한다")
  func onAppearLoadsOnceThenRefreshes() async {
    let store = TestStore(initialState: AttendanceCheckFeature.State()) {
      AttendanceCheckFeature()
    } withDependencies: {
      $0.attendanceUseCase = ManagementSupportAttendanceUseCase()
      $0.scheduleUseCase = ManagementSupportScheduleUseCase()
      $0.continuousClock = ImmediateClock()
      $0.mainQueue = .immediate
    }
    store.exhaustivity = .off

    await store.send(.view(.onAppear)) {
      $0.viewState = .loading
    }
    await store.finish()
    await store.skipReceivedActions(strict: false)

    #expect(store.state.viewState == .loaded)
    #expect(store.state.selectedScheduleID == 1)
    #expect(store.state.teams.count == 2)
    #expect(store.state.availableStatuses.count == ManagementSupportFixture.statuses.count)

    await store.send(.view(.onAppear))
    await store.finish()
    await store.skipReceivedActions(strict: false)

    #expect(store.state.attendanceCount == ManagementSupportFixture.attendanceCount.attendanceCount)
  }

  @Test("최초 로딩 중 재진입은 중복 요청을 만들지 않는다")
  func onAppearDuringInitialLoadingDoesNothing() async {
    var state = AttendanceCheckFeature.State()
    state.viewState = .loading

    let store = TestStore(initialState: state) {
      AttendanceCheckFeature()
    }

    await store.send(.view(.onAppear))
  }

  // MARK: - Async 가드

  @Test("scheduleID 가 없으면 출석 통계와 출석 목록 조회를 건너뛴다")
  func asyncGuardsSkipWithoutScheduleID() async {
    let store = TestStore(initialState: AttendanceCheckFeature.State()) {
      AttendanceCheckFeature()
    }

    await store.send(.async(.fetchAttendanceCount))
    await store.send(.async(.fetchAttendance))
  }

  @Test("fetchStatus 는 출석 상태 목록을 받아 담는다")
  func fetchStatusStoresStatuses() async {
    let store = TestStore(initialState: AttendanceCheckFeature.State()) {
      AttendanceCheckFeature()
    } withDependencies: {
      $0.attendanceUseCase = ManagementSupportAttendanceUseCase()
    }

    await store.send(.async(.fetchStatus))
    await store.receive(\.inner) {
      $0.availableStatuses = .init(uniqueElements: ManagementSupportFixture.statuses)
    }
  }

  @Test("fetchSchedule 은 로딩을 켰다가 응답으로 끈다")
  func fetchScheduleTogglesLoading() async {
    let store = TestStore(initialState: AttendanceCheckFeature.State()) {
      AttendanceCheckFeature()
    } withDependencies: {
      $0.scheduleUseCase = ManagementSupportScheduleUseCase()
      $0.attendanceUseCase = ManagementSupportAttendanceUseCase()
      $0.continuousClock = ImmediateClock()
    }
    store.exhaustivity = .off

    await store.send(.async(.fetchSchedule))
    await store.finish()
    await store.skipReceivedActions(strict: false)

    #expect(store.state.viewState == .loaded)
    #expect(store.state.selectedScheduleID == 1)
  }

  // MARK: - Inner

  @Test("스케줄 조회 실패는 로딩만 내린다")
  func fetchScheduleFailureStopsLoading() async {
    var state = AttendanceCheckFeature.State()
    state.viewState = .loading

    let store = TestStore(initialState: state) {
      AttendanceCheckFeature()
    }

    await store.send(.inner(.fetchScheduleResponse(.failure(.loadFailed)))) {
      $0.viewState = .loaded
    }
  }

  @Test("출석 통계 응답은 참석·지각·결석 수를 채운다")
  func attendanceCountResponseFillsCounts() async {
    let store = TestStore(initialState: AttendanceCheckFeature.State()) {
      AttendanceCheckFeature()
    }

    await store.send(.inner(.attendanceCountResponse(.success(ManagementSupportFixture.attendanceCount)))) {
      $0.attendanceSummary = ManagementSupportFixture.attendanceCount
    }
    #expect(store.state.attendanceCount == ManagementSupportFixture.attendanceCount.attendanceCount)
    #expect(store.state.lateCount == ManagementSupportFixture.attendanceCount.lateCount)
    #expect(store.state.absentCount == ManagementSupportFixture.attendanceCount.absentCount)
  }

  @Test("출석 통계 실패는 상태를 건드리지 않는다")
  func attendanceCountFailureKeepsState() async {
    let store = TestStore(initialState: AttendanceCheckFeature.State()) {
      AttendanceCheckFeature()
    }

    await store.send(.inner(.attendanceCountResponse(.failure(.loadFailed))))
  }

  @Test("팀 응답은 중복을 제거하고 teamId 순으로 정렬해 첫 팀을 고른다")
  func fetchTeamsResponseDedupesAndSelectsFirstTeam() async {
    let store = TestStore(initialState: AttendanceCheckFeature.State()) {
      AttendanceCheckFeature()
    }

    let duplicated = ManagementSupportFixture.teams + [SelectTeamEntity(teamId: 3, teams: .ios1)]

    await store.send(.inner(.fetchTeamsResponse(.success(duplicated)))) {
      $0.teams = .init(uniqueElements: ManagementSupportFixture.teams)
      $0.attendanceByTeam = [1: [], 2: []]
      $0.selectedTeamID = 1
      $0.settledTeamID = 1
    }
  }

  @Test("스케줄이 정해진 뒤 팀 응답이 오면 출석 목록까지 이어서 조회한다")
  func fetchTeamsResponseChainsAttendance() async {
    var state = AttendanceCheckFeature.State()
    state.selectedSchedule = EntityFixtureSchedule.value

    let store = TestStore(initialState: state) {
      AttendanceCheckFeature()
    } withDependencies: {
      $0.attendanceUseCase = ManagementSupportAttendanceUseCase()
    }

    await store.send(.inner(.fetchTeamsResponse(.success(ManagementSupportFixture.teams)))) {
      $0.teams = .init(uniqueElements: ManagementSupportFixture.teams)
      $0.attendanceByTeam = [1: [], 2: []]
      $0.selectedTeamID = 1
      $0.settledTeamID = 1
    }

    await store.receive(\.async)
    await store.receive(\.inner) {
      $0.viewState = .loaded
      $0.attendanceByTeam[1] = ManagementSupportFixture.attendances
    }
  }

  @Test("팀 조회 실패는 상태를 건드리지 않는다")
  func fetchTeamsFailureKeepsState() async {
    let store = TestStore(initialState: AttendanceCheckFeature.State()) {
      AttendanceCheckFeature()
    }

    await store.send(.inner(.fetchTeamsResponse(.failure(.loadFailed))))
  }

  @Test("출석 목록 응답은 팀별 캐시에만 저장한다")
  func attendanceResponseStoresTeamCache() async {
    var state = AttendanceCheckFeature.State()
    state.viewState = .refreshingAttendanceList
    state.teams = .init(uniqueElements: ManagementSupportFixture.teams)
    state.selectedTeamID = 1

    let store = TestStore(initialState: state) {
      AttendanceCheckFeature()
    }

    await store.send(.inner(.attendanceResponse(teamId: 1, .success(ManagementSupportFixture.attendances)))) {
      $0.viewState = .loaded
      $0.attendanceByTeam[1] = ManagementSupportFixture.attendances
    }
  }

  @Test("출석 목록 재조회가 실패해도 로딩을 끝낸다")
  func attendanceResponseFailureStopsLoading() async {
    var state = AttendanceCheckFeature.State()
    state.viewState = .refreshingAttendanceList

    let store = TestStore(initialState: state) {
      AttendanceCheckFeature()
    }

    await store.send(.inner(.attendanceResponse(teamId: 1, .failure(.loadFailed)))) {
      $0.viewState = .loaded
    }
  }

  @Test("출석 상태 조회 실패는 상태를 건드리지 않는다")
  func attendanceStatusFailureKeepsState() async {
    let store = TestStore(initialState: AttendanceCheckFeature.State()) {
      AttendanceCheckFeature()
    }

    await store.send(.inner(.attendanceStatusResponse(.failure(.loadFailed))))
  }

  @Test("출석 수정 성공은 통계와 목록을 다시 부른다")
  func editAttendanceSuccessRefetches() async {
    var state = AttendanceCheckFeature.State()
    state.viewState = .loaded

    let store = TestStore(initialState: state) {
      AttendanceCheckFeature()
    }
    store.exhaustivity = .off

    await store.send(.inner(.editAttendanceResponse(.success(ManagementSupportFixture.editAttendance)))) {
      $0.viewState = .refreshingAttendanceList
    }
    await store.finish()
  }

  @Test("rejected 로 거절되면 서버 문구를 그대로 알림에 싣는다")
  func editAttendanceRejectedShowsServerMessage() async {
    let store = TestStore(initialState: AttendanceCheckFeature.State()) {
      AttendanceCheckFeature()
    }

    await store.send(.inner(.editAttendanceResponse(.failure(.rejected("출석일이 아닙니다"))))) {
      $0.alert = AlertState {
        TextState("알림")
      } actions: {
        ButtonState(action: .confirmTapped) {
          TextState("확인")
        }
      } message: {
        TextState("출석일이 아닙니다")
      }
    }
  }

  @Test("그 밖의 수정 실패는 수정 실패 알럿을 띄운다")
  func editAttendanceFailureShowsGenericAlert() async {
    let store = TestStore(initialState: AttendanceCheckFeature.State()) {
      AttendanceCheckFeature()
    }

    await store.send(.inner(.editAttendanceResponse(.failure(.updateFailed)))) {
      $0.alert = AlertState {
        TextState("출석 수정 실패")
      } actions: {
        ButtonState(action: .confirmTapped) {
          TextState("확인")
        }
      } message: {
        TextState(AttendanceError.updateFailed.errorDescription ?? "")
      }
    }
  }

  @Test("알럿 확인은 알럿을 닫는다")
  func alertConfirmDismissesAlert() async {
    var state = AttendanceCheckFeature.State()
    state.alert = AlertState {
      TextState("출석 수정 실패")
    } actions: {
      ButtonState(action: .confirmTapped) {
        TextState("확인")
      }
    }

    let store = TestStore(initialState: state) {
      AttendanceCheckFeature()
    }

    await store.send(.scope(.alert(.presented(.confirmTapped)))) {
      $0.alert = nil
    }
  }

  // MARK: - Destination / Modal

  @Test("일정 모달이 날짜를 확정하면 모달을 닫고 해당 스케줄을 다시 조회한다")
  func scheduleModalDelegateUpdatesSelectedSchedule() async {
    var state = AttendanceCheckFeature.State()
    state.destination = .scheduleModal(.init())

    let store = TestStore(initialState: state) {
      AttendanceCheckFeature()
    } withDependencies: {
      $0.attendanceUseCase = ManagementSupportAttendanceUseCase()
    }
    store.exhaustivity = .off

    let selected = EntityFixtureSchedule.value
    await store.send(
      .destination(.presented(.scheduleModal(.delegate(.selectScheduleCompleted(selectedSchedule: selected)))))
    ) {
      $0.selectedSchedule = selected
      $0.destination = nil
    }
    await store.finish()
  }

  @Test("모달에서 상태를 확정하면 모달을 닫고 수정 요청을 보낸다")
  func attendanceModalConfirmSendsEdit() async {
    var state = AttendanceCheckFeature.State()
    state.attendanceModal = .adminStatusChangeWithAvailable(
      availableStatuses: ManagementSupportFixture.statuses
    )
    state.editTarget = .init(attendanceID: 100, userID: "user-1")
    state.selectedSchedule = EntityFixtureSchedule.value
    state.selectedTeamID = ManagementSupportFixture.teams[0].teamId

    let store = TestStore(initialState: state) {
      AttendanceCheckFeature()
    } withDependencies: {
      $0.attendanceUseCase = ManagementSupportAttendanceUseCase()
    }
    store.exhaustivity = .off

    await store.send(.scope(.attendanceModal(.presented(.confirmTapped(.late))))) {
      $0.attendanceModal = nil
    }
    await store.finish()
    await store.skipReceivedActions(strict: false)
    #expect(store.state.viewState == .loaded)
  }

  @Test("모달 취소는 모달만 닫는다")
  func attendanceModalCancelClosesModal() async {
    var state = AttendanceCheckFeature.State()
    state.attendanceModal = .adminStatusChangeWithAvailable(
      availableStatuses: ManagementSupportFixture.statuses
    )

    let store = TestStore(initialState: state) {
      AttendanceCheckFeature()
    }

    await store.send(.scope(.attendanceModal(.presented(.cancelTapped)))) {
      $0.attendanceModal = nil
    }
  }

  @Test("모달 dismiss 는 상태를 비운다")
  func attendanceModalDismissClearsState() async {
    var state = AttendanceCheckFeature.State()
    state.attendanceModal = .adminStatusChangeWithAvailable(
      availableStatuses: ManagementSupportFixture.statuses
    )

    let store = TestStore(initialState: state) {
      AttendanceCheckFeature()
    }

    await store.send(.scope(.attendanceModal(.dismiss))) {
      $0.attendanceModal = nil
    }
  }
}
