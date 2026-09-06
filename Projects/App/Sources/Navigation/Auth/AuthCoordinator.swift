//
//  AuthCoordinator.swift
//  Presentation
//
//  Created by DDD on 11/2/24.
//

import Auth
import AuthDomainInterface
import Foundation

import DDDCoreUtility

import ComposableArchitecture
import TCAFlow
import OnBoarding
import Web

@FlowCoordinator(screen: "AuthScreen", navigation: true)
public struct AuthCoordinator {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var routes: [Route<AuthScreen.State>]

    public init() {
      @Shared(.userSession) var userSession
      self.routes = [.root(.login(.init(userSession: userSession)), embedInNavigationView: true)]
    }
  }

  @CasePathable
  public enum Action {
    case router(IndexedRouterActionOf<AuthScreen>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case navigation(NavigationAction)
  }

  // MARK: - ViewAction

  @CasePathable
  public enum View {
    case backAction
    case backToRootAction
  }

  // MARK: - AsyncAction 비동기 처리 액션

  public enum AsyncAction: Equatable {

  }

  // MARK: - 앱내에서 사용하는 액션

  public enum InnerAction: Equatable {

  }

  // MARK: - NavigationAction

  public enum NavigationAction: Equatable {
    case presentStaff
    case presentMember
    case cleanup
  }

  func handleRoute(state: inout State, action: Action) -> Effect<Action> {
    switch action {
      case .router(let routeAction):
        return routerAction(state: &state, action: routeAction)

      case .view(let viewAction):
        return handleViewAction(state: &state, action: viewAction)

      case .async(let asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)

      case .inner(let innerAction):
        return handleInnerAction(state: &state, action: innerAction)

      case .navigation(let navigationAction):
        return handleNavigationAction(state: &state, action: navigationAction)
    }
  }
}

// MARK: - Effect Cancellation IDs
nonisolated enum AuthCancelID: Hashable {
  case selectTeamEffects
  case onBoardingEffects
  case loginEffects
}

extension AuthCoordinator {
  private func routerAction(
    state: inout State,
    action: IndexedRouterActionOf<AuthScreen>
  ) -> Effect<Action> {
    switch action {

        // MARK: - 초대코드 입력
      case .routeAction(id: _, action: .login(.delegate(.presentSignUpInviteView))):
        state.routes.push(.onboarding(.init()))
        return .none

      case .routeAction(id: _, action: .login(.delegate(.presentStaffMain))):
        return .send(.navigation(.presentStaff))

      case .routeAction(id: _, action: .login(.delegate(.presentMemberMain))):
        return .send(.navigation(.presentMember))

      case .routeAction(id: _, action: .login(.delegate(.presentWeb))):
        state.routes.push(.web(.init(url: "https://dddset.notion.site/DDD-2d424441b0b08080a518ed42f1315b20?source=copy_link")))
        return .none

      case .routeAction(id: _, action: .web(.backToRoot)):
        return .send(.view(.backAction))

      case .routeAction(id: _, action: .onboarding(.navigation(.backToRoot))):
        state.routes.goBackTo(\.login)
        return .none

      case .routeAction(id: _, action: .onboarding(.navigation(.presentStaff))):
        return .send(.navigation(.presentStaff))

      case .routeAction(id: _, action: .onboarding(.navigation(.presentMember))):
        return .send(.navigation(.presentMember))

      default:
        return .none
    }
  }

  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
      case .backAction:
        state.routes.goBack()
        return .none

      case .backToRootAction:
        state.routes.goBackToRoot()
        return .none
    }
  }

  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
      case .presentStaff:
        return .none

      case .presentMember:
        return .none

      case .cleanup:
        return .merge(
          .cancel(id: AuthCancelID.selectTeamEffects),
          .cancel(id: AuthCancelID.onBoardingEffects),
          .cancel(id: AuthCancelID.loginEffects)
        )
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    return .none
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    return .none
  }
}

extension AuthCoordinator {
  @Reducer
  public enum AuthScreen {
    case login(LoginFeature)
    case onboarding(OnBoardingCoordinator)
    case web(WebFeature)
  }
}

extension AuthCoordinator.AuthScreen.State: Equatable {}
