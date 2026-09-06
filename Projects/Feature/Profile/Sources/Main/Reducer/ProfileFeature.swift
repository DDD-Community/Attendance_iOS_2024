//
//  ProfileFeature.swift
//  DDDAttendance
//
//  Created by DDD on 7/17/24.
//

import DDDCoreLogger
import Foundation

import AuthDomainInterface
import DDDSharedUI
import ProfileDomainInterface

import ComposableArchitecture
import DDDDesignKit
import ProfileInterface

@Reducer
public struct ProfileFeature: Sendable {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    /// 이 화면이 지금 무엇을 그려야 하는지.
    public enum ViewState: Equatable {
      case loading
      case loaded
    }

    var profile: ProfileEntity?

    /// 네트워크 갱신 전에는 앱 전역 세션의 마지막 프로필을 즉시 표시합니다.
    var displayedProfile: ProfileEntity? {
      if let profile {
        return profile
      }

      guard !userSession.name.isEmpty else {
        return nil
      }

      return ProfileEntity(
        userID: userSession.userID,
        name: userSession.name,
        generation: userSession.generation,
        team: userSession.selectTeam == .unknown ? nil : userSession.selectTeam,
        jobRole: userSession.selectPart,
        role: userSession.userRole,
        manger: userSession.managing.isEmpty ? nil : userSession.managing
      )
    }

    /// 캐시나 서버 프로필이 확정되기 전에는 빈 프로필 카드(`"님"`) 대신 스켈레톤을 그린다.
    var viewState: ViewState = .loading

    @Shared(.userSession) var userSession
    @Presents var destination: Destination.State?
    @Shared(.appStorage("editGeneration")) var editGeneration: Bool = false

    // 기존 TCA AlertState 유지 (다른 곳에서 사용)
    @Presents public var alert: AlertState<AlertAction>?

    // TCA 스타일 CustomAlert (확인팝업용)
    @Presents public var customAlert: CustomAlertState<CustomAlertAction>?

    public init() {}
  }

  @Reducer
  public enum Destination {
    case createApp(CreateAppFeature)
  }

  public enum Action: ViewAction {
    case destination(PresentationAction<Destination.Action>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case scope(ScopeAction)
    case delegate(DelegateAction)
  }

  // MARK: - View action

  @CasePathable
  public enum View {
    case appearModal
    case closeModal
    case showWithdrawAlert
    case showLogoutAlert
  }

  // MARK: - 비동기 처리 액션

  @CasePathable
  public enum AsyncAction: Equatable {
    case fetchUser
    case deleteUser
    case logout
  }

  // MARK: - 앱내에서 사용하는 액션

  @CasePathable
  public enum InnerAction: Equatable {
    case setLoading(Bool)
    case fetchUserResponse(Result<ProfileEntity, ProfileError>)
    case deleteUserResponse(Result<WithdrawEntity, AuthError>)
    case logoutResponses(Result<AuthExitEntity, AuthError>)
  }

  // MARK: - 네비게이션 연결 액션

  /// 이동 계약은 ProfileInterface 에 있다. 호출부를 그대로 두기 위해 별칭만 받는다.
  public typealias DelegateAction = ProfileDelegate

  @CasePathable
  public enum ScopeAction {
    case alert(PresentationAction<AlertAction>)
    case customAlert(PresentationAction<CustomAlertAction>)
  }

  @CasePathable
  public enum AlertAction {
    case confirmTapped
  }

  public nonisolated enum CancelID: Hashable, Sendable {
    case fetchProfile
    case deleteUser
    case logoutUser
  }

  @Dependency(\.authUseCase) var authUseCase
  @Dependency(\.profileUseCase) var profileUseCase
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.continuousClock) var clock

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case let .destination(destinationAction):
        return handleDestinationAction(state: &state, action: destinationAction)

      // MARK: - ViewAction

      case let .view(viewAction):
        return handleViewAction(state: &state, action: viewAction)

      // MARK: - AsyncAction

      case let .async(asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)

      // MARK: - InnerAction

      case let .inner(innerAction):
        return handleInnerAction(state: &state, action: innerAction)

      // MARK: - DelegateAction

      case let .delegate(delegateAction):
        return handleDelegateAction(state: &state, action: delegateAction)

      case let .scope(scopeAction):
        switch scopeAction {
        case .alert:
          return .none

        case let .customAlert(customAlertAction):
          return handleCustomAlertAction(state: &state, action: customAlertAction)
        }
      }
    }
    .ifLet(\.$destination, action: \.destination)
    .ifLet(\.$alert, action: \.scope.alert)
    .ifLet(\.$customAlert, action: \.scope.customAlert) {
      EmptyReducer()
    }
  }
}

extension ProfileFeature {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .appearModal:
      state.destination = .createApp(.init())
      return .none

    case .closeModal:
      state.destination = nil
      return .none

    case .showWithdrawAlert:
      state.customAlert = .withdrawAccount()
      return .none

    case .showLogoutAlert:
      state.customAlert = .logout()
      return .none
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .fetchUser:
      guard !state.editGeneration else {
        return .cancel(id: CancelID.fetchProfile)
      }

      return .run { send in
        do {
          // 캐시 hit → 즉시 표시 (로딩 X), 그 후 강제 refresh로 화면 자동 갱신
          if let cached = await profileUseCase.getCachedProfile() {
            await send(.inner(.fetchUserResponse(.success(cached))))
            let refreshed = await Result {
              try await profileUseCase.refreshProfile()
            }
            .mapError(ProfileError.from)
            await send(.inner(.fetchUserResponse(refreshed)))
            return
          }

          // 캐시 miss → 세션의 마지막 프로필을 표시한 채 네트워크 갱신
          await send(.inner(.setLoading(true)))
          let fetchUserResult = await Result {
            try await profileUseCase.getProfile()
          }
          .mapError(ProfileError.from)

          await send(.inner(.fetchUserResponse(fetchUserResult)))
        } catch is CancellationError {
          DDDLogger.info("ProfileFeature.fetchUser Effect가 취소됨", category: .network)
        }
      }
      .cancellable(id: CancelID.fetchProfile, cancelInFlight: true)

    case .deleteUser:
      return .run {
        [
          userSession = state.userSession
        ] send in
        let deleteUserResult = await Result {
          try await authUseCase.withDraw(token: userSession.accessToken)
        }
        .mapError(AuthError.from)
        return await send(.inner(.deleteUserResponse(deleteUserResult)))
      }
      .cancellable(id: CancelID.deleteUser, cancelInFlight: true)

    case .logout:
      return .run { send in
        let logoutResult = await Result {
          try await authUseCase.logout()
        }
        .mapError(AuthError.from)
        return await send(.inner(.logoutResponses(logoutResult)))
      }
      .cancellable(id: CancelID.logoutUser, cancelInFlight: true)
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case let .setLoading(value):
      guard value else {
        state.viewState = .loaded
        return .none
      }
      // 세션 폴백으로라도 보여줄 프로필이 있으면 스켈레톤으로 되돌리지 않는다.
      state.viewState = state.profile == nil ? .loading : .loaded
      return .none

    case let .fetchUserResponse(result):
      state.viewState = .loaded
      switch result {
      case let .success(profileDTOData):
        state.profile = profileDTOData

      case let .failure(error):
        DDDLogger.error("유저 정보 가져오기: \(error.localizedDescription)", category: .network)
      }
      return .none

    case let .deleteUserResponse(result):
      switch result {
      case let .success(data):
        if data.isSuccess {
          // 탈퇴 성공 시 UserSession의 이름 제거
          state.$userSession.withLock { $0.name = "" }
          return .send(.delegate(.presentLogOut))
        }
        return .none

      case let .failure(error):
        state.alert = AlertState {
          TextState("탈퇴실패")
        } actions: {
          ButtonState(action: .confirmTapped) {
            TextState("확인")
          }
        } message: {
          TextState("회원 탈퇴 실패: \(String(describing: error.errorDescription ?? error.localizedDescription))")
        }
        return .none
      }

    case let .logoutResponses(result):
      switch result {
      case .success:
        return .send(.delegate(.presentLogOut))

      case let .failure(error):
        state.alert = AlertState {
          TextState("로그 아웃 실패")
        } actions: {
          ButtonState(action: .confirmTapped) {
            TextState("확인")
          }
        } message: {
          TextState("로그 아웃 실패: \(String(describing: AuthError.unknownError(error.errorDescription ?? "")))")
        }
        return .none
      }
    }
  }

  private func handleDelegateAction(
    state: inout State,
    action: DelegateAction
  ) -> Effect<Action> {
    switch action {
    case .presentBack:
      return .none

    case .presentLogOut:
      return .none

    case .presentCreateByApp:
      return .none

    case .presentPrivacyPolicy:
      return .none

    case .presentEditGeneration:
      state.$editGeneration.withLock { $0 = true }
      return .cancel(id: CancelID.fetchProfile)

    case .presentAppPeedBackWeb:
      return .none
    }
  }

  private func handleCustomAlertAction(
    state: inout State,
    action: PresentationAction<CustomAlertAction>
  ) -> Effect<Action> {
    switch action {
    case let .presented(customAlertAction):
      switch customAlertAction {
      case .confirmTapped:
        // customAlert의 title로 구분하여 적절한 액션 실행
        guard let alertState = state.customAlert else { return .none }

        // 팝업 닫기
        state.customAlert = nil

        if alertState.title.contains("탈퇴") {
          return .send(.async(.deleteUser))
        } else if alertState.title.contains("로그아웃") {
          return .send(.async(.logout))
        }
        return .none

      case .cancelTapped:
        state.customAlert = nil
        return .none

      case .policyTapped:
        return .none
      }

    case .dismiss:
      return .none
    }
  }

  private func handleDestinationAction(
    state: inout State,
    action: PresentationAction<Destination.Action>
  ) -> Effect<Action> {
    switch action {
    case .presented(.createApp(.delegate(.presentBack))):
      state.destination = nil
      return .none

    case .presented(.createApp(.delegate(.presentWeb))):
      state.destination = nil
      return .run { send in
        try await clock.sleep(for: .seconds(0.05))
        await send(.delegate(.presentAppPeedBackWeb))
      }

    default:
      return .none
    }
  }
}

extension ProfileFeature.Destination.State: Equatable {}
