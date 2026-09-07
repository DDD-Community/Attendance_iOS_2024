//
//  OnBoardingCoordinator.swift
//  OnBoarding
//
//  Created by DDD on 1/6/26.
//

import Foundation

import DDDSharedUI
import OnBoarding

import ComposableArchitecture
import TCAFlow

@FlowCoordinator(screen: "OnBoardingScreen", navigation: true)
public struct OnBoardingCoordinator {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var routes: [Route<OnBoardingScreen.State>]

    public init() {
      routes = [.root(.InviteCode(.init()), embedInNavigationView: true)]
    }
  }

  @CasePathable
  public enum Action {
    case router(IndexedRouterActionOf<OnBoardingScreen>)
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

  public enum AsyncAction: Equatable {}

  public enum InnerAction: Equatable {}

  public enum NavigationAction: Equatable {
    case backToRoot
    case presentLogin
    case presentStaff
    case presentMember
    case presentProfile
  }

  func handleRoute(state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case let .router(routeAction):
      return routerAction(state: &state, action: routeAction)

    case let .view(viewAction):
      return handleViewAction(state: &state, action: viewAction)

    case let .inner(innerAction):
      return handleInnerAction(state: &state, action: innerAction)

    case let .async(asyncAction):
      return handleAsyncAction(state: &state, action: asyncAction)

    case let .navigation(navigationAction):
      return handleNavigationAction(state: &state, action: navigationAction)
    }
  }
}

extension OnBoardingCoordinator {
  private func routerAction(
    state: inout State,
    action: IndexedRouterActionOf<OnBoardingScreen>
  ) -> Effect<Action> {
    switch action {
    case .routeAction(id: _, action: .InviteCode(.delegate(.presentBack))):
      return .send(.navigation(.backToRoot))

    case .routeAction(id: _, action: .onBoardingName(.delegate(.presentBack))),
         .routeAction(id: _, action: .selectPart(.delegate(.presentBack))),
         .routeAction(id: _, action: .selectManaging(.delegate(.presentBack))),
         .routeAction(id: _, action: .selectTeam(.delegate(.presentBack))):
      state.routes.goBack()
      return .none

    // MARK: - 이름 입력

    case .routeAction(id: _, action: .InviteCode(.delegate(.presentSignUpName))):
      state.routes.push(.onBoardingName(.init()))
      return .none

    case .routeAction(id: _, action: .onBoardingName(.delegate(.presentSignUpPart))):
      state.routes.push(.selectPart(.init()))
      return .none

        // MARK: - 운영진 담당업무 선택

    case .routeAction(id: _, action: .selectPart(.delegate(.presentManaging))):
      state.routes.push(.selectManaging(.init()))
      return .none

    // MARK: -  운영진 매니징 업무선택시  팀매니징 선택시 팀선택

    case .routeAction(id: _, action: .selectManaging(.delegate(.presentSelectTeam))):
      state.routes.push(.selectTeam(.init()))
      return .none

    case .routeAction(id: _, action: .selectManaging(.delegate(.presentManager))):
      return .send(.navigation(.presentStaff))

    case .routeAction(id: _, action: .selectManaging(.delegate(.presentMember))):
      return .send(.navigation(.presentMember))

    case .routeAction(id: _, action: .selectManaging(.delegate(.presentLogin))):
      return .send(.navigation(.presentLogin))

    case .routeAction(id: _, action: .selectManaging(.delegate(.presentProfile))):
      return .send(.navigation(.presentProfile))

    case .routeAction(id: _, action: .selectTeam(.delegate(.presentManager))):
      return .send(.navigation(.presentStaff))

    // MARK: - 멤버 선택 할팀 선택

    case .routeAction(id: _, action: .selectPart(.delegate(.presentSelectTeam))):
      state.routes.push(.selectTeam(.init()))
      return .none

    case .routeAction(id: _, action: .selectTeam(.delegate(.presentMember))):
      return .send(.navigation(.presentMember))

    case .routeAction(id: _, action: .selectTeam(.delegate(.presentLogin))):
      return .send(.navigation(.presentLogin))

    case .routeAction(id: _, action: .selectTeam(.delegate(.presentProfile))):
      return .send(.navigation(.presentProfile))

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

  private func handleInnerAction(
    state _: inout State,
    action _: InnerAction
  ) -> Effect<Action> {
    return .none
  }

  private func handleAsyncAction(
    state _: inout State,
    action _: AsyncAction
  ) -> Effect<Action> {
    return .none
  }

  private func handleNavigationAction(
    state _: inout State,
    action: NavigationAction
  ) -> Effect<Action> {
    switch action {
    case .presentStaff:
      return .none

    case .presentMember:
      return .none

    case .presentLogin:
      return .none

    case .backToRoot:
      return .none

    case .presentProfile:
      return .none
    }
  }
}

// swiftformat:disable:next extensionAccessControl
extension OnBoardingCoordinator {
  // @Reducer enum 매크로는 enum 자체에 public이 있어야 State/Action을 public으로 생성함.
  // swiftformat의 extensionAccessControl이 public을 extension으로 끌어올리면 매크로가 깨지므로 고정.
  @Reducer
  public enum OnBoardingScreen {
    case InviteCode(InviteCodeFeature)
    case onBoardingName(OnBoardingNameFeature)
    case selectPart(SelectPartFeature)
    case selectManaging(SelectManagingFeature)
    case selectTeam(SelectTeamFeature)
  }
}

extension OnBoardingCoordinator.OnBoardingScreen.State: Equatable {}
