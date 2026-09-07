//
//  AppReducer.swift
//  DDDAttendance
//
//  Created by DDD on 10/29/24.
//

import Foundation

import DDDAuthInterface
import DDDCoreUtility
import FeatureAssembly

import ComposableArchitecture

@Reducer
public struct AppReducer: Sendable {
  public init() {}

  @ObservableState
  public enum State {
    case splash(SplashFeature.State)
    case auth(AuthCoordinator.State)
    case staff(StaffCoordinator.State)
    case member(MemberCoordinator.State)

    public init() {
      self = .splash(SplashFeature.State())
    }

    // Animation identifier for SwiftUI transitions
    var animationID: String {
      switch self {
      case .splash: return "splash"
      case .auth: return "auth"
      case .staff: return "staff"
      case .member: return "member"
      }
    }
  }

  //MARK: - Action
  public enum Action: ViewAction {
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case scope(ScopeAction)
  }

  @CasePathable
  public enum View {
    case presentAuth
    case presentStaff
    case presentMember
  }

  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    case completeAuthTransition
    case completeStaffTransition
    case completeMemberTransition
  }

  //MARK: - 비동기 처리 액션
  public enum AsyncAction: Equatable {
    case startNotificationListener
    case refreshTokenExpired
  }

  //MARK: - 스코프 액션
  @CasePathable
  public enum ScopeAction {
    case splash(SplashFeature.Action)
    case auth(AuthCoordinator.Action)
    case staff(StaffCoordinator.Action)
    case member(MemberCoordinator.Action)
  }

  @Dependency(\.continuousClock) var clock

  private enum CancelID: Hashable {
    case transition
    case refreshTokenListener
  }

  /// 화면 전환 전에 각 Coordinator 의 장기 Effect 를 모두 취소한다.
  private func cancelAllCoordinatorEffects() -> Effect<Action> {
    return .merge([
      .cancel(id: StaffCoordinator.CancelID.allEffects),
      .cancel(id: StaffCoordinator.CancelID.profileEffects),
      .cancel(id: MemberCoordinator.CancelID.allEffects),
      .cancel(id: MemberCoordinator.CancelID.profileEffects),

      .cancel(id: ProfileFeature.CancelID.fetchProfile),
      .cancel(id: ProfileFeature.CancelID.deleteUser),
      .cancel(id: ProfileFeature.CancelID.logoutUser)
    ])
  }

  /// 상태를 바꾸기 전에 진행 중인 Effect 취소를 먼저 끝낸다.
  private func startTransition(_ action: InnerAction) -> Effect<Action> {
    .concatenate(
      cancelAllCoordinatorEffects(),
      .run { _ in await Task.yield() },
      .send(.inner(action))
    )
    .cancellable(id: CancelID.transition, cancelInFlight: true)
  }

  public var body: some ReducerOf<Self> {
    // ifCaseLet 은 base 를 감싸는 연산자라 배치 순서와 무관하게 자식이 먼저 실행된다.
    // (IfCaseLetReducer._reduce: reduceChild → parent._reduce 순서)
    // 따라서 아래 필터는 자식이 이미 처리한 뒤에 돈다. 경고 차단 용도가 아니다.
    Reduce { state, action in
      switch action {
      case .view(let viewAction):
        return handleViewAction(viewAction)

      case .inner(let innerAction):
        return handleInnerAction(state: &state, action: innerAction)

      case .async(let asyncAction):
        return handleAsyncAction(asyncAction)

      case .scope(let scopeAction):
        return handleScopeAction(state: &state, action: scopeAction)
      }
    }
    // 상태 불일치 방어 기능은 없다. 자식 상태가 다른 케이스면 여기서 경고가 발생한다.
    .ifCaseLet(\.splash, action: \.scope.splash) {
      SplashFeature()
    }
    .ifCaseLet(\.auth, action: \.scope.auth) {
      AuthCoordinator()
    }
    .ifCaseLet(\.staff, action: \.scope.staff) {
      StaffCoordinator()
    }
    .ifCaseLet(\.member, action: \.scope.member) {
      MemberCoordinator()
    }
  }

  private func handleViewAction(_ action: View) -> Effect<Action> {
    switch action {
    case .presentAuth:
      return startTransition(.completeAuthTransition)

    case .presentStaff:
      return startTransition(.completeStaffTransition)

    case .presentMember:
      return startTransition(.completeMemberTransition)
    }
  }

  private func handleAsyncAction(_ action: AsyncAction) -> Effect<Action> {
    switch action {
    case .startNotificationListener:
      return setupRefreshTokenExpiredListener()

    case .refreshTokenExpired:
      return startTransition(.completeAuthTransition)
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case .completeAuthTransition:
      state = .auth(.init())
      return .none

    case .completeStaffTransition:
      state = .staff(.init())
      return .none

    case .completeMemberTransition:
      state = .member(.init())
      return .none
    }
  }

  private func handleScopeAction(
    state: inout State,
    action: ScopeAction
  ) -> Effect<Action> {
    // 현재 화면과 다른 Coordinator 의 액션은 조용히 무시한다.
    switch (action, state) {
    case (.staff, .staff), (.member, .member), (.auth, .auth), (.splash, .splash):
      return handleScopeNavigation(action: action)
    default:
      return .none
    }
  }

  private func handleScopeNavigation(action: ScopeAction) -> Effect<Action> {
    switch action {
    case .splash(.delegate(.presentLogin)):
      return .run { send in
        try await clock.sleep(for: .seconds(0.5))
        await send(.view(.presentAuth))
      }
      .cancellable(id: CancelID.transition, cancelInFlight: true)

    case .splash(.delegate(.presentStaff)):
      return .send(.view(.presentStaff))

    case .splash(.delegate(.presentMember)):
      return .send(.view(.presentMember))

    case .auth(.navigation(.presentStaff)):
      return .send(.view(.presentStaff))

    case .auth(.navigation(.presentMember)):
      return .send(.view(.presentMember))

    case .staff(.navigation(.presentLogin)):
      return .send(.view(.presentAuth))

    case .staff(.navigation(.presentMember)):
      return .send(.view(.presentMember))

    case .member(.navigation(.presentLogin)):
      return .send(.view(.presentAuth))

    case .member(.navigation(.presentStaff)):
      return .send(.view(.presentStaff))

    default:
      return .none
    }
  }


  private func setupRefreshTokenExpiredListener() -> Effect<Action> {
    return .publisher {
      NotificationCenter.default
        .publisher(for: .dddAuthSessionDidExpire)
        .map { _ in Action.async(.refreshTokenExpired) }
    }
    .cancellable(id: CancelID.refreshTokenListener, cancelInFlight: true)
  }
}
