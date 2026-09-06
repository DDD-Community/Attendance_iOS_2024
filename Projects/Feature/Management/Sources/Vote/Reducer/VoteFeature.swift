//
//  VoteFeature.swift
//  Management
//
//  Created by DDD on 6/11/26.
//

import DDDCoreLogger
import ComposableArchitecture
import DDDDesignKit
import Foundation
import VoteDomainInterface

@Reducer
public struct VoteFeature {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    /// 이 화면이 지금 무엇을 그려야 하는지.
    public enum ViewState: Equatable {
      case loading
      case loaded
    }

    /// 첫 진입은 항상 fetch 로 시작한다. 빈 화면이 한 프레임 스쳐 지나가지 않도록 스켈레톤부터 그린다.

    var viewState: ViewState = .loading
    var hasFetchedVotes: Bool = false
    var voteId: Int?
    var voteStatus: VoteStatus = .before
    var participation: VoteParticipation?
    var isNonParticipantsPresented: Bool = false
    var isNonParticipantsLoading: Bool = false
    var nonParticipants: [NonParticipant] = []
    @Presents public var customAlert: CustomAlertState<CustomAlertAction>?
    @Presents public var alert: AlertState<AlertAction>?
    public init() {}
  }

  public enum Action: ViewAction, BindableAction {
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case scope(ScopeAction)
  }

  @CasePathable
  public enum View {
    case onAppear
    case onDisappear
    case tappedStartVoteButton
    case tappedCheckNonParticipants
    case tappedCloseNonParticipants
    case tappedEndVoteButton
  }

  @CasePathable
  public enum ScopeAction {
    case customAlert(PresentationAction<CustomAlertAction>)
    case alert(PresentationAction<AlertAction>)
  }

  @CasePathable
  public enum AlertAction: Equatable {
    case cancel
    case retry(AsyncAction)
  }

  @CasePathable
  public enum AsyncAction: Equatable {
    case fetchVotes
    case fetchParticipation
    case startParticipationStream
    case openVote
    case closeVote
    case fetchNonResponders
  }

  @CasePathable
  public enum InnerAction: Equatable {
    case votesResponse(Result<[Vote], VoteError>)
    case participationResponse(Result<VoteParticipation, VoteError>)
    case nonRespondersResponse(Result<[NonParticipant], VoteError>)
    case openVoteResponse(Result<Bool, VoteError>)
    case closeVoteResponse(Result<Bool, VoteError>)
  }

  nonisolated enum CancelID: Hashable {
    case fetchVotes
    case fetchParticipation
    case participationStream
    case openVote
    case closeVote
    case fetchNonResponders
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

      case let .scope(scopeAction):
        switch scopeAction {
        case let .customAlert(customAlertAction):
          return handleCustomAlertAction(state: &state, action: customAlertAction)

        case let .alert(alertAction):
          guard case let .presented(.retry(retryAction)) = alertAction else { return .none }
          return .send(.async(retryAction))
        }
      }
    }
    .ifLet(\.$customAlert, action: \.scope.customAlert) {
      CustomConfirmAlert()
    }
    .ifLet(\.$alert, action: \.scope.alert)
  }
}

extension VoteFeature {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
    case .onAppear:
      // 재진입 때는 스켈레톤 없이 최신 투표만 받아온다.
      if !state.hasFetchedVotes {
        state.hasFetchedVotes = true
        state.viewState = .loading
      }
      return .send(.async(.fetchVotes))

    case .onDisappear:
      return .cancel(id: CancelID.participationStream)

    case .tappedStartVoteButton:
      state.customAlert = .startVote()
      return .none

    case .tappedCheckNonParticipants:
      state.nonParticipants = []
      state.isNonParticipantsLoading = true
      state.isNonParticipantsPresented = true
      return .send(.async(.fetchNonResponders))

    case .tappedCloseNonParticipants:
      state.isNonParticipantsPresented = false
      return .none

    case .tappedEndVoteButton:
      state.customAlert = .endVote()
      return .none
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {
    case .fetchVotes:
      return .run { send in
        let result = await Result {
          try await voteUseCase.fetchVotes()
        }
        .mapError(VoteError.from)
        await send(.inner(.votesResponse(result)))
      }
      .cancellable(id: CancelID.fetchVotes, cancelInFlight: true)

    case .fetchParticipation:
      guard let voteId = state.voteId else { return .none }
      return .run { send in
        let result = await Result {
          try await voteUseCase.fetchParticipation(voteId: voteId)
        }
        .mapError(VoteError.from)
        await send(.inner(.participationResponse(result)))
      }
      .cancellable(id: CancelID.fetchParticipation, cancelInFlight: true)

    case .startParticipationStream:
      guard let voteId = state.voteId else { return .none }
      return .run { send in
        for await participation in voteUseCase.participationStream(voteId: voteId, interval: 5) {
          await send(.inner(.participationResponse(.success(participation))))
        }
      }
      .cancellable(id: CancelID.participationStream, cancelInFlight: true)

    case .openVote:
      guard let voteId = state.voteId else {
        return presentError(state: &state, error: .noActiveVote, retry: .fetchVotes)
      }
      return .run { send in
        let result = await Result { () -> Bool in
          try await voteUseCase.openVote(voteId: voteId)
          return true
        }
        .mapError(VoteError.from)
        await send(.inner(.openVoteResponse(result)))
      }
      .cancellable(id: CancelID.openVote, cancelInFlight: true)

    case .closeVote:
      guard let voteId = state.voteId else {
        return presentError(state: &state, error: .noActiveVote, retry: .fetchVotes)
      }
      return .run { send in
        let result = await Result { () -> Bool in
          try await voteUseCase.closeVote(voteId: voteId)
          return true
        }
        .mapError(VoteError.from)
        await send(.inner(.closeVoteResponse(result)))
      }
      .cancellable(id: CancelID.closeVote, cancelInFlight: true)

    case .fetchNonResponders:
      guard let voteId = state.voteId else {
        state.isNonParticipantsPresented = false
        state.isNonParticipantsLoading = false
        return presentError(state: &state, error: .noActiveVote, retry: .fetchVotes)
      }
      state.isNonParticipantsPresented = true
      state.isNonParticipantsLoading = true
      return .run { send in
        let result = await Result {
          try await voteUseCase.fetchNonResponders(voteId: voteId)
        }
        .mapError(VoteError.from)
        await send(.inner(.nonRespondersResponse(result)))
      }
      .cancellable(id: CancelID.fetchNonResponders, cancelInFlight: true)
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {
    case let .votesResponse(result):
      state.viewState = .loaded
      switch result {
      case let .success(votes):
        guard let latest = votes.first else {
          state.voteId = nil
          state.voteStatus = .before
          return .none
        }
        state.voteId = latest.id
        state.voteStatus = latest.status
        switch latest.status {
        case .inProgress:
          return .send(.async(.startParticipationStream))
        case .after:
          return .send(.async(.fetchParticipation))
        case .before:
          return .none
        }
      case let .failure(error):
        return presentError(state: &state, error: error, retry: .fetchVotes)
      }

    case let .participationResponse(result):
      switch result {
      case let .success(participation):
        state.participation = participation
        state.voteStatus = participation.status
        return .none
      case let .failure(error):
        return presentError(state: &state, error: error, retry: .fetchParticipation)
      }

    case let .nonRespondersResponse(result):
      state.isNonParticipantsLoading = false
      switch result {
      case let .success(members):
        state.nonParticipants = members
        return .none
      case let .failure(error):
        state.isNonParticipantsPresented = false
        return presentError(state: &state, error: error, retry: .fetchNonResponders)
      }

    case let .openVoteResponse(result):
      switch result {
      case .success:
        state.voteStatus = .inProgress
        return .send(.async(.startParticipationStream))
      case let .failure(error):
        return presentError(state: &state, error: error, retry: .openVote)
      }

    case let .closeVoteResponse(result):
      switch result {
      case .success:
        state.voteStatus = .after
        return .merge(
          .cancel(id: CancelID.participationStream),
          .send(.async(.fetchParticipation))
        )
      case let .failure(error):
        return presentError(state: &state, error: error, retry: .closeVote)
      }
    }
  }

  private func presentError(
    state: inout State,
    error: VoteError,
    retry: AsyncAction
  ) -> Effect<Action> {
    state.viewState = .loaded
    DDDLogger.error("투표 API 오류: \(error.localizedDescription)", category: .network)
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

  private func handleCustomAlertAction(
    state: inout State,
    action: PresentationAction<CustomAlertAction>
  ) -> Effect<Action> {
    switch action {
    case let .presented(customAlertAction):
      let alertStyle = state.customAlert?.style

      switch customAlertAction {
      case .confirmTapped:
        state.customAlert = nil
        return .none

      case .cancelTapped:
        state.customAlert = nil
        switch alertStyle {
        case .startConfirmation:
          return .send(.async(.openVote))
        case .endConfirmation:
          return .send(.async(.closeVote))
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
