//
//  SelectManagingFeature.swift
//  OnBoarding
//
//  Created by DDD on 9/4/26.
//

import Foundation

import AuthDomainInterface
import OnBoardingDomainInterface
import ProfileDomainInterface
import DDDCoreUtility

import ComposableArchitecture
import OnBoardingInterface

@Reducer
public struct SelectManagingFeature {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    public init() {}

    /// 이 화면이 지금 무엇을 그려야 하는지.
    public enum ViewState: Equatable {
      case loading
      case loaded
    }

    /// 첫 진입은 항상 fetch 로 시작한다. 빈 화면이 한 프레임 스쳐 지나가지 않도록 스켈레톤부터 그린다.

    var viewState = ViewState.loading
    var managers: IdentifiedArrayOf<SelectManaging> = []

    @Shared(.userSession) var userSession
    @Shared(.appStorage("editGeneration")) var editGeneration: Bool = false
    @Shared(.staffRole) var staffRole
    @Presents var alert: AlertState<AlertAction>?
  }

  public enum Action: ViewAction, BindableAction {
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case delegate(DelegateAction)
    case scope(ScopeAction)
  }

  // MARK: - ViewAction

  @CasePathable
  public enum View {
    case onAppear
    case selectManagingButton(selectManaging: SelectManaging)
    case signUp
  }

  @CasePathable
  public enum ScopeAction {
    case alert(PresentationAction<AlertAction>)
  }

  @CasePathable
  public enum AlertAction {
    case confirmTapped
  }

  // MARK: - AsyncAction 비동기 처리 액션

  public enum AsyncAction: Equatable {
    case fetchMangerList
    case signUpUser
    case editProfile
  }

  // MARK: - 앱내에서 사용하는 액션

  public enum InnerAction: Equatable {
    case mangerListResponse(Result<[SelectManaging], SignUpError>)
    case signUpUserResponse(Result<SignUpUser, SignUpError>)
    case editProfileResponse(Result<ProfileEntity, ProfileError>)
    case credentialRefreshFailed(ProfileEntity)
  }

  // MARK: - DelegateAction

  /// 이동 계약은 OnBoardingInterface 에 있다. 호출부를 그대로 두기 위해 별칭만 받는다.
  public typealias DelegateAction = SelectManagingDelegate

  nonisolated enum CancelID: Hashable, CaseIterable {
    case fetchMangerList
    case signUpUser
    case editProfile
  }

  @Dependency(\.onBoardingUseCase) var onBoardingUseCase
  @Dependency(\.signUpUseCase) var signUpUseCase
  @Dependency(\.profileUseCase) var profileUseCase
  @Dependency(\.authUseCase) var authUseCase
  @Dependency(\.continuousClock) var clock
  @Dependency(\.mainQueue) var mainQueue

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

      case .scope:
        return .none
      }
    }
    .ifLet(\.$alert, action: \.scope.alert)
  }
}

extension SelectManagingFeature {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .onAppear:
      // 이미 데이터가 있다면 다시 fetch하지 않음
      if !state.managers.isEmpty {
        return .none
      }
      return .send(.async(.fetchMangerList))

    case let .selectManagingButton(selectManaging):
      let selectedManaging = selectManaging.managing

      state.$userSession.withLock {
        var current = $0.managing
        if let index = current.firstIndex(of: selectedManaging) {
          current.remove(at: index)
        } else {
          current.append(selectedManaging)
        }
        $0.managing = current
      }

      return .none

    case .signUp:
      return .run { [
        editGeneration = state.editGeneration
      ] send in
        if editGeneration == true {
          await send(.async(.editProfile))
        } else {
          await send(.async(.signUpUser))
        }
      }
    }
  }

  private func handleDelegateAction(
    state _: inout State,
    action: DelegateAction
  ) -> Effect<Action> {
    // 모든 navigation에서 진행 중인 effect를 cancel
//    let cancelEffects = Effect<Action>.merge(
//      CancelID.allCases.map { .cancel(id: $0) }
//    )

    switch action {
    case .presentBack:
      return .none

    case .presentManager:
      return .none

    case .presentMember:
      return .none

    case .presentLogin:
      return .none

    case .presentSelectTeam:
      return .none

    case .presentProfile:
      return .none
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .fetchMangerList:
      state.viewState = .loading
      return .run { send in
        let mangerResult = await Result {
          try await onBoardingUseCase.fetchManaging()
        }
        .mapError(SignUpError.from)
        return await send(.inner(.mangerListResponse(mangerResult)))
      }
      .cancellable(id: CancelID.fetchMangerList, cancelInFlight: true)

    case .signUpUser:
      return .run { [
        userSession = state.userSession
      ] send in
        let signUpUserResult = await Result {
          try await signUpUseCase.registerUser(userSession: userSession)
        }
        .mapError(SignUpError.from)
        return await send(.inner(.signUpUserResponse(signUpUserResult)))
      }
      .cancellable(id: CancelID.signUpUser, cancelInFlight: true)

    case .editProfile:
      return .run { [
        userSession = state.userSession
      ] send in
        do {
          let profile = try await profileUseCase.editProfile(
            input: EditProfileInput(userSession: userSession)
          )
          do {
            let tokens = try await authUseCase.refresh()
            await authUseCase.updateSessionCredential(with: tokens)
            await send(.inner(.editProfileResponse(.success(profile))))
          } catch {
            await send(.inner(.credentialRefreshFailed(profile)))
          }
        } catch {
          await send(.inner(.editProfileResponse(.failure(ProfileError.from(error)))))
        }
      }
      .cancellable(id: CancelID.editProfile, cancelInFlight: true)
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case let .mangerListResponse(result):
      switch result {
      case let .success(data):
        state.viewState = .loaded
        state.managers = .init(uniqueElements: data)

      case .failure:
        state.viewState = .loaded
      }
      return .none

    case let .signUpUserResponse(result):
      switch result {
      case .success:
        state.$staffRole.withLock { $0 = state.userSession.userRole }

        return .send(.delegate(.presentManager))

      case let .failure(error):
        state.alert = AlertState {
          TextState("회원가입 실패")
        } actions: {
          ButtonState(action: .confirmTapped) {
            TextState("확인")
          }
        } message: {
          TextState(error.errorDescription ?? "알 수 없는 오류가 발생했습니다.")
        }
        return .none
      }

    case let .editProfileResponse(result):
      switch result {
      case let .success(data):
        applyEditedProfile(data, to: &state)

        if data.role == .manager {
          return .send(.delegate(.presentManager))
        } else {
          return .send(.delegate(.presentMember))
        }

      case let .failure(error):
        state.$editGeneration.withLock { $0 = false }
        state.alert = AlertState {
          TextState("프로필 수정 실패")
        } actions: {
          ButtonState(action: .confirmTapped) {
            TextState("확인")
          }
        } message: {
          TextState(error.errorDescription ?? "알 수 없는 오류가 발생했습니다.")
        }
        return .none
      }

    case let .credentialRefreshFailed(profile):
      applyEditedProfile(profile, to: &state)
      return .send(.delegate(.presentLogin))
    }
  }

  private func applyEditedProfile(
    _ profile: ProfileEntity,
    to state: inout State
  ) {
    state.$editGeneration.withLock { $0 = false }
    state.$staffRole.withLock { $0 = profile.role }
    state.$userSession.withLock {
      $0.userID = profile.userID
      $0.name = profile.name
      $0.generation = profile.generation
      $0.selectTeam = profile.team ?? .unknown
      $0.selectPart = profile.jobRole
      $0.userRole = profile.role
      $0.managing = profile.manger ?? []
    }
  }
}

private extension EditProfileInput {
  init(userSession: UserSession) {
    self.init(
      name: userSession.name,
      generationId: userSession.generationId,
      jobRole: userSession.selectPart,
      teamId: userSession.selectTeamId,
      managerRoles: userSession.userRole == .manager ? userSession.managing : nil,
      inviteCode: userSession.inviteCode
    )
  }
}
