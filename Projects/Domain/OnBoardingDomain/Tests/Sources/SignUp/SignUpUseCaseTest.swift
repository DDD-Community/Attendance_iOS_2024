//
//  SignUpUseCaseTest.swift
//  OnBoardingDomainTests
//
//  Created by DDD on 9/4/26.
//

import Testing

import AuthDomainInterface
@testable import OnBoardingDomain
import OnBoardingDomainInterface

import ComposableArchitecture

@Suite("SignUp UseCase", .serialized)
@MainActor
struct SignUpUseCaseTest {
  @Test("멤버가 팀을 선택하지 않으면 Repository를 호출하지 않는다")
  func memberRequiresTeam() async {
    let repository = SignUpRepositorySpy()
    let session = makeSession(userRole: .member, selectTeamId: nil)

    await #expect(throws: SignUpError.missingRequiredField("팀")) {
      try await execute(
        session: session,
        repository: repository,
        authRepository: MockAuthRepository.success()
      )
    }
    #expect(repository.callCount == 0)
  }

  @Test("Google 멤버 가입 입력과 로그인 토큰을 전달한다")
  func registersGoogleMember() async throws {
    let repository = SignUpRepositorySpy()
    let authRepository = MockAuthRepository.success()
    let session = makeSession(
      userRole: .member,
      provider: .google,
      selectTeamId: 2,
      token: "google-token",
      accessToken: "unused-access-token",
      oauthRefreshToken: "unused-refresh-token"
    )

    let result = try await execute(
      session: session,
      repository: repository,
      authRepository: authRepository
    )

    #expect(result == repository.response)
    #expect(repository.lastInput?.teamId == 2)
    #expect(repository.lastInput?.managerRoles == nil)
    #expect(repository.lastInput?.token == "google-token")
    #expect(repository.lastInput?.oauthRefreshToken == nil)
    #expect(authRepository.getLastLoginProvider() == .google)
    #expect(authRepository.getLastLoginToken() == "google-token")
  }

  @Test("Apple 운영진 가입은 관리 권한과 Apple 토큰을 전달한다")
  func registersAppleManager() async throws {
    let repository = SignUpRepositorySpy()
    let authRepository = MockAuthRepository.success()
    let session = makeSession(
      userRole: .manager,
      managing: [.teamManaging, .scheduleReminder],
      provider: .apple,
      selectTeamId: nil,
      token: "authorization-code",
      accessToken: "apple-id-token",
      oauthRefreshToken: "apple-refresh-token"
    )

    _ = try await execute(
      session: session,
      repository: repository,
      authRepository: authRepository
    )

    #expect(repository.lastInput?.teamId == nil)
    #expect(repository.lastInput?.managerRoles == [.teamManaging, .scheduleReminder])
    #expect(repository.lastInput?.token == "apple-id-token")
    #expect(repository.lastInput?.oauthRefreshToken == "apple-refresh-token")
    #expect(authRepository.getLastLoginProvider() == .apple)
    #expect(authRepository.getLastLoginToken() == "apple-id-token")
  }

  @Test("가입 후 로그인 실패는 가입 성공을 취소하지 않는다")
  func ignoresBestEffortLoginFailure() async throws {
    let repository = SignUpRepositorySpy()
    let authRepository = MockAuthRepository.invalidToken()

    let result = try await execute(
      session: makeSession(selectTeamId: 1),
      repository: repository,
      authRepository: authRepository
    )

    #expect(result == repository.response)
    #expect(repository.callCount == 1)
    #expect(authRepository.getLoginCallCount() == 1)
  }

  @Test("가입 요청 실패는 오류를 전달하고 로그인하지 않는다")
  func forwardsRegistrationFailure() async {
    let repository = SignUpRepositorySpy(result: .failure(.accountAlreadyExists))
    let authRepository = MockAuthRepository.success()

    await #expect(throws: SignUpError.accountAlreadyExists) {
      try await execute(
        session: makeSession(selectTeamId: 1),
        repository: repository,
        authRepository: authRepository
      )
    }

    #expect(repository.callCount == 1)
    #expect(authRepository.getLoginCallCount() == 0)
  }

  private func execute(
    session: UserSession,
    repository: SignUpRepositorySpy,
    authRepository: MockAuthRepository
  ) async throws -> SignUpUser {
    try await withDependencies {
      $0.signUpRepository = repository
      $0.authUseCase = authRepository
    } operation: {
      try await SignUpUseCaseImpl().registerUser(userSession: session)
    }
  }

  private func makeSession(
    userRole: Staff = .member,
    managing: [StaffManaging] = [],
    provider: SocialType = .google,
    selectTeamId: Int? = 1,
    token: String = "google-token",
    accessToken: String = "apple-id-token",
    oauthRefreshToken: String? = "apple-refresh-token"
  ) -> UserSession {
    UserSession(
      name: "테스트 사용자",
      selectPart: .ios,
      userRole: userRole,
      managing: managing,
      provider: provider,
      selectTeamId: selectTeamId,
      token: token,
      generationId: 12,
      accessToken: accessToken,
      oauthRefreshToken: oauthRefreshToken,
      inviteCode: "INVITE"
    )
  }
}

@MainActor
private final class SignUpRepositorySpy: SignUpInterface {
  let response = SignUpUser(
    name: "테스트 사용자",
    email: "test@example.com",
    generation: "12기",
    team: .ios1,
    managing: nil,
    selectPart: .ios
  )
  private let result: Result<SignUpUser, SignUpError>?
  private(set) var callCount = 0
  private(set) var lastInput: SignUpUserInput?

  init(result: Result<SignUpUser, SignUpError>? = nil) {
    self.result = result
  }

  func registerUser(input: SignUpUserInput) async throws(SignUpError) -> SignUpUser {
    callCount += 1
    lastInput = input
    return try result?.get() ?? response
  }
}
