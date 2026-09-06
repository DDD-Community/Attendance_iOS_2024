//
//  ProfileCoordinator.swift
//  Profile
//
//  Created by DDD on 1/4/26.
//

import Profile
import Foundation

import DDDSharedUI

import ComposableArchitecture
import TCAFlow
import OnBoarding
import Web

@FlowCoordinator(screen: "ProfileScreen", navigation: true)
public struct ProfileCoordinator: Sendable {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var routes: [Route<ProfileScreen.State>]

    public init() {
      routes = [.root(.profile(.init()), embedInNavigationView: true)]
    }
  }

  @CasePathable
  public enum Action {
    case router(IndexedRouterActionOf<ProfileScreen>)
    case view(View)
    case inner(InnerAction)
    case async(AsyncAction)
    case navigation(NavigationAction)
  }

  @CasePathable
  public enum View {
    case backAction
    case backToRootAction
  }

  public enum AsyncAction: Equatable {

  }

  public enum InnerAction: Equatable {

  }

  public enum NavigationAction: Equatable {
    case presentLogin
    case presentRoot
    case presentStaff
    case presentMember
  }

  func handleRoute(state: inout State, action: Action) -> Effect<Action> {
    switch action {
      case .router(let action):
        return routerAction(state: &state, action: action)

      case .view(let action):
        return handleViewAction(state: &state, action: action)

      case .inner(let action):
        return handleInnerAction(state: &state, action: action)

      case .async(let action):
        return handleAsyncAction(state: &state, action: action)

      case .navigation(let action):
        return handleNavigationAction(state: &state, action: action)
    }
  }
}

extension ProfileCoordinator {
  private func routerAction(
    state: inout State,
    action: IndexedRouterActionOf<ProfileScreen>
  ) -> Effect<Action> {
    switch action {
    case .routeAction(id: _, action: .profile(.delegate(.presentBack))):
      return .send(.navigation(.presentRoot))

    case .routeAction(id: _, action: .profile(.delegate(.presentLogOut))):
      return .concatenate(
        .cancel(id: ProfileFeature.CancelID.fetchProfile),
        .cancel(id: ProfileFeature.CancelID.deleteUser),
        .cancel(id: ProfileFeature.CancelID.logoutUser),
        .send(.navigation(.presentLogin))
      )

      case .routeAction(id: _, action: .profile(.delegate(.presentPrivacyPolicy))):
        state.routes.push(.web(.init(url: "https://dddset.notion.site/DDD-2d424441b0b08080a518ed42f1315b20?source=copy_link")))
        return .none


      case .routeAction(id: _, action: .profile(.delegate(.presentAppPeedBackWeb))):
        state.routes.push(.web(.init(url: "https://forms.gle/a2idQmnxjbC5czfP7")))
        return .none


      case .routeAction(id: _, action: .profile(.delegate(.presentEditGeneration))):
        state.routes.push(.onBoarding(.init()))
        return .none

      case .routeAction(id: _, action: .web(.backToRoot)):
        return .send(.view(.backAction))

      case .routeAction(id: _, action: .onBoarding(.navigation(.presentLogin))):
        return .send(.navigation(.presentLogin))

      case .routeAction(id: _, action: .onBoarding(.navigation(.backToRoot))):
        state.routes.goBackTo(\.profile)
        return .none

      case .routeAction(id: _, action: .onBoarding(.navigation(.presentProfile))):
        state.routes.goBackTo(\.profile)
        return .none

      // 기수변경으로 역할이 바뀐 경우 상위(Member/Staff)로 전파해 홈 전환
      case .routeAction(id: _, action: .onBoarding(.navigation(.presentStaff))):
        return .send(.navigation(.presentStaff))

      case .routeAction(id: _, action: .onBoarding(.navigation(.presentMember))):
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
      // 🔥 TCA 해결책 2: navigation 시 모든 Profile Effect 취소
      return .concatenate(
        .cancel(id: ProfileFeature.CancelID.fetchProfile),
        .cancel(id: ProfileFeature.CancelID.deleteUser),
        .cancel(id: ProfileFeature.CancelID.logoutUser)
      )

    case .backToRootAction:
      state.routes.goBackToRoot()
      return .concatenate(
        .cancel(id: ProfileFeature.CancelID.fetchProfile),
        .cancel(id: ProfileFeature.CancelID.deleteUser),
        .cancel(id: ProfileFeature.CancelID.logoutUser)
      )
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    return .none
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    return .none
  }

  private func handleNavigationAction(
    state: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentLogin:
      return .none

      case .presentRoot:
        return .none

      case .presentMember:
        return .none

      case .presentStaff:
        return .none
    }
  }
}

extension ProfileCoordinator {
  @Reducer
  public enum ProfileScreen {
    case profile(ProfileFeature)
    case web(WebFeature)
    case onBoarding(OnBoardingCoordinator)
  }
}

extension ProfileCoordinator.ProfileScreen.State: Equatable {}
