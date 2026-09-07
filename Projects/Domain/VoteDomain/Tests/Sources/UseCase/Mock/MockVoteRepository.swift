//
//  MockVoteRepository.swift
//  UseCaseTests
//
//  Created by DDD on 6/11/26.
//

import Foundation

@testable import VoteDomainInterface

@MainActor
final class MockVoteRepository: VoteRepositoryInterface {
  var fetchVotesCallCount = 0
  var participationCallCount = 0
  var nonRespondersCallCount = 0
  var openVoteCallCount = 0
  var closeVoteCallCount = 0

  private var votesResponse: Result<[Vote], VoteError>?
  private var participationResponse: Result<VoteParticipation, VoteError>?
  private var nonRespondersResponse: Result<[NonParticipant], VoteError>?
  private var openVoteResponse: Result<Void, VoteError>?
  private var closeVoteResponse: Result<Void, VoteError>?

  func fetchVotes() async throws(VoteError) -> [Vote] {
    fetchVotesCallCount += 1
    guard let votesResponse else { throw VoteError.unknown }
    return try votesResponse.get()
  }

  func fetchParticipation(
    voteId _: Int
  ) async throws(VoteError) -> VoteParticipation {
    participationCallCount += 1
    guard let participationResponse else { throw VoteError.unknown }
    return try participationResponse.get()
  }

  func participationStream(
    voteId _: Int,
    interval _: Double
  ) -> AsyncStream<VoteParticipation> {
    AsyncStream { continuation in
      if case let .success(participation) = participationResponse {
        continuation.yield(participation)
      }
      continuation.finish()
    }
  }

  func fetchNonResponders(
    voteId _: Int
  ) async throws(VoteError) -> [NonParticipant] {
    nonRespondersCallCount += 1
    guard let nonRespondersResponse else { throw VoteError.unknown }
    return try nonRespondersResponse.get()
  }

  func openVote(
    voteId _: Int
  ) async throws(VoteError) {
    openVoteCallCount += 1
    guard let openVoteResponse else { throw VoteError.unknown }
    try openVoteResponse.get()
  }

  func closeVote(
    voteId _: Int
  ) async throws(VoteError) {
    closeVoteCallCount += 1
    guard let closeVoteResponse else { throw VoteError.unknown }
    try closeVoteResponse.get()
  }

  func createVote(
    input _: CreateVoteInput
  ) async throws(VoteError) -> Int { 0 }

  func fetchTeamVoteResults(
    voteId: Int
  ) async throws(VoteError) -> TeamVoteResults {
    TeamVoteResults(voteId: voteId, title: "", status: .before, totalResponses: 0, categories: [])
  }

  func fetchFeedbackResults(
    voteId: Int
  ) async throws(VoteError) -> FeedbackResults {
    FeedbackResults(voteId: voteId, totalResponses: 0, questions: [])
  }

  func fetchActiveVote() async throws(VoteError) -> ActiveVote {
    ActiveVote(voteId: 0, title: "", alreadyResponded: false)
  }

  func fetchTeamVoteTemplate(
    voteId _: Int
  ) async throws(VoteError) -> TeamVoteTemplateInfo {
    TeamVoteTemplateInfo(
      templateVersion: 0,
      status: .before,
      template: TeamVoteTemplate(title: "", description: "", notice: "", categories: []),
      teams: []
    )
  }

  func fetchFeedbackTemplate(
    voteId _: Int
  ) async throws(VoteError) -> FeedbackTemplateInfo {
    FeedbackTemplateInfo(
      templateVersion: 0,
      status: .before,
      template: FeedbackTemplate(title: "", description: "", questions: [])
    )
  }

  func submitVote(
    voteId _: Int,
    submission _: VoteSubmission
  ) async throws(VoteError) {}

  func fetchMyResponse(
    voteId: Int
  ) async throws(VoteError) -> MyVoteResponse {
    MyVoteResponse(voteId: voteId, responded: false)
  }

  func configureVotesSuccess(_ votes: [Vote]) { votesResponse = .success(votes) }
  func configureVotesFailure(_ error: Error) { votesResponse = .failure(VoteError.from(error)) }
  func configureParticipationSuccess(_ participation: VoteParticipation) {
    participationResponse = .success(participation)
  }

  func configureParticipationFailure(_ error: Error) {
    participationResponse = .failure(VoteError.from(error))
  }
  func configureNonRespondersSuccess(_ members: [NonParticipant]) { nonRespondersResponse = .success(members) }
  func configureNonRespondersFailure(_ error: Error) {
    nonRespondersResponse = .failure(VoteError.from(error))
  }
  func configureOpenVoteSuccess() { openVoteResponse = .success(()) }
  func configureOpenVoteFailure(_ error: Error) { openVoteResponse = .failure(VoteError.from(error)) }
  func configureCloseVoteSuccess() { closeVoteResponse = .success(()) }
  func configureCloseVoteFailure(_ error: Error) { closeVoteResponse = .failure(VoteError.from(error)) }
}
