//
//  SelectTeamFeature.swift
//  Presentation
//
//  Created by DDD on 11/4/24.
//

import DDDCoreLogger
import Foundation

import AuthDomainInterface
import DDDCoreUtility
import OnBoardingDomainInterface
import ProfileDomainInterface

import ComposableArchitecture
import OnBoardingInterface

@Reducer
public struct SelectTeamFeature {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    public init() {}

    var activeButton = false
    var selectTeam: SelectTeams? = .unknown
    /// 이 화면이 지금 무엇을 그려야 하는지.
    public enum ViewState: Equatable {
      case loading
      case loaded
    }

    /// 첫 진입은 항상 fetch 로 시작한다. 빈 화면이 한 프레임 스쳐 지나가지 않도록 스켈레톤부터 그린다.

    var viewState = ViewState.loading
    var teams: IdentifiedArrayOf<SelectTeamEntity> = []


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

  @CasePathable
  public enum ScopeAction {
      case alert(PresentationAction<AlertAction>)
  }

  @CasePathable
  public enum AlertAction {
    case confirmTapped
  }

  // MARK: - ViewAction

  @CasePathable
  public enum View {
    case selectTeamButton(selectTeam: SelectTeamEntity)
    case onAppear
    case signUp
  }

  // MARK: - AsyncAction 비동기 처리 액션

  public enum AsyncAction: Equatable {
    case getTeams
    case signUpUser
    case editProfile
  }

  // MARK: - 앱내에서 사용하는 액션

  public enum InnerAction: Equatable {
    case teamListResponse(Result<[SelectTeamEntity], SignUpError>)
    case signUpUserResponse(Result<SignUpUser, SignUpError>)
    case editProfileResponse(Result<ProfileEntity, ProfileError>)
    case credentialRefreshFailed(ProfileEntity)
  }

  // MARK: - DelegateAction

  /// 이동 계약은 OnBoardingInterface 에 있다. 호출부를 그대로 두기 위해 별칭만 받는다.
  public typealias DelegateAction = SelectTeamDelegate

  nonisolated enum CancelID: Hashable {
    case selectTeam
    case signUpUser
    case editProfile
  }


  @Dependency(\.signUpUseCase) var signUpUseCase
  @Dependency(\.onBoardingUseCase) var onBoardingUseCase
  @Dependency(\.profileUseCase) var profileUseCase
  @Dependency(\.authUseCase) var authUseCase
  @Dependency(\.continuousClock) var clock

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .view(let viewAction):
        return handleViewAction(state: &state, action: viewAction)

      case .async(let asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)

      case .inner(let innerAction):
        return handleInnerAction(state: &state, action: innerAction)

      case .delegate(let delegateAction):
        return handleDelegateAction(state: &state, action: delegateAction)

        case .scope:
          return .none
      }
    }
    .ifLet(\.$alert, action: \.scope.alert)
  }
}

extension SelectTeamFeature {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .selectTeamButton(let selectTeams):
        let selectTeam = selectTeams.teams
        let teamId = selectTeams.teamId

        if state.selectTeam == selectTeam {
          // 동일한 파트 재선택 → 해제
          state.selectTeam = nil
          state.$userSession.withLock {
            $0.selectTeam = .unknown
            $0.selectTeamId = nil
          }
          state.activeButton = false
          return .none
        }

        state.selectTeam = selectTeam
        state.$userSession.withLock {
          $0.selectTeam = selectTeam
          $0.selectTeamId = teamId
        }

        state.activeButton = true
  //      DDDLogger.debug("selectPart: \(state.userEntity.role)", category: .auth)
        return .none

        case .onAppear:
          return .send(.async(.getTeams))
            .cancellable(id: CancelID.selectTeam, cancelInFlight: true)

      case .signUp:
        // Manager인 경우 회원가입 시 팀매니징 자동 추가
        if state.userSession.userRole == .manager {
          state.$userSession.withLock {
            if !$0.managing.contains(.teamManaging) {
              $0.managing.append(.teamManaging)
            }
          }
        }

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
    state: inout State,
    action: DelegateAction
  ) -> Effect<Action> {
    switch action {
    case .presentBack:
      return .none

    case .presentMember:
      return .none

    case .presentManager:
      return .none

      case .presentLogin:
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
      case .getTeams:
        state.viewState = .loading
        return .run {
          [userSession =  state.userSession]
          send in
          let teamResult = await Result {
            try await onBoardingUseCase.fetchTeams(generationId: userSession.generationId)
          }
            .mapError(SignUpError.from)
          return await send(.inner(.teamListResponse(teamResult)))

        }
        .cancellable(id: CancelID.selectTeam, cancelInFlight: true)
        .cancellable(id: "allAuthRelatedEffects")

      case .signUpUser:
        return .run { [
          userSession = state.userSession
        ] send in
          let signUpUserResult = await Result {
            return try await signUpUseCase.registerUser(userSession: userSession)
          }
          .mapError(SignUpError.from)
          return await send(.inner(.signUpUserResponse(signUpUserResult)))
        }


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
      case .teamListResponse(let result):
        switch result {
          case .success(let data):
            state.teams = .init(uniqueElements: data)
            state.viewState = .loaded
          case .failure(let error):
            state.viewState = .loaded
            DDDLogger.error("네트워크 에러: \(error.errorDescription ?? "알 수 없음")", category: .auth)
        }
        return .none

      case .signUpUserResponse(let result):
        switch result {
          case .success:
            state.$staffRole.withLock { $0 = state.userSession.userRole }

            if state.userSession.userRole == .manager {
              return .send(.delegate(.presentManager))
            } else {
              return .send(.delegate(.presentMember))
            }

          case .failure(let error):
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

      case .editProfileResponse(let result):
        switch result {
          case .success(let data):
            applyEditedProfile(data, to: &state)

            // 기수변경 완료 후 변경된 역할에 맞는 홈으로 이동 (운영진/멤버)
            if data.role == .manager {
              return .send(.delegate(.presentManager))
            } else {
              return .send(.delegate(.presentMember))
            }

          case .failure(let error):
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
