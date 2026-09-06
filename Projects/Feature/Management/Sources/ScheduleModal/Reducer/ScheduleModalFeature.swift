//
//  ScheduleModalFeature.swift
//  Management
//
//  Created by DDD on 12/27/25.
//

import DDDCoreLogger
import Foundation

import DDDSharedUI
import ScheduleDomainInterface

import ComposableArchitecture
import ManagementInterface

@Reducer
public struct ScheduleModalFeature {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var schedules: IdentifiedArrayOf<Schedule> = .init(uniqueElements: [])
    /// 이 화면이 지금 무엇을 그려야 하는지.
    public enum ViewState: Equatable {
      case loading
      case loaded
    }

    /// 첫 진입은 항상 fetch 로 시작한다. 빈 화면이 한 프레임 스쳐 지나가지 않도록 스켈레톤부터 그린다.

    var viewState: ViewState = .loading
    var selectedSchedule: Schedule?

    var isConfirmEnabled: Bool {
      selectedSchedule != nil
    }

    public init() {}
  }

  public enum Action: ViewAction, BindableAction {
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case delegate(DelegateAction)
  }

  // MARK: - ViewAction

  @CasePathable
  public enum View {
    case selectSchedule(item: Schedule)
    case confirmSelection
  }

  // MARK: - AsyncAction 비동기 처리 액션

  public enum AsyncAction: Equatable {
    case fetchSchedule
  }

  // MARK: - 앱내에서 사용하는 액션

  public enum InnerAction: Equatable {
    case scheduleResponse(Result<[Schedule], ScheduleError>)
  }

  // MARK: - DelegateAction

  /// 이동 계약은 ManagementInterface 에 있다. 호출부를 그대로 두기 위해 별칭만 받는다.
  public typealias DelegateAction = ScheduleModalDelegate

  @Dependency(\.scheduleUseCase) var scheduleUseCase
  @Dependency(\.continuousClock) var clock

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case let .view(viewAction):
        return handleViewAction(state: &state, action: viewAction)

      case let .async(asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)

      case let .inner(innerAction):
        return handleInnerAction(state: &state, action: innerAction)

      case let .delegate(delegateAction):
        return handleDelegateAction(state: &state, action: delegateAction)
      }
    }
  }
}

extension ScheduleModalFeature {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case let .selectSchedule(item):
      if state.selectedSchedule?.id == item.id {
        state.selectedSchedule = nil
      } else {
        state.selectedSchedule = item
      }
      return .none

    case .confirmSelection:
      guard let selectedSchedule = state.selectedSchedule else {
        return .none
      }
      return .send(.delegate(.selectScheduleCompleted(selectedSchedule: selectedSchedule)))
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .fetchSchedule:
      // 캐시 있으면 로딩 표시 X (SWR로 백그라운드 갱신)
      state.viewState = state.schedules.isEmpty ? .loading : .loaded
      return .run { send in
        if let cached = await scheduleUseCase.getCachedSchedule(), !cached.isEmpty {
          await send(.inner(.scheduleResponse(.success(cached))))
          _ = try? await scheduleUseCase.getSchedule()
          return
        }
        let result = await Result {
          try await scheduleUseCase.getSchedule()
        }
        .mapError(ScheduleError.from)
        try await clock.sleep(for: .seconds(0.6))
        await send(.inner(.scheduleResponse(result)))
      }
    }
  }

  private func handleDelegateAction(
    state _: inout State,
    action: DelegateAction
  ) -> Effect<Action> {
    switch action {
    case .selectScheduleCompleted:
      return .none
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case let .scheduleResponse(result):
      DDDLogger.debug("스케줄 응답 처리: 로딩 완료", category: .network)
      state.viewState = .loaded
      switch result {
      case let .success(data):
        state.schedules = .init(uniqueElements: data)
      case let .failure(error):
        DDDLogger.error("네트워크 에러: \(error.localizedDescription)", category: .network)
      }
      return .none
    }
  }
}
