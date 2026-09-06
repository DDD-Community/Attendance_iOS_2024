//
//  MemberMainFeature.swift
//  Presentation
//
//  Created by DDD on 1/2/25.
//

import DDDCoreLogger
import Foundation

import AttendanceDomainInterface
import DDDSharedUI
import MyPageDomainInterface
import ProfileDomainInterface
import VoteDomainInterface

import ComposableArchitecture
import MemberInterface
import ScheduleDomainInterface

@Reducer
public struct MemberMainFeature {
  public init() {}

  // 멤버 홈 탭 (일정은 운영진 전용이라 제외)
  public enum HomeTab: String, CaseIterable, Equatable {
    case attendance
    case vote

    public var title: String {
      switch self {
      case .attendance: return "출석현황"
      case .vote: return "투표"
      }
    }
  }

  @ObservableState
  public struct State: Equatable {
    public enum ViewState: Equatable {
      case loading
      case loaded
    }

    enum LoadingResource: Hashable {
      case profileAndAttendance
      case schedule
      case activeVote
    }

    var viewState: ViewState = .loading

    @ObservationStateIgnored
    var pendingLoadingResources: Set<LoadingResource> = []

    var member: ProfileEntity?

    var selectedHomeTab: HomeTab = .attendance
    var isExpandedDropDown: Bool = false
    var isVoteMenuAvailable: Bool = false

    // 투표 탭
    var vote: MemberVoteFeature.State = .init()

    @ObservationStateIgnored
    var didAppear: Bool = false

    // 출석 현황
    var startDate: String = ""
    var endDate: String = ""
    var presentCount: Int = .zero
    var lateCount: Int = .zero
    var absentCount: Int = .zero
    var showsAttendanceWarningIcon: Bool { absentCount > 0 }
    var isAttendanceWarningAlertPresented = false
    var attendanceViewState: ViewState = .loading

    // 일정표
    var schedules: IdentifiedArrayOf<ScheduleModel> = .init(uniqueElements: [])

    public init() {}
  }

  public enum Action: ViewAction, BindableAction {
    case binding(BindingAction<State>)
    case view(View)
    case inner(InnerAction)
    case async(AsyncAction)
    case delegate(DelegateAction)
    case vote(MemberVoteFeature.Action)
  }

  @CasePathable
  public enum View {
    case onAppear
    case onDisappear
    case didTapAbesentButton
    case didTapDismissAlertButton
    case toggleDropDown
    case closeDropDown
    case selectHomeTab(HomeTab)
    case didTapVoteBackButton
  }

  public enum AsyncAction: Equatable {
    case fetchCurrentUser
    case fetchAttendances
    case fetchSchedule
    case fetchActiveVote
  }

  public enum InnerAction: Equatable {
    case onFetchUserResponse(Result<ProfileEntity, ProfileError>)
    case onFetchAttendanceSummaryResponse(Result<AttendanceSummaryResponse, AttendanceError>)
    case onFetchSchedulesResponse(Result<[ScheduleModel], ScheduleError>)
    case onFetchActiveVoteResponse(Result<ActiveVote, VoteError>)
    case onResume
  }

  /// 이동 계약은 MemberInterface 에 있다. 호출부를 그대로 두기 위해 별칭만 받는다.
  public typealias DelegateAction = MemberMainDelegate

  @Dependency(\.profileUseCase) var profileUseCase
  @Dependency(\.attendanceUseCase) var attendanceUseCase
  @Dependency(\.myPageUseCase) var myPageUseCase
  @Dependency(\.voteUseCase) var voteUseCase

  public var body: some Reducer<State, Action> {
    BindingReducer()

    Scope(state: \.vote, action: \.vote) {
      MemberVoteFeature()
    }

    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case let .view(action):
        return handleViewAction(state: &state, action: action)

      case let .inner(action):
        return handleInnerAction(state: &state, action: action)

      case let .async(action):
        return handleAsyncAction(state: &state, action: action)

      case let .delegate(action):
        return handleDelegateAction(state: &state, action: action)

      case .vote(.delegate(.exitVote)):
        state.selectedHomeTab = .attendance
        state.isExpandedDropDown = false
        state.vote = .init()
        return .none

      case .vote(.inner(.activeVoteResponse(.failure))):
        state.isVoteMenuAvailable = false
        if state.selectedHomeTab == .vote {
          state.selectedHomeTab = .attendance
        }
        state.isExpandedDropDown = false
        return .none

      case .vote:
        return .none
      }
    }
  }
}

extension MemberMainFeature.State {
  var usesVoteWritingNavigationBar: Bool {
    selectedHomeTab == .vote && vote.step.usesVoteWritingNavigationBar
  }
}

private extension MemberVoteFeature.Step {
  var usesVoteWritingNavigationBar: Bool {
    switch self {
    case .loading, .teamSelect, .feedback:
      return true
    case .empty, .alreadyVoted, .completed:
      return false
    }
  }
}

extension MemberMainFeature {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .onAppear:
      guard !state.didAppear else {
        return .none
      }

      state.didAppear = true
      beginLoading(state: &state)

      return .merge(
        .run { await $0(.async(.fetchCurrentUser)) },
        .run { await $0(.async(.fetchSchedule)) },
        .run { await $0(.async(.fetchActiveVote)) }
      )

    case .onDisappear:
      state.didAppear = false
      return .none

    case .didTapAbesentButton:
      guard state.showsAttendanceWarningIcon else {
        return .none
      }

      state.isAttendanceWarningAlertPresented = true
      return .none

    case .didTapDismissAlertButton:
      state.isAttendanceWarningAlertPresented = false
      return .none

    case .toggleDropDown:
      state.isExpandedDropDown.toggle()
      return .none

    case .closeDropDown:
      state.isExpandedDropDown = false
      return .none

    case let .selectHomeTab(tab):
      guard tab != .vote || state.isVoteMenuAvailable else {
        state.isExpandedDropDown = false
        return .none
      }
      state.selectedHomeTab = tab
      state.isExpandedDropDown = false
      return .none

    case .didTapVoteBackButton:
      return .send(.vote(.view(.requestExit)))
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case let .onFetchUserResponse(result):
      switch result {
      case let .success(member):
        state.member = member
        DDDLogger.debug("Succeed Fetch User Profile: \(member)", category: .attendance)
        return .none

      case let .failure(error):
        state.member = nil
        state.attendanceViewState = .loaded
        finishLoading(state: &state, resource: .profileAndAttendance)
        DDDLogger.error("Failed Fetch User Profile: \(error)", category: .attendance)
        return .none
      }

    case let .onFetchAttendanceSummaryResponse(result):
      finishLoading(state: &state, resource: .profileAndAttendance)
      state.attendanceViewState = .loaded
      switch result {
      case let .success(counts):
        state.presentCount = counts.totalAttended
        state.lateCount = counts.totalLate
        state.absentCount = counts.totalAbsent
        DDDLogger.debug("Succeed Fetch Attendance Counts: \(counts)", category: .attendance)
        return .none

      case let .failure(error):
        DDDLogger.error("Failed Fetch Count: \(error)", category: .attendance)
        return .none
      }

    case let .onFetchSchedulesResponse(result):
      finishLoading(state: &state, resource: .schedule)
      switch result {
      case let .success(schedules):
        state.schedules = .init(uniqueElements: schedules)

        // TODO: - 추후 기수 활동 기간 API 필요
        if let start = schedules.first, let end = schedules.last {
          state.startDate = "2026.\(start.month).\(start.day)"
          state.endDate = "2026.\(end.month).\(end.day)"
        }

        DDDLogger.debug("Succeed Fetch Schedules: \(schedules)", category: .attendance)
        return .none

      case let .failure(error):
        DDDLogger.error("Failed Fetch Schedules: \(error)", category: .attendance)
        return .none
      }

    case let .onFetchActiveVoteResponse(result):
      finishLoading(state: &state, resource: .activeVote)
      switch result {
      case .success:
        state.isVoteMenuAvailable = true
        return .none

      case let .failure(error):
        state.isVoteMenuAvailable = false
        if state.selectedHomeTab == .vote {
          state.selectedHomeTab = .attendance
          state.vote = .init()
        }
        state.isExpandedDropDown = false
        DDDLogger.error("Failed Fetch Active Vote: \(error)", category: .attendance)
        return .none
      }

    case .onResume:
      state.attendanceViewState = .loading
      return .send(.async(.fetchAttendances))
    }
  }

  private func beginLoading(state: inout State) {
    state.viewState = .loading
    state.pendingLoadingResources = [.profileAndAttendance, .schedule, .activeVote]
  }

  private func finishLoading(
    state: inout State,
    resource: State.LoadingResource
  ) {
    guard state.pendingLoadingResources.remove(resource) != nil else {
      return
    }

    if state.pendingLoadingResources.isEmpty {
      state.viewState = .loaded
    }
  }

  private func handleAsyncAction(
    state _: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .fetchCurrentUser:
      return .run { send in
        let result = await Result {
          try await profileUseCase.getProfile()
        }

        switch result {
        case let .success(member):
          await send(.inner(.onFetchUserResponse(.success(member))))
          await send(.async(.fetchAttendances))

        case let .failure(error):
          let error = ProfileError.from(error)
          await send(.inner(.onFetchUserResponse(.failure(error))))
        }
      }

    case .fetchAttendances:
      return .run { send in
        let result = await Result {
          try await myPageUseCase.fetchAttendances()
        }

        switch result {
        case let .success(counts):
          await send(.inner(.onFetchAttendanceSummaryResponse(.success(counts))))

        case let .failure(error):
          let error = AttendanceError.from(error)
          await send(.inner(.onFetchAttendanceSummaryResponse(.failure(error))))
        }
      }

    case .fetchSchedule:
      return .run { send in
        let result = await Result {
          try await myPageUseCase.fetchSchedules()
        }

        switch result {
        case let .success(schedules):
          let schedules = schedules.map { $0.toPresentation() }
          await send(.inner(.onFetchSchedulesResponse(.success(schedules))))

        case let .failure(error):
          let error = ScheduleError.from(error)
          await send(.inner(.onFetchSchedulesResponse(.failure(error))))
        }
      }

    case .fetchActiveVote:
      return .run { send in
        let result = await Result {
          try await voteUseCase.fetchActiveVote()
        }
        .mapError(VoteError.from)
        await send(.inner(.onFetchActiveVoteResponse(result)))
      }
    }
  }

  private func handleDelegateAction(
    state: inout State,
    action: DelegateAction
  ) -> Effect<Action> {
    switch action {
    case .routeToQRCode:
      state.isExpandedDropDown = false
      return .none

    case .routeToProfile:
      state.isExpandedDropDown = false
      return .none
    }
  }
}

private extension AttendanceMyScheduleResponse {
  func toPresentation() -> ScheduleModel {
    return .init(
      id: id,
      title: name,
      description: desc,
      month: month,
      day: day,
      status: .init(rawValue: status) ?? .none
    )
  }
}
