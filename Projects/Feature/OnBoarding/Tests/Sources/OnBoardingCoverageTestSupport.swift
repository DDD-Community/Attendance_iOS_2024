//
//  OnBoardingCoverageTestSupport.swift
//  OnBoardingTests
//
//  OnBoarding 커버리지 테스트가 공유하는 스텁과 픽스처.
//  구현 코드는 건드리지 않고, 도메인 의존성만 결정적인 값으로 대체한다.
//

import Foundation

import OnBoardingDomainInterface
import ProfileDomainInterface

import ComposableArchitecture

// MARK: - UseCase Stub

struct StubOnBoardingRepository: OnBoardingInterface, OnBoardingUseCaseInterface, @unchecked Sendable {
  var teams: [SelectTeamEntity] = []
  var jobs: [SelectJob] = []
  var managings: [SelectManaging] = []
  var verifiedCode: VerifyCodeEntity = .init(generationID: 0, type: .member)
  var failure: OnBoardingError?

  func verifyCode(code _: String) async throws(OnBoardingError) -> VerifyCodeEntity {
    if let failure = failure { throw failure }
    return verifiedCode
  }

  func fetchJobs() async throws(OnBoardingError) -> [SelectJob] {
    if let failure = failure { throw failure }
    return jobs
  }

  func fetchTeams(generationId _: Int) async throws(OnBoardingError) -> [SelectTeamEntity] {
    if let failure = failure { throw failure }
    return teams
  }

  func fetchManaging() async throws(OnBoardingError) -> [SelectManaging] {
    if let failure = failure { throw failure }
    return managings
  }
}

// MARK: - UseCase Stubs

struct StubSignUpUseCase: SignUpUseCaseInterface, @unchecked Sendable {
  var registered: SignUpUser = OnBoardingCoverageFixture.signUpUser
  var failure: SignUpError?

  func registerUser(userSession _: UserSession) async throws(SignUpError) -> SignUpUser {
    if let failure = failure { throw failure }
    return registered
  }
}

struct StubProfileUseCase: ProfileUseCaseInterface, @unchecked Sendable {
  var profile: ProfileEntity = OnBoardingCoverageFixture.managerProfile
  var editFailure: EditProfileError?

  func getProfile() async throws(ProfileError) -> ProfileEntity {
    profile
  }

  func getCachedProfile() async -> ProfileEntity? {
    profile
  }

  func refreshProfile() async throws(ProfileError) -> ProfileEntity {
    profile
  }

  func editProfile(input _: EditProfileInput) async throws(EditProfileError) -> ProfileEntity {
    if let editFailure = editFailure { throw editFailure }
    return profile
  }
}

// MARK: - Fixtures

/// 저장 프로퍼티 대신 계산 프로퍼티로 둔다.
/// (Entity 타입들이 Sendable 이 아니라 static let 으로 두면 동시성 진단에 걸린다)
enum OnBoardingCoverageFixture {
  static var iosTeam: SelectTeamEntity {
    SelectTeamEntity(teamId: 1, teams: .ios1)
  }

  static var webTeam: SelectTeamEntity {
    SelectTeamEntity(teamId: 2, teams: .web1)
  }

  static var teams: [SelectTeamEntity] {
    [iosTeam, webTeam]
  }

  static var iosJob: SelectJob {
    SelectJob(jobKeys: "IOS", job: .ios)
  }

  static var backendJob: SelectJob {
    SelectJob(jobKeys: "BE", job: .backend)
  }

  static var jobs: [SelectJob] {
    [iosJob, backendJob]
  }

  static var photoManaging: SelectManaging {
    SelectManaging(managingKeys: "PHOTO", managing: .photo)
  }

  static var teamManaging: SelectManaging {
    SelectManaging(managingKeys: "TEAM_MANAGING", managing: .teamManaging)
  }

  static var managings: [SelectManaging] {
    [photoManaging, teamManaging]
  }

  static var signUpUser: SignUpUser {
    SignUpUser(
      name: "김철수",
      email: "chulsoo@ddd.com",
      generation: "11기",
      team: .ios1,
      managing: [],
      selectPart: .ios
    )
  }

  static var managerProfile: ProfileEntity {
    ProfileEntity(
      userID: 7,
      name: "김영희",
      generation: "11기",
      team: .ios1,
      jobRole: .ios,
      role: .manager,
      manger: [.teamManaging]
    )
  }

  static var memberProfile: ProfileEntity {
    ProfileEntity(
      userID: 9,
      name: "박민수",
      generation: "12기",
      team: .web1,
      jobRole: .backend,
      role: .member,
      manger: nil
    )
  }

  static var managerCode: VerifyCodeEntity {
    VerifyCodeEntity(generationID: 13, type: .manager)
  }

  static var memberCode: VerifyCodeEntity {
    VerifyCodeEntity(generationID: 14, type: .member)
  }
}
