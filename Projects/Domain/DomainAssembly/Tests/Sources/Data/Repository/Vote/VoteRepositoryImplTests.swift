//
//  VoteRepositoryImplTests.swift
//  DomainAssemblyTests
//
//  Created by DDD on 9/4/26.
//

import Foundation
import Testing

@testable import AppUpdateDomain
@testable import AttendanceDomain
@testable import AuthDomain
import DDDNetworkInterface
@testable import MyPageDomain
@testable import OnBoardingDomain
@testable import ProfileDomain
@testable import QRCodeDomain
@testable import ScheduleDomain
@testable import VoteDomain

struct VoteRepositoryImplTests {
  private static let responseErrorCases: [(Int, String?, VoteError)] = [
    (400, "VOTE_NO_ACTIVE", .noActiveVote),
    (400, "DATA_NOT_FOUND", .notFound),
    (400, "MANAGER_ONLY", .managerOnly),
    (400, "VOTE_ALREADY_OPEN", .alreadyOpen),
    (400, "VOTE_INVALID_STATUS", .invalidStatus),
    (403, nil, .managerOnly),
    (404, nil, .notFound),
    (500, nil, .requestFailed)
  ]

  @Test("투표 Repository 성공 응답 전체 경로")
  func successPaths() async throws {
    let client = StubNetworkClient([
      .response(200, "[]"), .response(200, "{}"), .response(200, "{}"),
      .response(204), .response(204), .response(200, #"{"voteId":7}"#),
      .response(200, "{}"), .response(200, "{}"), .response(200, "{}"),
      .response(200, "{}"), .response(200, "{}"), .response(204),
      .response(200, "{}")
    ])
    let repository = makeRepository(client: client) { VoteRepositoryImpl() }

    #expect(try await repository.fetchVotes().isEmpty)
    _ = try await repository.fetchParticipation(voteId: 1)
    #expect(try await repository.fetchNonResponders(voteId: 1).isEmpty)
    try await repository.openVote(voteId: 1)
    try await repository.closeVote(voteId: 1)
    #expect(try await repository.createVote(input: .init(
      generationId: 1, title: "투표", teamVoteTemplate: nil, feedbackTemplate: nil
    )) == 7)
    _ = try await repository.fetchTeamVoteResults(voteId: 1)
    _ = try await repository.fetchFeedbackResults(voteId: 1)
    _ = try await repository.fetchActiveVote()
    _ = try await repository.fetchTeamVoteTemplate(voteId: 1)
    _ = try await repository.fetchFeedbackTemplate(voteId: 1)
    try await repository.submitVote(voteId: 1, submission: .init(teamVote: [], feedback: []))
    _ = try await repository.fetchMyResponse(voteId: 1)
  }

  @Test(
    "서버 코드와 상태를 VoteError로 변환",
    arguments: responseErrorCases
  )
  func responseErrors(status: Int, code: String?, expected: VoteError) async {
    let json = code.map { #"{"code":"\#($0)"}"# } ?? "{}"
    let repository = makeRepository(client: StubNetworkClient(statusCode: status, json: json)) { VoteRepositoryImpl() }
    await #expect(throws: expected) { try await repository.openVote(voteId: 1) }
  }

  @Test("네트워크 오류는 요청 실패")
  func networkError() async {
    let error = DDDNetworkError.response(.init(httpStatus: 503))
    let repository = makeRepository(client: StubNetworkClient(error: error)) { VoteRepositoryImpl() }
    await #expect(throws: VoteError.requestFailed) { try await repository.fetchActiveVote() }
  }

  @Test("성공 상태의 잘못된 JSON은 invalidResponse")
  func invalidJSON() async {
    let repository = makeRepository(client: StubNetworkClient(json: "not-json")) { VoteRepositoryImpl() }
    await #expect(throws: VoteError.invalidResponse) { try await repository.fetchActiveVote() }
  }
}
