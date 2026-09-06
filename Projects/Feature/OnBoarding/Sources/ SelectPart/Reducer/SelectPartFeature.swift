//
//  SelectPartFeature.swift
//  Presentation
//
//  Created by DDD on 11/3/24.
//

import DDDCoreLogger
import Foundation

import DDDCoreUtility
import OnBoardingDomainInterface

import ComposableArchitecture
import OnBoardingInterface

@Reducer
public struct SelectPartFeature {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public init() {}

    var activeSelectPart = false
    var selectPart: SelectParts? = .all
    var selectJobs: IdentifiedArrayOf<SelectJob> = []
    /// 이 화면이 지금 무엇을 그려야 하는지.
    public enum ViewState: Equatable {
      case loading
      case loaded
    }

    /// 첫 진입은 항상 fetch 로 시작한다. 빈 화면이 한 프레임 스쳐 지나가지 않도록 스켈레톤부터 그린다.

    var viewState = ViewState.loading
    @Shared(.userSession) var userSession

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
    case selectPartButton(selectPart: SelectJob)
    case onAppear
  }
  
  // MARK: - AsyncAction 비동기 처리 액션
  
  public enum AsyncAction: Equatable {
    case getJobList
  }
  
  // MARK: - 앱내에서 사용하는 액션
  
  public enum InnerAction: Equatable {
    case jobListResponse(Result<[SelectJob], SignUpError>)
  }
  
  // MARK: - DelegateAction
  
  /// 이동 계약은 OnBoardingInterface 에 있다. 호출부를 그대로 두기 위해 별칭만 받는다.
  public typealias DelegateAction = SelectPartDelegate


  nonisolated enum CancelID: Hashable {
    case fetchJobList
  }

  @Dependency(\.onBoardingUseCase) var onBoardingUseCase

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
        
      case .delegate(let delegateAction):
        return handleDelegateAction(state: &state, action: delegateAction)
      }
    }
  }
}

extension SelectPartFeature {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {

    case .selectPartButton(let selectJob):
      let selectedPart = selectJob.job

      if state.selectPart == selectedPart {
        // 동일한 파트 재선택 → 해제
        state.selectPart = nil
        state.$userSession.withLock { $0.selectPart = .all }
        state.activeSelectPart = false
        return .none
      }

      state.selectPart = selectedPart
        state.$userSession.withLock { $0.selectPart = selectedPart }
      state.activeSelectPart = true
//      DDDLogger.debug("selectPart: \(state.userEntity.role)", category: .auth)
      return .none

      case .onAppear:
        return .send(.async(.getJobList))
    }
  }

  private func handleDelegateAction(
    state: inout State,
    action: DelegateAction
  ) -> Effect<Action> {
    switch action {
    case .presentBack:
      return .none

    case .presentManaging:
      return .none
    case .presentSelectTeam:
      return .none
    case .presentNextStep:
        return .run { [isAdmin = state.userSession.userRole] send in
        if isAdmin == .manager {
          await send(.delegate(.presentManaging))
        } else {
          await send(.delegate(.presentSelectTeam))
        }
      }
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
      case .getJobList:
        state.viewState = .loading
        return .run { send in
          let jobListResult = await Result {
            try await onBoardingUseCase.fetchJobs()
          }
            .mapError(SignUpError.from)
          return await send(.inner(.jobListResponse(jobListResult)))
        }
        .cancellable(id: CancelID.fetchJobList, cancelInFlight: true)
    }

  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
      case .jobListResponse(let result):
        switch result {
          case .success(let data):
            state.viewState = .loaded
            state.selectJobs = .init(uniqueElements: data)

          case .failure(let error):
            state.viewState = .loaded
            DDDLogger.error("네트워크 통신 실패: \(error.errorDescription)", category: .auth)
        }
        return .none

    }
  }
}
