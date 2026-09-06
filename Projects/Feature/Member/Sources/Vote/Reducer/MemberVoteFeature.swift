//
//  MemberVoteFeature.swift
//  Member
//
//  Created by DDD on 6/11/26.
//

import DDDCoreLogger
import ComposableArchitecture
import DDDDesignKit
import Foundation
import MemberInterface
import VoteDomainInterface

/// [멤버] 투표 참여 플로우 리듀서.
/// 진행 중 투표 조회 → 템플릿 로드 → 1단계(팀 선택) → 2단계(피드백) → 제출.
@Reducer
public struct MemberVoteFeature {
  public init() {}

  /// 투표 탭의 화면 단계.
  public enum Step: Equatable {
    case loading
    case empty // 진행 중인 투표 없음
    case alreadyVoted // 이미 참여 완료
    case teamSelect // 1단계: 팀 선택
    case feedback // 2단계: 피드백
    case completed // 방금 제출 완료
  }

  @ObservableState
  public struct State: Equatable {
    var step: Step = .loading
    var voteId: Int?
    var teamTemplate: TeamVoteTemplateInfo?
    var feedbackTemplate: FeedbackTemplateInfo?
    var teamAnswers: [TeamVoteAnswer] = []
    var submitting: Bool = false
    @Presents public var exitAlert: CustomAlertState<CustomAlertAction>?
    @Presents public var alert: AlertState<AlertAction>?
    public init() {}
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
  public enum View {
    case onAppear
    case requestExit
    case teamSelectNext([TeamVoteAnswer])
    case backToTeamSelect
    case submitFeedback([FeedbackAnswer])
  }

  @CasePathable
  public enum ScopeAction {
    case exitAlert(PresentationAction<CustomAlertAction>)
    case alert(PresentationAction<AlertAction>)
  }

  @CasePathable
  public enum AlertAction: Equatable {
    case cancel
    case retry(AsyncAction)
  }

  public enum AsyncAction: Equatable {
    case fetchActiveVote
    case fetchTemplates(voteId: Int)
    case submit(VoteSubmission)
  }

  public enum InnerAction: Equatable {
    case activeVoteResponse(Result<ActiveVote, VoteError>)
    case templatesResponse(Result<Templates, VoteError>)
    case submitResponse(Result<Bool, VoteError>)
  }

  public typealias DelegateAction = MemberVoteDelegate

  /// 1·2단계 템플릿을 한 번에 로드한 결과.
  public struct Templates: Equatable, Sendable {
    let team: TeamVoteTemplateInfo
    let feedback: FeedbackTemplateInfo
  }

  nonisolated enum CancelID: Hashable {
    case fetchActiveVote
    case fetchTemplates
    case submit
  }

  @Dependency(\.voteUseCase) var voteUseCase

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

      case .delegate:
        return .none

      case let .scope(scopeAction):
        switch scopeAction {
        case let .exitAlert(exitAlertAction):
          return handleExitAlertAction(state: &state, action: exitAlertAction)

        case let .alert(alertAction):
          guard case let .presented(.retry(retryAction)) = alertAction else { return .none }
          return .send(.async(retryAction))
        }
      }
    }
    .ifLet(\.$exitAlert, action: \.scope.exitAlert) {
      CustomConfirmAlert()
    }
    .ifLet(\.$alert, action: \.scope.alert)
  }
}

extension MemberVoteFeature {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .onAppear:
      // 이미 로드된 단계면 다시 조회하지 않는다.
      guard state.step == .loading else { return .none }
      return .send(.async(.fetchActiveVote))

    case .requestExit:
      guard state.step == .teamSelect || state.step == .feedback else {
        return state.step == .loading ? .send(.delegate(.exitVote)) : .none
      }
      state.exitAlert = .exitWriting()
      return .none

    case let .teamSelectNext(answers):
      state.teamAnswers = answers
      state.step = .feedback
      return .none

    case .backToTeamSelect:
      guard state.step == .feedback else { return .none }
      state.step = .teamSelect
      return .none

    case let .submitFeedback(feedbackAnswers):
      guard !state.submitting else { return .none }
      let submission = VoteSubmission(
        teamVote: state.teamAnswers,
        feedback: feedbackAnswers
      )
      return .send(.async(.submit(submission)))
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .fetchActiveVote:
      state.step = .loading
      return .run { send in
        let result = await Result {
          try await voteUseCase.fetchActiveVote()
        }
        .mapError(VoteError.from)
        await send(.inner(.activeVoteResponse(result)))
      }
      .cancellable(id: CancelID.fetchActiveVote, cancelInFlight: true)

    case let .fetchTemplates(voteId):
      return .run { send in
        let result = await Result { () -> Templates in
          async let team = voteUseCase.fetchTeamVoteTemplate(voteId: voteId)
          async let feedback = voteUseCase.fetchFeedbackTemplate(voteId: voteId)
          return try await Templates(team: team, feedback: feedback)
        }
        .mapError(VoteError.from)
        await send(.inner(.templatesResponse(result)))
      }
      .cancellable(id: CancelID.fetchTemplates, cancelInFlight: true)

    case let .submit(submission):
      state.submitting = true
      let voteId = state.voteId
      return .run { send in
        let result = await Result { () -> Bool in
          guard let voteId else { throw VoteError.noActiveVote }
          try await voteUseCase.submitVote(voteId: voteId, submission: submission)
          return true
        }
        .mapError(VoteError.from)
        await send(.inner(.submitResponse(result)))
      }
      .cancellable(id: CancelID.submit, cancelInFlight: true)
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case let .activeVoteResponse(result):
      switch result {
      case let .success(activeVote):
        state.voteId = activeVote.voteId
        if activeVote.alreadyResponded {
          state.step = .alreadyVoted
          return .none
        }
        return .send(.async(.fetchTemplates(voteId: activeVote.voteId)))

      case let .failure(error):
        // 진행 중 투표가 없으면 빈 화면으로 안내한다.
        if error == .noActiveVote || error == .notFound {
          state.step = .empty
          return .none
        }
        state.step = .empty
        return presentError(state: &state, error: error, retry: .fetchActiveVote)
      }

    case let .templatesResponse(result):
      switch result {
      case let .success(templates):
        state.teamTemplate = templates.team
        state.feedbackTemplate = templates.feedback
        state.step = .teamSelect
        return .none

      case let .failure(error):
        state.step = .empty
        guard let voteId = state.voteId else {
          return presentError(state: &state, error: error, retry: .fetchActiveVote)
        }
        return presentError(state: &state, error: error, retry: .fetchTemplates(voteId: voteId))
      }

    case let .submitResponse(result):
      state.submitting = false
      switch result {
      case .success:
        state.step = .completed
        return .none

      case let .failure(error):
        // 재시도는 사용자가 피드백 화면에서 다시 제출하도록 유도한다.
        return presentError(state: &state, error: error, retry: .fetchActiveVote)
      }
    }
  }

  private func presentError(
    state: inout State,
    error: VoteError,
    retry: AsyncAction
  ) -> Effect<Action> {
    DDDLogger.error("멤버 투표 API 오류: \(error.localizedDescription)", category: .network)
    state.alert = AlertState {
      TextState("요청을 처리하지 못했어요")
    } actions: {
      ButtonState(action: .retry(retry)) {
        TextState("재시도")
      }
      ButtonState(role: .cancel, action: .cancel) {
        TextState("닫기")
      }
    } message: {
      TextState(error.errorDescription ?? "알 수 없는 오류가 발생했어요")
    }
    return .none
  }

  private func handleExitAlertAction(
    state: inout State,
    action: PresentationAction<CustomAlertAction>
  ) -> Effect<Action> {
    switch action {
    case let .presented(alertAction):
      switch alertAction {
      case .confirmTapped:
        state.exitAlert = nil
        return .none

      case .cancelTapped:
        state.exitAlert = nil
        switch state.step {
        case .feedback:
          state.step = .teamSelect
          return .none

        case .teamSelect:
          return .send(.delegate(.exitVote))

        default:
          return .none
        }

      case .policyTapped:
        return .none
      }

    case .dismiss:
      return .none
    }
  }
}
