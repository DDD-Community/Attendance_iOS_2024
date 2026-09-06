//
//  InviteCodeFeature.swift
//  Presentation
//
//  Created by DDD on 11/2/24.
//

import DDDCoreLogger
import Foundation

import DDDCoreUtility
import OnBoardingDomainInterface

import ComposableArchitecture
import OnBoardingInterface

@Reducer
public struct InviteCodeFeature {
  public init() {}

  public enum FocusField: Hashable {
    case first
    case second
    case third
    case last
  }
  
  @ObservableState
  public struct State: Equatable {
    
    var firstInviteCode = ""
    var secondInviteCode = ""
    var thirdInviteCode = ""
    var lastInviteCode = ""
    var focusedField: FocusField? = .first

    @Shared(.userSession) var userSession
    @Presents public var alert: AlertState<AlertAction>?

    var totalInviteCode: String {
      return firstInviteCode + secondInviteCode + thirdInviteCode + lastInviteCode
    }
    var enableButton: Bool {
      return !isNotAvailableCode &&
      !firstInviteCode.isEmpty &&
      !secondInviteCode.isEmpty &&
      !thirdInviteCode.isEmpty &&
      !lastInviteCode.isEmpty
    }
    var isNotAvailableCode = false
    

    
    public init() { }
  }

  @CasePathable
  public enum Action: ViewAction, BindableAction {
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case scope(ScopeAction)
    case delegate(DelegateAction)
  }
  
  // MARK: - ViewAction
  
  @CasePathable
  public enum View {
    case initInviteCode
    case focusChanged(FocusField?)
  }
  
  // MARK: - AsyncAction 비동기 처리 액션
  @CasePathable
  public enum AsyncAction: Equatable {
    case verifyInviteCode(code: String)
  }
  
  // MARK: - 앱내에서 사용하는 액션
  @CasePathable
  public enum InnerAction: Equatable {
    case verifyInviteCodeResponse(Result<VerifyCodeEntity, SignUpError>)
  }
  
  // MARK: - DelegateAction
  /// 이동 계약은 OnBoardingInterface 에 있다. 호출부를 그대로 두기 위해 별칭만 받는다.
  public typealias DelegateAction = InviteCodeDelegate

  @CasePathable
  public enum ScopeAction {
      case alert(PresentationAction<AlertAction>)
  }

  @CasePathable
  public enum AlertAction {
      case confirmTapped
  }

  nonisolated enum CancelID: Hashable {
    case verifyCode
  }


  

  @Dependency(\.onBoardingUseCase) var onBoardingUseCase
  @Dependency(\.continuousClock) var clock
  @Dependency(\.mainQueue) var mainQueue
  
  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none
        
      case .view(let viewAction):
        return handleViewAction(state: &state, action: viewAction)
        
      case .async(let asyncAction):
        return handleAsyncAction(state: &state, action: asyncAction)
        
      case .inner(let innerAction):
        return handleInnerAction(state: &state, action: innerAction)

        case .scope:
          return .none

      case .delegate(let delegateAction):
        return handleDelegateAction(state: &state, action: delegateAction)
      }
    }
    .ifLet(\.$alert, action: \.scope.alert)
  }
}

extension InviteCodeFeature {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .initInviteCode:
      state.firstInviteCode = ""
      state.secondInviteCode = ""
      state.thirdInviteCode = ""
      state.lastInviteCode = ""
      state.focusedField = .first
      return .none
    case .focusChanged(let field):
      state.focusedField = field
      return .none
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .verifyInviteCode(let code):
      return .run { send in
        let verifyCodeResult = await Result {
          try await onBoardingUseCase.verifyCode(code: code)
        }
          .mapError(SignUpError.from)
        return await send(.inner(.verifyInviteCodeResponse(verifyCodeResult)))

      }
      .cancellable(id: CancelID.verifyCode, cancelInFlight: true)
    }
  }

  private func handleDelegateAction(
    state: inout State,
    action: DelegateAction
  ) -> Effect<Action> {
    switch action {
    case .presentBack:
      return .none

    case .presentSignUpName:
      return .none
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case .verifyInviteCodeResponse(let result):
      switch result {
      case .success(let data):
        state.isNotAvailableCode = false
        let inviteCode = state.totalInviteCode
        state.$userSession.withLock {
          $0.userRole = data.type
          $0.generationId = data.generationID
          $0.inviteCode = inviteCode
          $0.managing = []
          $0.selectTeam = .unknown
          $0.selectTeamId = nil
        }
        return .send(.delegate(.presentSignUpName))

      case .failure(let error):
        DDDLogger.error("코드에러: \(error)", category: .auth)
        state.isNotAvailableCode = true
        state.alert = AlertState {
          TextState("오류")
        } actions: {
          ButtonState(action: .confirmTapped) {
            TextState("확인")
          }
        } message: {
          TextState("잘못된 초대 코드입니다. 다시 입력해 주세요.\n\(SignUpError.invalidInviteCode.errorDescription ?? "")")
        }
      }
      return .none
    }
  }
}
