//
//  SplashFeature.swift
//  DDDAttendance
//
//  Created by DDD on 10/29/24.
//

import DDDCoreLogger
import Foundation
import FeatureAssembly

import DDDSharedUI

@Reducer
public struct SplashFeature: Sendable {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    @Shared(.staffRole) var staffRole
    
    // 앱 업데이트 관련
    @Presents var customAlert: CustomAlertState<CustomAlertAction>?
    var appStoreURL: String = ""
    var isUpdateCheckCompleted: Bool = false
    var isProfileFetchCompleted: Bool = false
    
    public init() {}
  }
  
  public enum Action: ViewAction, BindableAction {
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case delegate(DelegateAction)
    case scope(ScopeAction)
    
    @CasePathable
    public enum ScopeAction {
      case alert(PresentationAction<AlertAction>)
      case customAlert(PresentationAction<CustomAlertAction>)
    }
  }
  
  public enum AlertAction: Equatable {
    // 필요시 추가
  }
  
  // MARK: - ViewAction
  
  @CasePathable
  public enum View {
    case onAppear
  }
  
  // MARK: - AsyncAction 비동기 처리 액션
  
  public enum AsyncAction: Equatable {
    case fetchUser
    case checkAppUpdate
  }
  
  // MARK: - 앱내에서 사용하는 액션
  
  public enum InnerAction: Equatable {
    case fetchUserResponse(Result<ProfileEntity, ProfileError>)
    case checkAppUpdateResponse(Result<AppUpdateInfo?, AppUpdateError>)
  }
  
  // MARK: - DelegateAction
  
  @CasePathable
  public enum DelegateAction: Equatable, Sendable {
    case presentLogin
    case presentStaff
    case presentMember
  }
  
  nonisolated enum CancelID: Hashable {
    case fetchProfile
    case checkAppUpdate
  }
  
  @Dependency(\.continuousClock) var clock
  @Dependency(\.profileUseCase) var profileUseCase
  @Dependency(\.appUpdateUseCase) var appUpdateUseCase
  @Dependency(\.openURL) var openURL
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.authService) var authService
  
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
        
      case .scope(.customAlert(.presented(.confirmTapped))):
        // 앱스토어로 이동
        return .run { [appStoreURL = state.appStoreURL] _ in
          if let url = URL(string: appStoreURL) {
            await openURL(url)
          }
        }
        
      case .scope(.customAlert(.presented(.cancelTapped))):
        // "나중에 할게요" 선택 시 팝업을 닫고 화면 이동
        state.customAlert = nil
        if state.isProfileFetchCompleted {
          return navigateToNextScreen(state: &state)
        }
        return .none
        
      case .scope:
        return .none
      }
    }
    .ifLet(\.$customAlert, action: \.scope.customAlert) {
      EmptyReducer()
    }
  }
}

extension SplashFeature {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .onAppear:
      let staffRole = state.staffRole
      return .run { send in
        // 먼저 딜레이를 주고
        try await clock.sleep(for: .seconds(0.5))
        
        // 앱 업데이트 체크 (백그라운드에서)
        await send(.async(.checkAppUpdate))
        
        if staffRole == .manager {
          DDDLogger.debug("👔 [Splash] Redirecting to staff", category: .app)
          await send(.async(.fetchUser))
        } else if staffRole == .member {
          DDDLogger.debug("👤 [Splash] Redirecting to member", category: .app)
          await send(.async(.fetchUser))
        } else {
          DDDLogger.debug("❓ [Splash] No staff role - redirecting to login", category: .app)
          await send(.delegate(.presentLogin))
        }
      }
      .cancellable(id: CancelID.fetchProfile, cancelInFlight: true)
    }
  }
  
  private func handleAsyncAction(
    state _: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .fetchUser:
      return .run { send in
        let fetchUserResult = await Result {
          try await profileUseCase.getProfile()
        }
          .mapError(ProfileError.from)
        try await clock.sleep(for: .seconds(1))
        return await send(.inner(.fetchUserResponse(fetchUserResult)))
      }
      .cancellable(id: CancelID.fetchProfile, cancelInFlight: true)
      
    case .checkAppUpdate:
      return .run { send in
        let updateResult = await Result {
          try await appUpdateUseCase.checkForUpdate()
        }
          .mapError(AppUpdateError.from)
        await send(.inner(.checkAppUpdateResponse(updateResult)))
      }
      .cancellable(id: CancelID.checkAppUpdate, cancelInFlight: true)
    }
  }
  
  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case let .fetchUserResponse(result):
      switch result {
      case .success:
        DDDLogger.debug("[Splash] User profile fetched successfully", category: .app)
        state.isProfileFetchCompleted = true
        
        // 업데이트 체크가 완료되고 팝업이 없는 경우에만 화면 이동
        if state.isUpdateCheckCompleted && state.customAlert == nil {
          return navigateToNextScreen(state: &state)
        }
        
        return .none
        
      case let .failure(error):
        DDDLogger.error("❌ [Splash] Failed to fetch user profile: \(error.localizedDescription)", category: .app)
        
        // 토큰 만료나 인증 에러의 경우 로그인으로 이동
        // 다른 네트워크 에러의 경우에도 안전하게 로그인으로 이동
        return .run { send in
          await authService.signOut()
          await send(.delegate(.presentLogin))
        }
      }
      
    case let .checkAppUpdateResponse(result):
      state.isUpdateCheckCompleted = true
      
      switch result {
      case let .success(updateInfo):
        // 업데이트가 필요한 경우에만 Alert 표시
        if let updateInfo = updateInfo {
          DDDLogger.debug("[Splash] App update available: \(updateInfo.latestVersion)", category: .app)
          state.appStoreURL = updateInfo.appStoreUrl
          

          
          let message = "새로운 버전 \(updateInfo.displayVersion)이 출시되었습니다!\n\n더 나은 경험을 위해 지금 업데이트하세요!"
          
          state.customAlert = .alert(
            title: "새로운 버전이 출시되었어요!",
            message: message,
            confirmTitle: "지금 업데이트",
            cancelTitle: "나중에 할게요",
            isDestructive: false
          )
        } else {
          DDDLogger.debug("[Splash] App is up to date", category: .app)
          
          // 업데이트가 없고 프로필 fetch가 완료되었다면 화면 이동
          if state.isProfileFetchCompleted {
            return navigateToNextScreen(state: &state)
          }
        }
        return .none
        
      case let .failure(error):
        DDDLogger.error("[Splash] Failed to check app update: \(error.localizedDescription)", category: .app)
        
        // 에러가 발생해도 프로필 fetch가 완료되었다면 화면 이동
        if state.isProfileFetchCompleted {
          return navigateToNextScreen(state: &state)
        }
        return .none
      }
    }
  }
  
  private func handleDelegateAction(
    state _: inout State,
    action: DelegateAction
  ) -> Effect<Action> {
    switch action {
    case .presentLogin:
      return .none
      
    case .presentStaff:
      return .none
      
    case .presentMember:
      return .none
    }
  }
  
  private func navigateToNextScreen(state: inout State) -> Effect<Action> {
    let staffRole = state.staffRole
    
    if staffRole == .manager {
      DDDLogger.debug("[Splash] Navigation to staff after checks completed", category: .app)
      return .send(.delegate(.presentStaff))
    } else if staffRole == .member {
      DDDLogger.debug("[Splash] Navigation to member after checks completed", category: .app)
      return .send(.delegate(.presentMember))
    } else {
      DDDLogger.debug("[Splash] No staff role after checks completed - redirecting to login", category: .app)
      return .send(.delegate(.presentLogin))
    }
  }
  
}
