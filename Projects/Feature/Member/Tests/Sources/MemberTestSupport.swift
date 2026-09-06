//
//  MemberTestSupport.swift
//  MemberTests
//
//  Member 피처 테스트가 공유하는 픽스처와 유스케이스 스텁.
//  네트워크를 타는 live 유스케이스 대신 이 스텁을 주입해 async 분기를 결정적으로 검증한다.
//

import ComposableArchitecture
import AttendanceDomainInterface
import MyPageDomainInterface
import ProfileDomainInterface
import QRCodeDomainInterface
import VoteDomainInterface
import Foundation
import SwiftUI

@testable import Member

// MARK: - Fixtures

enum MemberTestFixture {
  // MARK: Profile

  static let profile = ProfileEntity(
    userID: 1,
    name: "김철수",
    generation: "13기",
    team: .ios1,
    jobRole: .ios,
    role: .member,
    manger: nil
  )

  // MARK: Attendance

  static let attendanceSummary = AttendanceSummaryResponse(
    totalAttended: 8,
    totalLate: 1,
    totalAbsent: 2
  )

  static let cleanAttendanceSummary = AttendanceSummaryResponse(
    totalAttended: 10,
    totalLate: 0,
    totalAbsent: 0
  )

  // MARK: Schedule

  static let scheduleResponses: [AttendanceMyScheduleResponse] = [
    AttendanceMyScheduleResponse(
      id: 1,
      name: "OT",
      desc: "오리엔테이션",
      month: 9,
      day: 2,
      status: "ATTENDED"
    ),
    AttendanceMyScheduleResponse(
      id: 2,
      name: "중간 발표",
      desc: "중간 점검",
      month: 10,
      day: 14,
      status: "LATE"
    ),
    AttendanceMyScheduleResponse(
      id: 3,
      name: "최종 발표",
      desc: "데모데이",
      month: 11,
      day: 30,
      status: "정의되지-않은-값"
    )
  ]

  /// `scheduleResponses` 를 리듀서가 매핑한 결과와 같아야 한다.
  static let schedules: [ScheduleModel] = [
    ScheduleModel(
      id: 1,
      title: "OT",
      description: "오리엔테이션",
      month: 9,
      day: 2,
      status: .attended
    ),
    ScheduleModel(
      id: 2,
      title: "중간 발표",
      description: "중간 점검",
      month: 10,
      day: 14,
      status: .late
    ),
    ScheduleModel(
      id: 3,
      title: "최종 발표",
      description: "데모데이",
      month: 11,
      day: 30,
      status: .none
    )
  ]

  // MARK: Vote

  static let activeVote = ActiveVote(
    voteId: 42,
    title: "DDD 13기 팀 투표",
    alreadyResponded: false
  )

  static let respondedVote = ActiveVote(
    voteId: 42,
    title: "DDD 13기 팀 투표",
    alreadyResponded: true
  )

  static let teamTemplate = TeamVoteTemplateInfo(
    templateVersion: 1,
    status: .inProgress,
    template: TeamVoteTemplate(
      title: "가장 기억에 남는 팀을 골라주세요",
      description: "13기 활동을 돌아보며 팀을 선택해주세요.",
      notice: "본인 팀은 선택할 수 없어요.",
      categories: [
        // order 가 뒤섞여 있어야 정렬 분기를 태울 수 있다.
        TeamVoteCategory(
          id: "collaboration",
          order: 1,
          title: "협업이 가장 좋았던 팀",
          maxSelectableTeams: 2,
          reasonRequired: true,
          reasonMinLength: 5,
          reasonMaxLength: 200,
          reasonLabel: "이유를 알려주세요"
        ),
        TeamVoteCategory(
          id: "design",
          order: 0,
          title: "디자인이 가장 좋았던 팀",
          maxSelectableTeams: 1,
          reasonRequired: false,
          reasonMinLength: 0,
          reasonMaxLength: 100,
          reasonLabel: "이유 (선택)"
        )
      ]
    ),
    teams: [
      VoteTeam(id: 1, name: "1팀", serviceName: "출석부", isOwnTeam: true),
      VoteTeam(id: 2, name: "2팀", serviceName: nil, isOwnTeam: false),
      VoteTeam(id: 3, name: "3팀", serviceName: "가계부", isOwnTeam: false)
    ]
  )

  static let feedbackTemplate = FeedbackTemplateInfo(
    templateVersion: 2,
    status: .inProgress,
    template: FeedbackTemplate(
      title: "참여 경험을 들려주세요",
      description: "솔직한 의견이 다음 기수를 만듭니다.",
      questions: [
        FeedbackQuestion(
          id: "q-multi",
          order: 1,
          type: .multiSelect,
          title: "가장 만족했던 점은 무엇인가요?",
          helpText: "최대 2개까지 선택할 수 있어요",
          required: true,
          maxSelectableOptions: 2,
          maxLength: nil,
          options: [
            FeedbackOption(id: "opt-1", label: "팀 빌딩"),
            FeedbackOption(id: "opt-2", label: "세션 구성"),
            FeedbackOption(id: "opt-3", label: "운영 지원")
          ],
          followUp: []
        ),
        FeedbackQuestion(
          id: "q-text",
          order: 2,
          type: .longText,
          title: "개선했으면 하는 점을 적어주세요",
          helpText: nil,
          required: false,
          maxSelectableOptions: nil,
          maxLength: 200,
          options: nil,
          followUp: []
        ),
        FeedbackQuestion(
          id: "q-bool",
          order: 3,
          type: .boolean,
          title: "다음 기수에도 참여할 의향이 있나요?",
          helpText: nil,
          required: true,
          maxSelectableOptions: nil,
          maxLength: nil,
          options: nil,
          followUp: [
            FeedbackQuestion(
              id: "q-bool-follow",
              order: 1,
              type: .longText,
              title: "그렇게 생각한 이유를 알려주세요",
              helpText: nil,
              required: false,
              maxSelectableOptions: nil,
              maxLength: 100,
              options: nil,
              followUp: []
            )
          ]
        ),
        FeedbackQuestion(
          id: "q-team",
          order: 4,
          type: .teamSelect,
          title: "함께하고 싶은 팀을 골라주세요",
          helpText: "복수 선택 가능",
          required: false,
          maxSelectableOptions: 3,
          maxLength: nil,
          options: [
            FeedbackOption(id: "team-1", label: "1팀"),
            FeedbackOption(id: "team-2", label: "2팀")
          ],
          followUp: []
        )
      ]
    )
  )

  static let templates = MemberVoteFeature.Templates(
    team: teamTemplate,
    feedback: feedbackTemplate
  )

  static let teamAnswers: [TeamVoteAnswer] = [
    TeamVoteAnswer(categoryId: "collaboration", teamIds: [2, 3], reason: "협업이 좋았어요"),
    TeamVoteAnswer(categoryId: "design", teamIds: [2], reason: nil)
  ]

  static let feedbackAnswers: [FeedbackAnswer] = [
    FeedbackAnswer(
      questionId: "q-multi",
      optionIds: ["opt-1"],
      textValue: nil,
      boolValue: nil
    ),
    FeedbackAnswer(
      questionId: "q-text",
      optionIds: nil,
      textValue: "세션 시간이 조금 짧았어요",
      boolValue: nil
    ),
    FeedbackAnswer(
      questionId: "q-bool",
      optionIds: nil,
      textValue: nil,
      boolValue: true
    )
  ]

  static let submission = VoteSubmission(
    teamVote: teamAnswers,
    feedback: feedbackAnswers
  )
}

// MARK: - Vote UseCase Stub

/// `VoteUseCaseInterface` 중 멤버 플로우가 실제로 쓰는 메서드 결과를 주입받는다.
/// 운영진 전용 메서드는 호출될 일이 없으므로 실패로 고정한다.
final class StubVoteUseCase: VoteUseCaseInterface, @unchecked Sendable {
  private let activeVoteResult: Result<ActiveVote, VoteError>
  private let teamTemplateResult: Result<TeamVoteTemplateInfo, VoteError>
  private let feedbackTemplateResult: Result<FeedbackTemplateInfo, VoteError>
  private let submitError: VoteError?

  init(
    activeVote: Result<ActiveVote, VoteError> = .failure(.noActiveVote),
    teamTemplate: Result<TeamVoteTemplateInfo, VoteError> = .failure(.requestFailed),
    feedbackTemplate: Result<FeedbackTemplateInfo, VoteError> = .failure(.requestFailed),
    submitError: VoteError? = nil
  ) {
    activeVoteResult = activeVote
    teamTemplateResult = teamTemplate
    feedbackTemplateResult = feedbackTemplate
    self.submitError = submitError
  }

  // MARK: 멤버 플로우

  func fetchActiveVote() async throws(VoteError) -> ActiveVote {
    switch activeVoteResult {
    case let .success(value): return value
    case let .failure(error): throw error
    }
  }

  func fetchTeamVoteTemplate(voteId _: Int) async throws(VoteError) -> TeamVoteTemplateInfo {
    switch teamTemplateResult {
    case let .success(value): return value
    case let .failure(error): throw error
    }
  }

  func fetchFeedbackTemplate(voteId _: Int) async throws(VoteError) -> FeedbackTemplateInfo {
    switch feedbackTemplateResult {
    case let .success(value): return value
    case let .failure(error): throw error
    }
  }

  func submitVote(voteId _: Int, submission _: VoteSubmission) async throws(VoteError) {
    if let submitError {
      throw submitError
    }
  }

  // MARK: 운영진 전용 (멤버 테스트에서 호출되지 않음)

  func fetchVotes() async throws(VoteError) -> [Vote] {
    throw .managerOnly
  }

  func fetchParticipation(voteId _: Int) async throws(VoteError) -> VoteParticipation {
    throw .managerOnly
  }

  func participationStream(voteId _: Int, interval _: Double) -> AsyncStream<VoteParticipation> {
    AsyncStream { $0.finish() }
  }

  func fetchNonResponders(voteId _: Int) async throws(VoteError) -> [NonParticipant] {
    throw .managerOnly
  }

  func openVote(voteId _: Int) async throws(VoteError) {
    throw .managerOnly
  }

  func closeVote(voteId _: Int) async throws(VoteError) {
    throw .managerOnly
  }

  func createVote(input _: CreateVoteInput) async throws(VoteError) -> Int {
    throw .managerOnly
  }

  func fetchTeamVoteResults(voteId _: Int) async throws(VoteError) -> TeamVoteResults {
    throw .managerOnly
  }

  func fetchFeedbackResults(voteId _: Int) async throws(VoteError) -> FeedbackResults {
    throw .managerOnly
  }

  func fetchMyResponse(voteId _: Int) async throws(VoteError) -> MyVoteResponse {
    throw .notFound
  }
}

// MARK: - Profile UseCase Stub

final class StubProfileUseCase: ProfileUseCaseInterface, @unchecked Sendable {
  private let profileResult: Result<ProfileEntity, ProfileError>

  init(profile: Result<ProfileEntity, ProfileError>) {
    profileResult = profile
  }

  func getProfile() async throws(ProfileError) -> ProfileEntity {
    switch profileResult {
    case let .success(value): return value
    case let .failure(error): throw error
    }
  }

  func getCachedProfile() async -> ProfileEntity? {
    switch profileResult {
    case let .success(value): return value
    case .failure: return nil
    }
  }

  func refreshProfile() async throws(ProfileError) -> ProfileEntity {
    try await getProfile()
  }

  func editProfile(input _: EditProfileInput) async throws(EditProfileError) -> ProfileEntity {
    throw .invalidTeam
  }
}

// MARK: - MyPage UseCase Stubs

final class StubMyPageUseCase: MyPageUseCaseInterface, @unchecked Sendable {
  private let attendances: Result<AttendanceSummaryResponse, MyPageError>
  private let schedules: Result<[AttendanceMyScheduleResponse], MyPageError>

  init(
    attendances: Result<AttendanceSummaryResponse, MyPageError>,
    schedules: Result<[AttendanceMyScheduleResponse], MyPageError>
  ) {
    self.attendances = attendances
    self.schedules = schedules
  }

  func fetchAttendances() async throws(MyPageError) -> AttendanceSummaryResponse {
    switch attendances {
    case let .success(value): return value
    case let .failure(error): throw error
    }
  }

  func fetchSchedules() async throws(MyPageError) -> [AttendanceMyScheduleResponse] {
    switch schedules {
    case let .success(value): return value
    case let .failure(error): throw error
    }
  }
}

// MARK: - QRCode UseCase Stub

final class StubQRCodeUseCase: QRCodeUseCaseInterface, @unchecked Sendable {
  private let createResult: Result<String, QRCodeError>

  init(createResult: Result<String, QRCodeError>) {
    self.createResult = createResult
  }

  func createQRCode(userID _: Int) async throws(QRCodeError) -> String {
    switch createResult {
    case let .success(value): return value
    case let .failure(error): throw error
    }
  }

  /// 이미지 동등성 비교를 피하려고 항상 nil 을 돌려준다.
  func generateQRCode(from _: String) async -> Image? {
    nil
  }

  func qrValidateCheck(from _: String) async throws(QRCodeError) -> QRValidateEntity {
    throw .invalidPayload
  }
}

// MARK: - Dependency 주입 헬퍼

extension DependencyValues {
  /// Member 화면이 실제로 접근하는 유스케이스를 한 번에 스텁으로 바꾼다.
  mutating func stubMemberUseCases(
    profile: Result<ProfileEntity, ProfileError> = .success(MemberTestFixture.profile),
    attendances: Result<AttendanceSummaryResponse, MyPageError>
      = .success(MemberTestFixture.attendanceSummary),
    schedules: Result<[AttendanceMyScheduleResponse], MyPageError>
      = .success(MemberTestFixture.scheduleResponses),
    vote: StubVoteUseCase = StubVoteUseCase()
  ) {
    profileUseCase = StubProfileUseCase(profile: profile)
    myPageUseCase = StubMyPageUseCase(attendances: attendances, schedules: schedules)
    voteUseCase = vote
  }
}
