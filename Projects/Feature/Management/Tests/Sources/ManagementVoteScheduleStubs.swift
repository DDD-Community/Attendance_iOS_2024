//
//  ManagementVoteScheduleStubs.swift
//  ManagementTests
//
//  Created by DDD on 2026-09-03.
//
//  Vote / Schedule / ScheduleModalFeature 리듀서 테스트가 공유하는 UseCase 스텁.
//  네트워크를 타지 않으면서 성공/실패/스트림 경로를 모두 지정할 수 있게 값 타입으로 둔다.
//

import Foundation

import ScheduleDomainInterface
import VoteDomainInterface

// MARK: - VoteUseCaseInterface 스텁

/// VoteFeature 가 쓰는 6개 경로(목록/참여현황/스트림/미참여자/시작/종료)만 제어한다.
/// 나머지 멤버 API 는 이 화면에서 호출되지 않으므로 `.unknown` 을 던져 오호출을 드러낸다.
struct ManagementVoteUseCaseStub: VoteUseCaseInterface, @unchecked Sendable {
  var votes: [Vote] = []
  var votesError: VoteError?
  var participation: VoteParticipation?
  var participationError: VoteError?
  var streamValues: [VoteParticipation] = []
  var nonResponders: [NonParticipant] = []
  var nonRespondersError: VoteError?
  var openError: VoteError?
  var closeError: VoteError?

  func fetchVotes() async throws(VoteError) -> [Vote] {
    if let votesError { throw votesError }
    return votes
  }

  func fetchParticipation(voteId: Int) async throws(VoteError) -> VoteParticipation {
    if let participationError { throw participationError }
    return participation ?? VoteParticipation(
      voteId: voteId,
      totalMembers: 0,
      respondedMembers: 0,
      participationRate: 0
    )
  }

  func participationStream(
    voteId _: Int,
    interval _: Double
  ) -> AsyncStream<VoteParticipation> {
    let values = streamValues
    return AsyncStream { continuation in
      for value in values {
        continuation.yield(value)
      }
      continuation.finish()
    }
  }

  func fetchNonResponders(voteId _: Int) async throws(VoteError) -> [NonParticipant] {
    if let nonRespondersError { throw nonRespondersError }
    return nonResponders
  }

  func openVote(voteId _: Int) async throws(VoteError) {
    if let openError { throw openError }
  }

  func closeVote(voteId _: Int) async throws(VoteError) {
    if let closeError { throw closeError }
  }

  // MARK: - 이 화면에서 쓰지 않는 계약

  func createVote(input _: CreateVoteInput) async throws(VoteError) -> Int {
    throw VoteError.unknown
  }

  func fetchTeamVoteResults(voteId _: Int) async throws(VoteError) -> TeamVoteResults {
    throw VoteError.unknown
  }

  func fetchFeedbackResults(voteId _: Int) async throws(VoteError) -> FeedbackResults {
    throw VoteError.unknown
  }

  func fetchActiveVote() async throws(VoteError) -> ActiveVote {
    throw VoteError.unknown
  }

  func fetchTeamVoteTemplate(voteId _: Int) async throws(VoteError) -> TeamVoteTemplateInfo {
    throw VoteError.unknown
  }

  func fetchFeedbackTemplate(voteId _: Int) async throws(VoteError) -> FeedbackTemplateInfo {
    throw VoteError.unknown
  }

  func submitVote(voteId _: Int, submission _: VoteSubmission) async throws(VoteError) {
    throw VoteError.unknown
  }

  func fetchMyResponse(voteId _: Int) async throws(VoteError) -> MyVoteResponse {
    throw VoteError.unknown
  }
}

// MARK: - ScheduleInterface 스텁

/// `cached` 가 nil 이면 캐시 미스, 빈 배열이면 "캐시는 있지만 비어있음" 경로를 태운다.
struct ManagementScheduleUseCaseStub: ScheduleUseCaseInterface, @unchecked Sendable {
  var schedules: [Schedule] = []
  var error: ScheduleError?
  var cached: [Schedule]?

  func getSchedule() async throws(ScheduleError) -> [Schedule] {
    if let error { throw error }
    return schedules
  }

  func getCachedSchedule() async -> [Schedule]? {
    cached
  }
}

// MARK: - 공용 픽스처

enum ManagementScheduleFixture {
  static let orientation = Schedule(
    id: 1,
    name: "OT",
    description: "오리엔테이션",
    month: 9,
    day: 2,
    year: 2026
  )

  static let midterm = Schedule(
    id: 2,
    name: "중간 발표",
    description: "팀별 중간 점검",
    month: 10,
    day: 11,
    year: 2026
  )

  static let demoDay = Schedule(
    id: 3,
    name: "데모데이",
    description: "최종 발표",
    month: 11,
    day: 29,
    year: 2026
  )

  static let all: [Schedule] = [orientation, midterm, demoDay]
}

enum ManagementVoteFixture {
  static let nonParticipants: [NonParticipant] = [
    NonParticipant(id: 1, name: "김철수", teamName: "iOS 1팀", attendance: .attended),
    NonParticipant(id: 2, name: "박영희", teamName: "AOS 2팀", attendance: .late),
    NonParticipant(id: 3, name: "이민수", teamName: "웹 1팀", attendance: .absent),
    NonParticipant(id: 4, name: "최지우", teamName: "서버 1팀")
  ]
}
