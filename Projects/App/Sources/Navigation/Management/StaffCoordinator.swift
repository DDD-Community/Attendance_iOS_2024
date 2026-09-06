//
//  StaffCoordinator.swift
//  Presentation
//
//  Created by DDD on 11/4/24.
//

import Management
import Foundation
import DDDCoreUtility
import Profile
import ComposableArchitecture
import TCAFlow

@FlowCoordinator(screen: "CoreMemberScreen", navigation: true)
public struct StaffCoordinator {
  public init() {}

  @ObservableState
  public struct State: Equatable {

    public init() {
      self.routes = [.root(.coreMember(.init()), embedInNavigationView: true)]
    }
    var routes: [Route<CoreMemberScreen.State>]
  }

  @CasePathable
  public enum Action {
    case router(IndexedRouterActionOf<CoreMemberScreen>)
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
    // RefreshTokenExpired는 AppReducer에서 처리하므로 중복 제거
  }

  // MARK: - 앱내에서 사용하는 액션

  public enum InnerAction: Equatable {

  }

  // MARK: - NavigationAction

  public enum NavigationAction: Equatable {
    case presentLogin
    case presentMember
  }


  @Dependency(\.continuousClock) var clock

  public nonisolated enum CancelID: Hashable, Sendable {
    case allEffects
    case profileEffects
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

extension StaffCoordinator {
  private func routerAction(
    state: inout State,
    action: IndexedRouterActionOf<CoreMemberScreen>
  ) -> Effect<Action> {
    switch action {
      // MARK: - 운영진 프로필
    case .routeAction(id: _, action: .coreMember(.delegate(.presentManagerProfile))):
      state.routes.push(.profile(.init()))
      return .concatenate(
        .cancel(id: CancelID.profileEffects),
        .cancel(id: ProfileFeature.CancelID.fetchProfile),
        .cancel(id: ProfileFeature.CancelID.deleteUser),
        .cancel(id: ProfileFeature.CancelID.logoutUser)
      )


    // MARK: - 로그아웃
    case .routeAction(id: _, action: .profile(.navigation(.presentLogin))):
      return .concatenate(
        .cancel(id: CancelID.allEffects),
        .cancel(id: CancelID.profileEffects),
        .cancel(id: ProfileFeature.CancelID.fetchProfile),
        .cancel(id: ProfileFeature.CancelID.deleteUser),
        .cancel(id: ProfileFeature.CancelID.logoutUser),
        .send(.navigation(.presentLogin))
      )

      case .routeAction(id: _, action: .profile(.navigation(.presentRoot))):
        return .concatenate(
          .cancel(id: CancelID.profileEffects),
          .cancel(id: ProfileFeature.CancelID.fetchProfile),
          .cancel(id: ProfileFeature.CancelID.deleteUser),
          .cancel(id: ProfileFeature.CancelID.logoutUser),
          .send(.view(.backAction))
        )

      case .routeAction(id: _, action: .profile(.navigation(.presentMember))):
        return .concatenate(
          .cancel(id: CancelID.profileEffects),
          .cancel(id: ProfileFeature.CancelID.fetchProfile),
          .cancel(id: ProfileFeature.CancelID.deleteUser),
          .cancel(id: ProfileFeature.CancelID.logoutUser),
          .send(.navigation(.presentMember))
        )

      case .routeAction(id: _, action: .profile(.navigation(.presentStaff))):
        return .concatenate(
          .cancel(id: CancelID.profileEffects),
          .cancel(id: ProfileFeature.CancelID.fetchProfile),
          .cancel(id: ProfileFeature.CancelID.deleteUser),
          .cancel(id: ProfileFeature.CancelID.logoutUser),
          .send(.view(.backToRootAction))
        )

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
    case .presentLogin:
      return .none

      case .presentMember:
        return .none
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    // RefreshTokenExpired는 AppReducer에서 처리하므로 여기서는 처리할 액션이 없음
    return .none
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    return .none
  }

  // RefreshTokenExpired listener는 AppReducer에서 처리하므로 중복 제거
}

extension StaffCoordinator {
  @Reducer
  public enum CoreMemberScreen {
    case coreMember(StaffFeature)
    case profile(ProfileCoordinator)
  }
}

extension StaffCoordinator.CoreMemberScreen.State: Equatable {}
