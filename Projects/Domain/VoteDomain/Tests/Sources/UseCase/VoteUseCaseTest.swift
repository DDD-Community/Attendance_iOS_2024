//
//  VoteUseCaseTest.swift
//  UseCaseTests
//
//  Created by DDD on 6/11/26.
//

import Foundation
import Testing

@testable import VoteDomain
@testable import VoteDomainInterface

import ComposableArchitecture

@Suite("Vote UseCase Tests - 운영진 투표 관리 TDD")
@MainActor
struct VoteUseCaseTest {
  private var mockRepository: MockVoteRepository!

  init() async {
    mockRepository = MockVoteRepository()
  }

  // MARK: - 투표 목록

  @Test("TC-001: 투표 목록 조회 성공 - 최신 투표 상태 매핑")
  func fetch_votes_success() async throws {
    let votes = [
      Vote(id: 1, title: "DDD 13기 최종 투표", status: .inProgress),
      Vote(id: 2, title: "임시 투표", status: .before)
    ]
    mockRepository.configureVotesSuccess(votes)

    let result = try await withDependencies {
      $0.voteRepository = mockRepository
    } operation: {
      try await VoteUseCaseImpl().fetchVotes()
    }

    #expect(result.count == 2)
    #expect(result.first?.id == 1)
    #expect(result.first?.status == .inProgress)
    #expect(mockRepository.fetchVotesCallCount == 1)
  }

  @Test("TC-002: 투표 목록이 비어있을 때")
  func fetch_votes_empty() async throws {
    mockRepository.configureVotesSuccess([])

    let result = try await withDependencies {
      $0.voteRepository = mockRepository
    } operation: {
      try await VoteUseCaseImpl().fetchVotes()
    }

    #expect(result.isEmpty)
    #expect(mockRepository.fetchVotesCallCount == 1)
  }

  @Test("TC-003: 투표 목록 조회 실패")
  func fetch_votes_failure() async throws {
    mockRepository.configureVotesFailure(VoteError.unknown)

    await #expect(throws: VoteError.self) {
      try await withDependencies {
        $0.voteRepository = mockRepository
      } operation: {
        _ = try await VoteUseCaseImpl().fetchVotes()
      }
    }
    #expect(mockRepository.fetchVotesCallCount == 1)
  }

  // MARK: - 참여 현황

  @Test("TC-004: 참여 현황 조회 성공")
  func fetch_participation_success() async throws {
    let participation = VoteParticipation(voteId: 1, totalMembers: 42, respondedMembers: 35, participationRate: 83)
    mockRepository.configureParticipationSuccess(participation)

    let result = try await withDependencies {
      $0.voteRepository = mockRepository
    } operation: {
      try await VoteUseCaseImpl().fetchParticipation(voteId: 1)
    }

    #expect(result.totalMembers == 42)
    #expect(result.respondedMembers == 35)
    #expect(result.participationRate == 83)
    #expect(mockRepository.participationCallCount == 1)
  }

  @Test("TC-005: 참여 현황 조회 실패 (없는 투표)")
  func fetch_participation_failure() async throws {
    mockRepository.configureParticipationFailure(VoteError.notFound)

    await #expect(throws: VoteError.notFound) {
      try await withDependencies {
        $0.voteRepository = mockRepository
      } operation: {
        _ = try await VoteUseCaseImpl().fetchParticipation(voteId: 99)
      }
    }
  }

  @Test("TC-006: 참여 현황 실시간 스트림 - 최신 값 수신")
  func participation_stream_yields() async throws {
    let participation = VoteParticipation(voteId: 1, totalMembers: 42, respondedMembers: 40, participationRate: 95)
    mockRepository.configureParticipationSuccess(participation)

    let received = await withDependencies {
      $0.voteRepository = mockRepository
    } operation: { () async -> VoteParticipation? in
      var last: VoteParticipation?
      for await value in VoteUseCaseImpl().participationStream(voteId: 1, interval: 0) {
        last = value
      }
      return last
    }

    #expect(received?.respondedMembers == 40)
    #expect(received?.participationRate == 95)
  }

  // MARK: - 미참여 명단

  @Test("TC-007: 미참여 명단 조회 성공")
  func fetch_non_responders_success() async throws {
    let members = [
      NonParticipant(id: 1, name: "김민준", teamName: "Web 1팀"),
      NonParticipant(id: 2, name: "이서연", teamName: "Web 2팀")
    ]
    mockRepository.configureNonRespondersSuccess(members)

    let result = try await withDependencies {
      $0.voteRepository = mockRepository
    } operation: {
      try await VoteUseCaseImpl().fetchNonResponders(voteId: 1)
    }

    #expect(result.count == 2)
    #expect(result.first?.name == "김민준")
    #expect(mockRepository.nonRespondersCallCount == 1)
  }

  @Test("TC-008: 미참여 명단 비어있음")
  func fetch_non_responders_empty() async throws {
    mockRepository.configureNonRespondersSuccess([])

    let result = try await withDependencies {
      $0.voteRepository = mockRepository
    } operation: {
      try await VoteUseCaseImpl().fetchNonResponders(voteId: 1)
    }

    #expect(result.isEmpty)
  }

  // MARK: - 투표 시작/종료

  @Test("TC-009: 투표 시작 성공")
  func open_vote_success() async throws {
    mockRepository.configureOpenVoteSuccess()

    try await withDependencies {
      $0.voteRepository = mockRepository
    } operation: {
      try await VoteUseCaseImpl().openVote(voteId: 1)
    }

    #expect(mockRepository.openVoteCallCount == 1)
  }

  @Test("TC-010: 투표 시작 실패 (이미 진행 중)")
  func open_vote_already_open() async throws {
    mockRepository.configureOpenVoteFailure(VoteError.alreadyOpen)

    await #expect(throws: VoteError.alreadyOpen) {
      try await withDependencies {
        $0.voteRepository = mockRepository
      } operation: {
        try await VoteUseCaseImpl().openVote(voteId: 1)
      }
    }
    #expect(mockRepository.openVoteCallCount == 1)
  }

  @Test("TC-011: 투표 종료 성공")
  func close_vote_success() async throws {
    mockRepository.configureCloseVoteSuccess()

    try await withDependencies {
      $0.voteRepository = mockRepository
    } operation: {
      try await VoteUseCaseImpl().closeVote(voteId: 1)
    }

    #expect(mockRepository.closeVoteCallCount == 1)
  }

  @Test("TC-012: 투표 종료 실패 (잘못된 상태)")
  func close_vote_invalid_status() async throws {
    mockRepository.configureCloseVoteFailure(VoteError.invalidStatus)

    await #expect(throws: VoteError.invalidStatus) {
      try await withDependencies {
        $0.voteRepository = mockRepository
      } operation: {
        try await VoteUseCaseImpl().closeVote(voteId: 1)
      }
    }
  }

  // MARK: - 상태 매핑

  @Test("TC-013: 서버 상태 문자열 → VoteStatus 매핑")
  func vote_status_mapping() {
    #expect(VoteStatus(serverStatus: "DRAFT") == .before)
    #expect(VoteStatus(serverStatus: "OPEN") == .inProgress)
    #expect(VoteStatus(serverStatus: "CLOSED") == .after)
    #expect(VoteStatus(serverStatus: "unknown") == .before)
  }
}
