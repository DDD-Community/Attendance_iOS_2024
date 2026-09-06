//
//  VoteRepositoryImpl.swift
//  VoteDomain
//
//  Created by DDD on 6/11/26.
//

import Foundation

import APIEndpoint
import DDDNetworkInterface
import VoteDomainInterface

import Dependencies

public final class VoteRepositoryImpl: VoteRepositoryInterface, @unchecked Sendable {
  @Dependency(\.networkClient) private var client

  public init() {}

  public func fetchVotes() async throws(VoteError) -> [Vote] {
    let response = try await response(VoteRequest.list)
    try validate(response)
    return try decode([VoteListItemDTO].self, from: response.data).toDomain()
  }

  public func fetchParticipation(
    voteId: Int
  ) async throws(VoteError) -> VoteParticipation {
    let response = try await response(VoteRequest.participation(voteId: voteId))
    try validate(response)
    return try decode(VoteParticipationDTO.self, from: response.data).toDomain()
  }

  public func participationStream(
    voteId: Int,
    interval: Double
  ) -> AsyncStream<VoteParticipation> {
    AsyncStream { continuation in
      let task = _Concurrency.Task {
        while !_Concurrency.Task.isCancelled {
          if let participation = try? await fetchParticipation(voteId: voteId) {
            continuation.yield(participation)
          }
          try? await _Concurrency.Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
        }
        continuation.finish()
      }
      continuation.onTermination = { _ in task.cancel() }
    }
  }

  public func fetchNonResponders(
    voteId: Int
  ) async throws(VoteError) -> [NonParticipant] {
    let response = try await response(VoteRequest.nonResponders(voteId: voteId))
    try validate(response)
    return try decode(NonRespondersDTO.self, from: response.data).toDomain()
  }

  public func openVote(
    voteId: Int
  ) async throws(VoteError) {
    let response = try await response(VoteRequest.open(voteId: voteId))
    try validate(response)
  }

  public func closeVote(
    voteId: Int
  ) async throws(VoteError) {
    let response = try await response(VoteRequest.close(voteId: voteId))
    try validate(response)
  }

  public func createVote(
    input: CreateVoteInput
  ) async throws(VoteError) -> Int {
    let response = try await response(VoteRequest.create(body: input))
    try validate(response)
    return try decode(CreateVoteResponseDTO.self, from: response.data).voteId ?? 0
  }

  public func fetchTeamVoteResults(
    voteId: Int
  ) async throws(VoteError) -> TeamVoteResults {
    let response = try await response(VoteRequest.teamVoteResults(voteId: voteId))
    try validate(response)
    return try decode(TeamVoteResultsDTO.self, from: response.data).toDomain()
  }

  public func fetchFeedbackResults(
    voteId: Int
  ) async throws(VoteError) -> FeedbackResults {
    let response = try await response(VoteRequest.feedbackResults(voteId: voteId))
    try validate(response)
    return try decode(FeedbackResultsDTO.self, from: response.data).toDomain()
  }

  public func fetchActiveVote() async throws(VoteError) -> ActiveVote {
    let response = try await response(VoteRequest.active)
    try validate(response)
    return try decode(ActiveVoteDTO.self, from: response.data).toDomain()
  }

  public func fetchTeamVoteTemplate(
    voteId: Int
  ) async throws(VoteError) -> TeamVoteTemplateInfo {
    let response = try await response(VoteRequest.teamVoteTemplate(voteId: voteId))
    try validate(response)
    return try decode(TeamVoteTemplateResponseDTO.self, from: response.data).toDomain()
  }

  public func fetchFeedbackTemplate(
    voteId: Int
  ) async throws(VoteError) -> FeedbackTemplateInfo {
    let response = try await response(VoteRequest.feedbackTemplate(voteId: voteId))
    try validate(response)
    return try decode(FeedbackTemplateResponseDTO.self, from: response.data).toDomain()
  }

  public func submitVote(
    voteId: Int,
    submission: VoteSubmission
  ) async throws(VoteError) {
    let response = try await response(VoteRequest.submit(voteId: voteId, body: submission))
    try validate(response)
  }

  public func fetchMyResponse(
    voteId: Int
  ) async throws(VoteError) -> MyVoteResponse {
    let response = try await response(VoteRequest.myResponse(voteId: voteId))
    try validate(response)
    return try decode(MyVoteResponseDTO.self, from: response.data).toDomain()
  }
}

private extension VoteRepositoryImpl {
  struct ErrorBody: Decodable {
    let code: String?
    let message: String?
  }

  func response(_ request: VoteRequest) async throws(VoteError) -> DDDHTTPResponse {
    do {
      return try await client.sendResponse(request)
    } catch {
      throw Self.mapError(error)
    }
  }

  /// 서버가 준 응답 코드만 도메인 케이스로 옮기고, 전송·디코딩 실패는 `.unknown` 으로 흡수한다.
  private static func mapError(_ error: DDDNetworkError) -> VoteError {
    guard case let .response(responseError) = error else {
      return .requestFailed
    }
    return mapResponseError(
      statusCode: responseError.httpStatus,
      code: responseError.code
    )
  }

  func validate(_ response: DDDHTTPResponse) throws(VoteError) {
    guard !(200 ..< 300).contains(response.statusCode) else { return }
    let body = try? JSONDecoder().decode(ErrorBody.self, from: response.data)
    throw Self.mapResponseError(statusCode: response.statusCode, code: body?.code)
  }

  func decode<T: Decodable>(_: T.Type, from data: Data) throws(VoteError) -> T {
    do {
      return try JSONDecoder().decode(T.self, from: data)
    } catch {
      throw .invalidResponse
    }
  }

  private static func mapResponseError(statusCode: Int, code: String?) -> VoteError {
    switch code {
    case "VOTE_NO_ACTIVE":
      return .noActiveVote
    case "DATA_NOT_FOUND", "VOTE_NOT_FOUND":
      return .notFound
    case "MANAGER_ONLY", "VOTE_MANAGER_NOT_ALLOWED":
      return .managerOnly
    case "VOTE_ALREADY_OPEN":
      return .alreadyOpen
    case "VOTE_INVALID_STATUS", "VOTE_NOT_DRAFT", "VOTE_NOT_OPEN", "VALIDATION_ERROR":
      return .invalidStatus
    default:
      break
    }

    switch statusCode {
    case 403:
      return .managerOnly
    case 404:
      return .notFound
    default:
      return .requestFailed
    }
  }
}
