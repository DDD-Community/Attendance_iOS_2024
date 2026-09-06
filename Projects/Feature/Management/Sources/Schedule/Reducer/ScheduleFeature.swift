//
//  ScheduleFeature.swift
//  Presentation
//
//  Created by DDD on 5/9/25.
//

import DDDCoreLogger
import Foundation

import DDDSharedUI

import ComposableArchitecture
import ScheduleDomainInterface
import AuthDomainInterface

@Reducer
public struct ScheduleFeature {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    
    public init() {}
    
    var schedules: IdentifiedArrayOf<Schedule> = .init(uniqueElements: [])
    /// 이 화면이 지금 무엇을 그려야 하는지.
    public enum ViewState: Equatable {
      case loading
      case loaded
    }

    /// 첫 진입은 항상 fetch 로 시작한다. 빈 화면이 한 프레임 스쳐 지나가지 않도록 스켈레톤부터 그린다.

    var viewState: ViewState = .loading
    var hasFetchedSchedule: Bool = false
    @Shared(.userSession) var userSession

  }
  
  public enum Action: ViewAction, BindableAction {
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    
  }
  
  //MARK: - ViewAction
  @CasePathable
    public enum View {
      case onAppear
    
  }
  
  
  //MARK: - AsyncAction 비동기 처리 액션
  public enum AsyncAction: Equatable {
    case fetchSchedule
    case refreshSchedule
  }
  
  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction {
    case fetchScheduleResponse(Result<[Schedule], ScheduleError>)
  }
  
  nonisolated enum CancelID: Hashable {
    case fetchSchedule
  }

  @Dependency(\.scheduleUseCase) var scheduleUseCase
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.continuousClock) var  clock
  
  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none
        
      case .view(let viewAction):
        return handleViewAction(state: &state, action: viewAction)
        
      case .async(let asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)
        
      case .inner(let innerAction):
        return handleInnerAction(state: &state, action: innerAction)
        
      }
    }
  }
}

extension ScheduleFeature {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .onAppear:
      guard !state.hasFetchedSchedule else {
        // 두 번째 진입부터는 스켈레톤 없이 최신 일정만 받아온다.
        return .send(.async(.refreshSchedule))
      }
      state.hasFetchedSchedule = true
      return .send(.async(.fetchSchedule))

    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .fetchSchedule:
      state.viewState = .loading
      return scheduleEffect()

    case .refreshSchedule:
      return scheduleEffect()
    }
  }

  private func scheduleEffect() -> Effect<Action> {
    return .run { send in
      let scheduleResult = await Result {
        try await scheduleUseCase.getSchedule()
      }
        .mapError(ScheduleError.from)
      return await send(.inner(.fetchScheduleResponse(scheduleResult)))
    }
    .cancellable(id: CancelID.fetchSchedule, cancelInFlight: true)
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case .fetchScheduleResponse(let result):
      switch result {
      case .success(let schedules):
        state.schedules = .init(uniqueElements: schedules)
          state.viewState = .loaded

      case .failure(let error):
        DDDLogger.error("스케줄 조회 실패: \(error.localizedDescription ?? "알 수 없는 오류")", category: .network)
        state.viewState = .loaded
      }
      return .none
    }
  }
}
