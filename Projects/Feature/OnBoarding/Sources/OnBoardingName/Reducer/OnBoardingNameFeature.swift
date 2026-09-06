//
//  OnBoardingNameFeature.swift
//  Presentation
//
//  Created by DDD on 11/3/24.
//

import Foundation

import AuthDomainInterface
import DDDCoreUtility
import OnBoardingInterface

import ComposableArchitecture

@Reducer
public struct OnBoardingNameFeature {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public init() {}

    @Shared(.userSession) var userSession

    
    var isNotAvailableName: Bool = false
    var enableButton: Bool {
      return !userSession.name.isEmpty && !isNotAvailableName
    }
  }
  
  public enum Action: ViewAction, BindableAction {
    case binding(BindingAction<State>)
    case view(View)
    case delegate(DelegateAction)
  }
  
  // MARK: - ViewAction
  
  @CasePathable
  public enum View {
    case checkIsAvailableName
    case initSignUpName
  }

  
  // MARK: - DelegateAction
  /// 이동 계약은 OnBoardingInterface 에 있다. 호출부를 그대로 두기 위해 별칭만 받는다.
  public typealias DelegateAction = OnBoardingNameDelegate
  
  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none
        
      case .view(let viewAction):
        return handleViewAction(state: &state, action: viewAction)
          
      case .delegate(let delegateAction):
        return handleDelegateAction(state: &state, action: delegateAction)
      }
    }
  }
}

extension OnBoardingNameFeature {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .checkIsAvailableName:
      if state.userSession.name.count > 5 {
        state.isNotAvailableName = true
      } else {
        state.isNotAvailableName = false
      }
      return .run { [enableButton = state.enableButton] send in
        if enableButton == true {
          await send(.delegate(.presentSignUpPart))
        }
      }

    case .initSignUpName:
      // 이름 초기화 로직 제거 - 사용자가 입력한 이름을 유지
      return .none
    }
  }

  private func handleDelegateAction(
    state: inout State,
    action: DelegateAction
  ) -> Effect<Action> {
    switch action {
    case .presentBack:
      return .none

    case .presentSignUpPart:
      return .none
    }
  }
}
