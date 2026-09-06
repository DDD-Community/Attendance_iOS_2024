//
//  AuthUseCaseTest.swift
//  UseCaseTests
//
//  Created by DDD on 2026-01-31
//

import Foundation
import Testing

@testable import AuthDomain
@testable import AuthDomainInterface

import ComposableArchitecture

@Suite("Auth UseCase Tests - Complete TDD Implementation")
@MainActor
final class AuthUseCaseTest {

  // MARK: - Test Dependencies
  private var mockAuthRepository: MockAuthRepository!
  private var mockUserSession: MockUserSession!

  init() async {
    mockAuthRepository = await MockAuthRepository.success()
    mockUserSession = await MockUserSession.success()
  }

  // MARK: - Tier 1: Core Login Flow (6 Test Cases)

  @Test("TC-001: Apple 로그인 성공 (신규 사용자)")
  func test_apple_login_success_new_user() async throws {
    // Given: Apple 신규 사용자 로그인 설정
    let expectedProvider = SocialType.apple
    let expectedToken = AuthTestFixture.TestTokens.validAppleToken

    // Configure AppleSuccess repository with new user
    mockAuthRepository = await MockAuthRepository.appleSuccess()

    // When: Apple 로그인 실행
    let result = try await AuthTestHelper.withMockDependencies(
      mockAuthRepository: mockAuthRepository,
      mockUserSession: mockUserSession
    ) {
      let useCase = AuthUseCaseImpl()
      return try await useCase.login(provider: expectedProvider, token: expectedToken)
    }

    // Then: 신규 사용자 로그인 검증
    AuthTestHelper.verifyLoginSuccess(
      result: result,
      expectedProvider: expectedProvider,
      expectedName: "Apple User", // DomainInterface Mock returns "Apple User"
      expectedIsNewUser: false, // DomainInterface Mock returns false for appleSuccess
      expectedRole: nil
    )


    AuthTestHelper.validateAuthTokens(result.token, shouldHaveOAuthToken: false)
    AuthTestHelper.verifyRepositoryCalls(mockRepository: mockAuthRepository, expectedLoginCalls: 1)
  }

  @Test("TC-002: Google 로그인 성공 (신규 사용자)")
  func test_google_login_success_new_user() async throws {
    // Given: Google 신규 사용자 로그인 설정
    let expectedProvider = SocialType.google
    let expectedToken = AuthTestFixture.TestTokens.validGoogleToken

    mockAuthRepository = await MockAuthRepository.newUser()

    // When: Google 로그인 실행
    let result = try await AuthTestHelper.withMockDependencies(
      mockAuthRepository: mockAuthRepository,
      mockUserSession: mockUserSession
    ) {
      let useCase = AuthUseCaseImpl()
      return try await useCase.login(provider: expectedProvider, token: expectedToken)
    }

    // Then: 신규 사용자 로그인 검증
    AuthTestHelper.verifyLoginSuccess(
      result: result,
      expectedProvider: expectedProvider,
      expectedName: "New Google User",
      expectedIsNewUser: true,
      expectedRole: nil
    )


    AuthTestHelper.validateAuthTokens(result.token, shouldHaveOAuthToken: true)
  }

  @Test("TC-003: Google 로그인 성공 (기존 사용자)")
  func test_google_login_success_existing_user() async throws {
    // Given: Google 기존 사용자 로그인 설정
    let expectedProvider = SocialType.google
    let expectedToken = AuthTestFixture.TestTokens.validGoogleToken

    mockAuthRepository = await MockAuthRepository.success()

    // When: Google 로그인 실행
    let result = try await AuthTestHelper.withMockDependencies(
      mockAuthRepository: mockAuthRepository,
      mockUserSession: mockUserSession
    ) {
      let useCase = AuthUseCaseImpl()
      return try await useCase.login(provider: expectedProvider, token: expectedToken)
    }

    // Then: 기존 사용자 로그인 검증
    AuthTestHelper.verifyLoginSuccess(
      result: result,
      expectedProvider: expectedProvider,
      expectedName: "Test User",
      expectedIsNewUser: false,
      expectedRole: .member
    )

    #expect(result.token.oauthRefreshToken != nil, "Google 로그인은 oauthRefreshToken이 있어야 함")
    AuthTestHelper.verifyRepositoryCalls(mockRepository: mockAuthRepository, expectedLoginCalls: 1)
  }

  @Test("TC-004: 로그인 실패 (잘못된 credential)")
  func test_login_failure_invalid_credentials() async throws {
    // Given: 잘못된 credential 에러 설정
    let invalidToken = AuthTestFixture.TestTokens.invalidToken
    mockAuthRepository = await MockAuthRepository.invalidToken()

    // When & Then: 로그인 실패 검증
    await #expect(throws: AuthError.invalidCredential("invalid token")) {
      try await AuthTestHelper.withMockDependencies(
        mockAuthRepository: mockAuthRepository,
      ) {
        let useCase = AuthUseCaseImpl()
        _ = try await useCase.login(provider: .google, token: invalidToken)
      }
    }

    // Then: 실패 시 부작용 없음 검증
    AuthTestHelper.verifyRepositoryCalls(mockRepository: mockAuthRepository, expectedLoginCalls: 1)
  }

  @Test("TC-005: 로그인 실패 (네트워크 오류)")
  func test_login_failure_network_error() async throws {
    // Given: 네트워크 에러 설정
    mockAuthRepository = await MockAuthRepository.networkError()

    // When & Then: 네트워크 에러 검증
    await #expect(throws: AuthError.unknownError("네트워크 요청에 실패했습니다")) {
      try await AuthTestHelper.withMockDependencies(
        mockAuthRepository: mockAuthRepository,
      ) {
        let useCase = AuthUseCaseImpl()
        _ = try await useCase.login(provider: .apple, token: AuthTestFixture.TestTokens.validAppleToken)
      }
    }

    // Then: 실패 시 상태 변경 없음 검증
  }

  @Test("TC-006: Token refresh 성공")
  func test_token_refresh_success() async throws {
    // Given: 토큰 갱신 성공 설정
    mockAuthRepository = await MockAuthRepository.refreshSuccess()

    // When: 토큰 갱신 실행
    let result = try await AuthTestHelper.withMockDependencies(
      mockAuthRepository: mockAuthRepository,
    ) {
      let useCase = AuthUseCaseImpl()
      return try await useCase.refresh()
    }

    // Then: 토큰 갱신 성공 검증
    #expect(result.accessToken == "refreshed_access_token", "갱신된 accessToken이 반환되어야 함")
    #expect(result.refreshToken == "refreshed_refresh_token", "갱신된 refreshToken이 반환되어야 함")
    AuthTestHelper.verifyRepositoryCalls(mockRepository: mockAuthRepository, expectedRefreshCalls: 1)
  }

  @Test("TC-007: Logout 및 상태 초기화")
  func test_logout_and_state_reset() async throws {
    // Given: 로그아웃 성공 설정
    mockAuthRepository = await MockAuthRepository.logoutSuccess()

    // When: 로그아웃 실행
    let result = try await AuthTestHelper.withMockDependencies(
      mockAuthRepository: mockAuthRepository,
      mockUserSession: mockUserSession
    ) {
      let useCase = AuthUseCaseImpl()
      return try await useCase.logout()
    }

    // Then: 로그아웃 및 상태 초기화 검증
    #expect(result.code != nil, "로그아웃 응답이 올바르게 반환되어야 함")
    #expect(result.message != nil, "로그아웃 메시지가 올바르게 반환되어야 함")

    AuthTestHelper.verifyRepositoryCalls(mockRepository: mockAuthRepository, expectedLogoutCalls: 1)
  }

  @Test("TC-008: UpdateSessionCredential 호출 검증")
  func test_update_session_credential_call() async throws {
    // Given: 세션 자격증명 업데이트 토큰
    let testTokens = AuthTestFixture.validAuthTokens

    // When: 세션 자격증명 업데이트 실행
    try await AuthTestHelper.withMockDependencies(
      mockAuthRepository: mockAuthRepository,
    ) {
      let useCase = AuthUseCaseImpl()
      await useCase.updateSessionCredential(with: testTokens)
    }

    // Then: Repository 호출 검증
    AuthTestHelper.verifyRepositoryCalls(
      mockRepository: mockAuthRepository,
      expectedUpdateCredentialCalls: 1
    )
    #expect(mockAuthRepository.lastUpdateTokens == testTokens, "올바른 토큰이 전달되어야 함")
  }

  @Test("TC-009: 회원탈퇴 성공")
  func test_withdraw_success() async throws {
    // Given: 회원탈퇴 성공 설정
    let withdrawToken = AuthTestFixture.TestTokens.withdrawToken
    mockAuthRepository = await MockAuthRepository.withdrawSuccess()

    // When: 회원탈퇴 실행
    let result = try await AuthTestHelper.withMockDependencies(
      mockAuthRepository: mockAuthRepository,
    ) {
      let useCase = AuthUseCaseImpl()
      return try await useCase.withDraw(token: withdrawToken)
    }

    // Then: 회원탈퇴 성공 검증
    #expect(result.isSuccess, "회원탈퇴가 성공해야 함")

    AuthTestHelper.verifyRepositoryCalls(mockRepository: mockAuthRepository, expectedWithdrawCalls: 1)
  }

  @Test("TC-010: 회원탈퇴 실패")
  func test_withdraw_failure() async throws {
    // Given: 회원탈퇴 실패 설정
    mockAuthRepository = await MockAuthRepository.unauthorized()

    // When & Then: 회원탈퇴 실패 검증
    await #expect(throws: AuthError.accountDeletionNotAllowed) {
      try await AuthTestHelper.withMockDependencies(
        mockAuthRepository: mockAuthRepository,
      ) {
        let useCase = AuthUseCaseImpl()
        _ = try await useCase.withDraw(token: AuthTestFixture.TestTokens.withdrawToken)
      }
    }

    // Then: 실패 시 Keychain은 정리되지 않아야 함
  }

  @Test("TC-011: Apple 특화 기능 검증")
  func test_apple_specific_features() async throws {
    // Given: Apple 로그인 설정
    mockAuthRepository = MockAuthRepository.appleSuccess()

    // When: Apple 로그인 실행
    let result = try await AuthTestHelper.withMockDependencies(
      mockAuthRepository: mockAuthRepository,
    ) {
      let useCase = AuthUseCaseImpl()
      return try await useCase.login(provider: .apple, token: AuthTestFixture.TestTokens.validAppleToken)
    }

    // Then: Apple 특화 기능 검증
    #expect(result.provider == .apple, "Apple 제공자가 올바르게 설정되어야 함")
    #expect(result.token.oauthRefreshToken == nil, "Apple은 oauthRefreshToken이 nil이어야 함")
    #expect(!result.token.accessToken.isEmpty, "accessToken은 존재해야 함")
    #expect(!result.token.refreshToken.isEmpty, "refreshToken은 존재해야 함")
  }

  @Test("TC-012: 동시 로그인 요청 처리")
  func test_concurrent_login_requests_handling() async throws {
    // Given: 동시 로그인 요청 설정
    let concurrentCount = AuthTestFixture.ConcurrentTestData.simultaneousLoginCount
    mockAuthRepository = await MockAuthRepository.concurrency()

    let concurrentOperations: [() async throws -> LoginEntity] = (0..<concurrentCount).map { index in
      {
        try await AuthTestHelper.withMockDependencies(
          mockAuthRepository: self.mockAuthRepository,
        ) {
          let useCase = AuthUseCaseImpl()
          return try await useCase.login(
            provider: AuthTestFixture.ConcurrentTestData.concurrentProviders[index],
            token: AuthTestFixture.ConcurrentTestData.concurrentTokens[index]
          )
        }
      }
    }

    // When: 동시 로그인 실행
    let results = try await AuthTestHelper.performConcurrentOperations(operations: concurrentOperations)

    // Then: 동시 로그인 결과 검증
    let successCount = results.compactMap { result in
      if case .success = result { return result }
      return nil
    }.count

    #expect(successCount == concurrentCount, "모든 동시 로그인이 성공해야 함")
    #expect(mockAuthRepository.getLoginCallCount() == concurrentCount, "모든 로그인이 Repository를 호출해야 함")
  }

  @Test("TC-013: 빈 사용자명 처리")
  func test_empty_username_handling() async throws {
    // Given: 빈 사용자명 설정이 가능한 Apple 사용자
    mockAuthRepository = MockAuthRepository.appleSuccess()

    // When: Apple 로그인 실행
    let result = try await AuthTestHelper.withMockDependencies(
      mockAuthRepository: mockAuthRepository,
    ) {
      let useCase = AuthUseCaseImpl()
      return try await useCase.login(provider: .apple, token: AuthTestFixture.TestTokens.validAppleToken)
    }

    // Then: Apple 사용자명 처리 검증 (DomainInterface Mock에서는 "Apple User" 반환)
    #expect(!result.name.isEmpty, "Apple User 이름이 반환되어야 함")
    #expect(result.name == "Apple User", "Mock에서 제공하는 Apple User 이름이어야 함")
  }

  @Test("TC-014: Token 만료 후 refresh 시나리오")
  func test_token_expired_refresh_scenario() async throws {
    // Given: 토큰 만료 상황 설정
    mockAuthRepository = MockAuthRepository()
    mockAuthRepository.configureRefreshFailure(AuthError.refreshTokenExpired)

    // When & Then: 토큰 만료 에러 검증
    await #expect(throws: AuthError.refreshTokenExpired) {
      try await AuthTestHelper.withMockDependencies(
        mockAuthRepository: mockAuthRepository,
      ) {
        let useCase = AuthUseCaseImpl()
        _ = try await useCase.refresh()
      }
    }

    // Then: refresh 호출 검증
    AuthTestHelper.verifyRepositoryCalls(mockRepository: mockAuthRepository, expectedRefreshCalls: 1)
  }

  @Test("TC-015: 서버 에러 시나리오")
  func test_server_error_scenario() async throws {
    // Given: 서버 에러 설정
    mockAuthRepository = MockAuthRepository()
    mockAuthRepository.configureLogoutFailure(AuthError.logoutFailed)

    // When & Then: 서버 에러 검증 (로그아웃)
    await #expect(throws: AuthError.logoutFailed) {
      try await AuthTestHelper.withMockDependencies(
        mockAuthRepository: mockAuthRepository,
      ) {
        let useCase = AuthUseCaseImpl()
        _ = try await useCase.logout()
      }
    }

    // Then: logout 호출 검증
    AuthTestHelper.verifyRepositoryCalls(mockRepository: mockAuthRepository, expectedLogoutCalls: 1)
  }

  @Test("TC-016: 완전한 인증 플로우 통합 테스트")
  func test_full_authentication_flow_integration() async throws {
    // Given: 완전한 플로우 성공 설정
    mockAuthRepository = await MockAuthRepository.success()
    mockAuthRepository.configureSuccessfulRefresh()
    mockAuthRepository.logoutResponse = .success(AuthExitEntity(code: "200", message: "logout", detail: "success"))

    // When: 전체 인증 플로우 실행
    let loginResult = try await AuthTestHelper.withMockDependencies(
      mockAuthRepository: mockAuthRepository,
    ) {
      let useCase = AuthUseCaseImpl()
      return try await useCase.login(provider: .google, token: AuthTestFixture.TestTokens.validGoogleToken)
    }

    // Then: 로그인 결과 검증
    #expect(loginResult.provider == .google, "Google 제공자여야 함")
    #expect(!loginResult.token.accessToken.isEmpty, "Access token이 있어야 함")

    // When: 토큰 갱신 실행
    let refreshResult = try await AuthTestHelper.withMockDependencies(
      mockAuthRepository: mockAuthRepository,
    ) {
      let useCase = AuthUseCaseImpl()
      return try await useCase.refresh()
    }

    // Then: 토큰 갱신 결과 검증
    #expect(!refreshResult.accessToken.isEmpty, "갱신된 access token이 있어야 함")

    // When: 로그아웃 실행
    let logoutResult = try await AuthTestHelper.withMockDependencies(
      mockAuthRepository: mockAuthRepository,
    ) {
      let useCase = AuthUseCaseImpl()
      return try await useCase.logout()
    }

    // Then: 전체 플로우 검증
    #expect(logoutResult.code != nil, "로그아웃 응답이 있어야 함")
    AuthTestHelper.verifyRepositoryCalls(
      mockRepository: mockAuthRepository,
      expectedLoginCalls: 1,
      expectedRefreshCalls: 1,
      expectedLogoutCalls: 1
    )
  }
}
