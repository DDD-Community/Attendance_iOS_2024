//
//  AttendanceCheckFeature.swift
//  Presentation
//
//  Created by DDD on 1/16/25.
//

import AttendanceDomainInterface
import AuthDomainInterface
import DDDCoreLogger
import Foundation
import OnBoardingDomainInterface
import ProfileDomainInterface

import DDDSharedUI

import ComposableArchitecture
import ScheduleDomainInterface

@Reducer
public struct AttendanceCheckFeature {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    public enum ViewState: Equatable {
      case idle
      case loading
      case refreshingAttendanceList
      case loaded
    }

    struct EditTarget: Equatable {
      let attendanceID: Int?
      let userID: String
    }

    @Shared(.userSession) var userSession

    var viewState: ViewState = .idle

    var selectedSchedule: Schedule?
    var selectedTeamID: Int?
    /// 페이지 전환이 끝난 팀. 이 팀을 기준으로 이전/다음 팀을 배치한다.
    var settledTeamID: Int?

    var teams: IdentifiedArrayOf<SelectTeamEntity> = []
    var attendanceByTeam: [Int: [Attendance]] = [:]
    var availableStatuses: IdentifiedArrayOf<AttendanceStatus> = []
    var attendanceSummary: AttendanceCount?

    var editTarget: EditTarget?

    @Presents var destination: Destination.State?
    @Presents var attendanceModal: AttendanceModalState<AttendanceModalAction>?
    @Presents public var alert: AlertState<AlertAction>?

    var selectedScheduleID: Int? {
      selectedSchedule?.id
    }

    var selectedAttendanceDate: Date {
      selectedSchedule?.toDate() ?? .now
    }

    var attendanceCount: Int {
      attendanceSummary?.attendanceCount ?? 0
    }

    var lateCount: Int {
      attendanceSummary?.lateCount ?? 0
    }

    var absentCount: Int {
      attendanceSummary?.absentCount ?? 0
    }

    var orderedTeams: [SelectTeamEntity] {
      teams.sorted { $0.teamId < $1.teamId }
    }

    /// 복제 페이지 없이 현재 팀의 앞뒤에 이전/다음 팀이 오도록 페이지 순서를 회전한다.
    var pageTeams: IdentifiedArrayOf<SelectTeamEntity> {
      let teams = orderedTeams

      guard teams.count > 2 else {
        return .init(uniqueElements: teams)
      }

      guard let settledTeamID,
            let anchorIndex = teams.firstIndex(where: { $0.teamId == settledTeamID })
      else {
        return .init(uniqueElements: teams)
      }

      let startIndex = (anchorIndex - 1 + teams.count) % teams.count
      let rotatedTeams = Array(teams[startIndex...]) + Array(teams[..<startIndex])
      return .init(uniqueElements: rotatedTeams)
    }

    var pageSelection: Int {
      selectedTeamID ?? pageTeams.first?.teamId ?? 0
    }

    public init() {}
  }

  public enum Action: ViewAction, BindableAction {
    case destination(PresentationAction<Destination.Action>)
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case scope(ScopeAction)
  }

  @Reducer(state: .equatable)
  public enum Destination {
    case scheduleModal(ScheduleModalFeature)
  }

  // MARK: - ViewAction

  @CasePathable
  public enum View {
    case onAppear
    case selectPartButton(selectPart: SelectTeamEntity)
    case pageChanged(teamID: Int)
    case closeModal
    case tapSelectDate
    case showEditAttendanceModal(id: Int?, userId: String)
    case refreshData // 수동 새로고침
  }

  // MARK: - AsyncAction 비동기 처리 액션

  public enum AsyncAction: Equatable {
    case fetchSchedule
    case fetchAttendanceCount
    case fetchTeams
    case fetchAttendance
    case fetchStatus
    case editAttendance(status: AttendanceStatus)
  }

  // MARK: - 앱내에서 사용하는 액션

  @CasePathable
  public enum InnerAction: Equatable {
    case fetchScheduleResponse(Result<[Schedule], ScheduleError>)
    case attendanceCountResponse(Result<AttendanceCount, AttendanceError>)
    case fetchTeamsResponse(Result<[SelectTeamEntity], AttendanceError>)
    case attendanceResponse(teamId: Int, Result<[Attendance], AttendanceError>)
    case attendanceStatusResponse(Result<[AttendanceStatus], AttendanceError>)
    case editAttendanceResponse(Result<EditAttendance, AttendanceError>)
    case pageTransitionFinished(teamID: Int)
  }

  @CasePathable
  public enum AlertAction {
    case confirmTapped
  }

  @CasePathable
  public enum ScopeAction: Equatable {
    case alert(PresentationAction<AlertAction>)
    case attendanceModal(PresentationAction<AttendanceModalAction>)
  }

  nonisolated enum CancelID: Hashable {
    case fetchSchedule
    case fetchAttendanceCount
    case fetchTeams
    case fetchAttendance
    case fetchStatus
    case editAttendance
    case pageTransition
  }

  @Dependency(\.attendanceUseCase) var attendanceUseCase
  @Dependency(\.scheduleUseCase) var scheduleUseCase
  @Dependency(\.continuousClock) var clock
  @Dependency(\.mainQueue) var mainQueue

  public var body: some Reducer<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .binding:
        // BindingReducer가 자동으로 처리
        return .none

      case let .view(viewAction):
        return handleViewAction(state: &state, action: viewAction)

      case let .async(asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)

      case let .inner(innerAction):
        return handleInnerAction(state: &state, action: innerAction)

      case let .destination(destinationAction):
        return handleDestinationAction(state: &state, action: destinationAction)

      case let .scope(scopeAction):
        switch scopeAction {
        case .alert:
          return .none

        case let .attendanceModal(action):
          return handleAttendanceModalAction(state: &state, action: action)
        }
      }
    }
    .ifLet(\.$destination, action: \.destination)
    .ifLet(\.$alert, action: \.scope.alert)
    .ifLet(\.$attendanceModal, action: \.scope.attendanceModal) {
      AttendanceModalFeature()
    }
  }
}

extension AttendanceCheckFeature {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .onAppear:
      switch state.viewState {
      case .idle:
        state.viewState = .loading
        return .concatenate(
          .run { await $0(.async(.fetchSchedule)) }, // 성공시 fetchAttendanceCount와 fetchTeams 자동 호출
          .run { await $0(.async(.fetchStatus)) }
        )

      case .loaded:
        return refreshEffect()

      case .loading, .refreshingAttendanceList:
        return .none
      }

    case .refreshData:
      // 수동 새로고침: 실시간 데이터만 다시 가져옴 (스케줄은 제외)
      return refreshEffect()

    case let .selectPartButton(selectPart):
      updateSelectedTeam(state: &state, team: selectPart)
      return .send(.async(.fetchAttendance))

    case let .pageChanged(teamID):
      guard let team = state.orderedTeams.first(where: { $0.teamId == teamID }),
            team.teamId != state.selectedTeamID
      else {
        return .none
      }

      updateSelectedTeam(state: &state, team: team, updatePageAnchor: false)
      return .merge(
        .send(.async(.fetchAttendance)),
        .run { send in
          try await clock.sleep(for: .milliseconds(350))
          await send(.inner(.pageTransitionFinished(teamID: teamID)))
        }
        .cancellable(id: CancelID.pageTransition, cancelInFlight: true)
      )

    case .tapSelectDate:
      state.destination = .scheduleModal(.init())
      return .none

    case .closeModal:
      state.destination = nil
      return .none

    case let .showEditAttendanceModal(id, userid):
      state.attendanceModal = .adminStatusChangeWithAvailable(
        availableStatuses: Array(state.availableStatuses),
        currentStatus: .attended
      )
      state.editTarget = .init(attendanceID: id, userID: userid)
      return .none
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .fetchSchedule:
      state.viewState = .loading
      return .run { send in
        let scheduleResult = await Result {
          try await scheduleUseCase.getSchedule()
        }
        .mapError(ScheduleError.from)
        try await clock.sleep(for: .seconds(0.8))
        return await send(.inner(.fetchScheduleResponse(scheduleResult)))
      }
      .cancellable(id: CancelID.fetchSchedule, cancelInFlight: true)

    case .fetchAttendanceCount:
      guard let scheduleID = state.selectedScheduleID else {
        DDDLogger.debug("fetchAttendanceCount 건너뜀: 선택된 스케줄 없음", category: .attendance)
        return .none
      }

      // scheduleId가 유효한지 확인
      guard scheduleID > 0 else {
        DDDLogger.debug("fetchAttendanceCount 건너뜀: scheduleId: \(scheduleID)", category: .attendance)
        return .none
      }

      return .run { send in
        let attendanceResult = await Result {
          try await attendanceUseCase.adminAttendanceCount(scheduleId: scheduleID)
        }
        .mapError(AttendanceError.from)
        return await send(.inner(.attendanceCountResponse(attendanceResult)))
      }
      .cancellable(id: CancelID.fetchAttendanceCount, cancelInFlight: true)

    case .fetchTeams:
      return .run { send in
        let teamResult = await Result {
          try await attendanceUseCase.fetchAttendanceTeams()
        }
        .mapError(AttendanceError.from)
        return await send(.inner(.fetchTeamsResponse(teamResult)))
      }
      .cancellable(id: CancelID.fetchTeams, cancelInFlight: true)

    case .fetchAttendance:
      guard let scheduleId = state.selectedScheduleID,
            let teamId = state.selectedTeamID
      else {
        DDDLogger.debug("fetchAttendance 건너뜀: 스케줄 또는 팀이 선택되지 않음", category: .attendance)
        return .none
      }

      // scheduleId와 teamId가 유효한지 확인
      guard scheduleId > 0, teamId > 0 else {
        DDDLogger.debug("fetchAttendance 건너뜀: scheduleId: \(scheduleId), teamId: \(teamId)", category: .attendance)
        return .none
      }

      return .run { send in
        let attendanceResult = await Result {
          try await attendanceUseCase.sessionAttendance(scheduleId: scheduleId, teamId: teamId)
        }
        .mapError(AttendanceError.from)
        return await send(.inner(.attendanceResponse(teamId: teamId, attendanceResult)))
      }
      .cancellable(id: CancelID.fetchAttendance, cancelInFlight: true)

    case .fetchStatus:
      return .run { send in
        let statusResult = await Result {
          try await attendanceUseCase.fetchStatus()
        }
        .mapError(AttendanceError.from)
        return await send(.inner(.attendanceStatusResponse(statusResult)))
      }
      .cancellable(id: CancelID.fetchStatus, cancelInFlight: true)

    case let .editAttendance(status):
      guard let editTarget = state.editTarget,
            let scheduleId = state.selectedScheduleID
      else {
        return .none
      }

      return .run { send in
        let editAttendanceResult = await Result {
          let input = EditAttendanceInput(
            attendanceId: editTarget.attendanceID,
            scheduleId: scheduleId,
            status: status,
            userId: editTarget.userID
          )
          return try await attendanceUseCase.editAttendance(input: input)
        }
        .mapError(AttendanceError.from)

        return await send(.inner(.editAttendanceResponse(editAttendanceResult)))
      }
      .cancellable(id: CancelID.editAttendance, cancelInFlight: true)
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case let .fetchScheduleResponse(result):
      switch result {
      case let .success(schedules):
        state.viewState = .loaded
        let selectedScheduleID = closestScheduleId(from: schedules)
        state.selectedSchedule = schedules.first(where: { $0.id == selectedScheduleID })
          ?? schedules.first
          ?? state.selectedSchedule

        // 스케줄이 설정된 후 출석 통계 및 팀 정보 가져오기
        return .merge(
          .send(.async(.fetchAttendanceCount)),
          .send(.async(.fetchTeams)) // team 설정 후 fetchAttendance 자동 호출됨
        )

      case let .failure(error):
        DDDLogger.error("스케줄 조회 실패: \(error.localizedDescription)", category: .network)
        state.viewState = .loaded
        return .none
      }

    case let .attendanceCountResponse(result):
      switch result {
      case let .success(data):
        state.attendanceSummary = data

      case let .failure(error):
        DDDLogger.error("기수 출석 현황 조회 실패: \(error.localizedDescription)", category: .network)
      }
      return .none

    case let .fetchTeamsResponse(result):
      switch result {
      case let .success(data):
        var seen: Set<SelectTeams> = []
        let uniqueTeams = data.filter { seen.insert($0.teams).inserted }
        let orderedTeams = uniqueTeams.sorted { $0.teamId < $1.teamId }
        state.teams = .init(uniqueElements: orderedTeams)
        for team in orderedTeams {
          if state.attendanceByTeam[team.teamId] == nil {
            state.attendanceByTeam[team.teamId] = []
          }
        }
        if let userTeam = orderedTeams.first(where: { $0.teams == state.userSession.selectTeam }) {
          updateSelectedTeam(state: &state, team: userTeam)
        } else if let firstTeam = orderedTeams.first {
          updateSelectedTeam(state: &state, team: firstTeam)
        }

        // team 설정 후 출석 데이터 가져오기 (scheduleId가 유효한 경우에만)
        if state.selectedScheduleID != nil {
          return .send(.async(.fetchAttendance))
        } else {
          return .none
        }

      case let .failure(error):
        DDDLogger.error("기수 팀 조회 실패: \(error.localizedDescription)", category: .network)
        return .none
      }

    case let .attendanceResponse(teamId, result):
      // 출석 상태 수정 후 재조회의 성공 여부와 관계없이 카드 목록 skeleton을 내린다.
      state.viewState = .loaded
      switch result {
      case let .success(data):
        state.attendanceByTeam[teamId] = data

      case let .failure(error):
        DDDLogger.error("기수 출석 현황 조회 실패: \(error.localizedDescription)", category: .network)
      }
      return .none

    case let .attendanceStatusResponse(result):
      switch result {
      case let .success(data):
        state.availableStatuses = .init(uniqueElements: data)
      case let .failure(error):
        DDDLogger.error("출석 현황 조회 실패: \(error.localizedDescription)", category: .attendance)
      }
      return .none

    case let .editAttendanceResponse(result):
      switch result {
      case .success:
        state.viewState = .refreshingAttendanceList
        return .merge(
          .run { await $0(.async(.fetchAttendanceCount)) },
          .run { await $0(.async(.fetchAttendance)) }
        )
      case let .failure(error):
        DDDLogger.error("출석 현황 수정 실패: \(error.localizedDescription)", category: .attendance)

        // 서버에서 온 사용자 친화적 메시지 사용
        let alertTitle: String
        let alertMessage: String

        // 전송 실패는 도메인이 구분하지 않으므로 서버가 준 거절 사유만 따로 보여준다.
        switch error {
        case let .rejected(message):
          alertTitle = "알림"
          alertMessage = message
        default:
          alertTitle = "출석 수정 실패"
          alertMessage = error.errorDescription ?? "출석 상태 수정에 실패했습니다. 다시 시도해주세요."
        }

        state.alert = AlertState {
          TextState(alertTitle)
        } actions: {
          ButtonState(action: .confirmTapped) {
            TextState("확인")
          }
        } message: {
          TextState(alertMessage)
        }
      }
      return .none

    case let .pageTransitionFinished(teamID):
      guard state.selectedTeamID == teamID else {
        return .none
      }
      state.settledTeamID = teamID
      return .none
    }
  }

  private func handleDestinationAction(
    state: inout State,
    action: PresentationAction<Destination.Action>
  ) -> Effect<Action> {
    switch action {
    case let .presented(.scheduleModal(.delegate(.selectScheduleCompleted(selectedSchedule)))):
      if selectedSchedule.toDate() != nil {
        state.selectedSchedule = selectedSchedule
        DDDLogger.debug("날짜 업데이트됨: 새로운 스케줄: \(selectedSchedule.id)", category: .attendance)
      } else {
        DDDLogger.error(
          "날짜 변환 실패: 입력: year=\(selectedSchedule.year), month=\(selectedSchedule.month), day=\(selectedSchedule.day)",
          category: .attendance
        )
      }

      state.destination = nil

      // 새로운 스케줄 선택시 해당 스케줄의 출석 데이터를 새로 가져오기
      return .merge(
        .send(.async(.fetchAttendanceCount)), // 새 스케줄의 출석 통계
        .send(.async(.fetchAttendance)) // 새 스케줄의 출석 리스트
      )

    default:
      return .none
    }
  }

  private func handleAttendanceModalAction(
    state: inout State,
    action: PresentationAction<AttendanceModalAction>
  ) -> Effect<Action> {
    switch action {
    case let .presented(attendanceModalAction):
      switch attendanceModalAction {
      case .binding:
        return .none

      case let .confirmTapped(status):
        state.attendanceModal = nil
        return .send(.async(.editAttendance(status: status)))

      case .cancelTapped:
        state.attendanceModal = nil
        return .none
      }

    case .dismiss:
      return .none
    }
  }
}

private extension AttendanceCheckFeature {
  func refreshEffect() -> Effect<Action> {
    .merge(
      .run { await $0(.async(.fetchAttendanceCount)) },
      .run { await $0(.async(.fetchTeams)) },
      .run { await $0(.async(.fetchStatus)) }
    )
  }

  func updateSelectedTeam(
    state: inout State,
    team: SelectTeamEntity,
    updatePageAnchor: Bool = true
  ) {
    state.selectedTeamID = team.teamId
    if updatePageAnchor {
      state.settledTeamID = team.teamId
    }
  }

  func todayScheduleId(
    from schedules: [Schedule],
    now: Date = Date(),
    timeZone: TimeZone = .init(identifier: "Asia/Seoul")!
  ) -> Int? {
    guard let today = normalizedDate(now, timeZone: timeZone) else { return nil }

    return schedules.first(where: {
      $0.toDate(timeZone: timeZone) == today
    })?.id
  }

  /// 오늘 일정을 우선하고, 없으면 절대 시간 거리가 가장 짧은 일정을 반환한다.
  func closestScheduleId(
    from schedules: [Schedule],
    now: Date = Date(),
    timeZone: TimeZone = .init(identifier: "Asia/Seoul")!
  ) -> Int? {
    guard let today = normalizedDate(now, timeZone: timeZone) else { return nil }

    if let todayScheduleId = todayScheduleId(
      from: schedules,
      now: now,
      timeZone: timeZone
    ) {
      return todayScheduleId
    }

    return schedules
      .compactMap { schedule -> (Schedule, TimeInterval)? in
        guard let scheduleDate = schedule.toDate(timeZone: timeZone) else { return nil }
        return (schedule, abs(scheduleDate.timeIntervalSince(today)))
      }
      .min(by: { $0.1 < $1.1 })?
      .0.id
  }

  func normalizedDate(_ date: Date, timeZone: TimeZone) -> Date? {
    date
      .formatted(.yearMonthDay, timeZone: timeZone)
      .date(as: .yearMonthDay, timeZone: timeZone)
  }
}
