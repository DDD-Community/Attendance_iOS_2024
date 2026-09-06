//
//  AuthRepositoryTest.swift
//  Repository
//
//  Created by DDD on 4/17/26.
//

import Foundation
import Testing

@testable import AppUpdateDomain
@testable import AttendanceDomain
@testable import AuthDomain
import AuthDomainInterface
@testable import MyPageDomain
@testable import OnBoardingDomain
@testable import ProfileDomain
@testable import QRCodeDomain
@testable import ScheduleDomain
@testable import VoteDomain

@MainActor
struct AuthRepositoryTest {

  // MARK: - 로그인 테스트

  @Test("로그인 성공 테스트 - Google 로그인")
  func testLoginSuccess_Google() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.success()

    // When
    let result = try await mockRepository.login(provider: .google, token: "google_test_token")

    // Then
    #expect(result.name == "Test User")
    #expect(result.isNewUser == false)
    #expect(result.provider == .google)
    #expect(result.role == .member)
    #expect(result.token.accessToken == "mock_access_token")
    #expect(mockRepository.loginCallCount == 1)
    #expect(mockRepository.lastLoginProvider == .google)
    #expect(mockRepository.lastLoginToken == "google_test_token")
  }

  @Test("로그인 성공 테스트 - Apple 로그인")
  func testLoginSuccess_Apple() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.success()

    // When
    let result = try await mockRepository.login(provider: .apple, token: "apple_test_token")

    // Then
    #expect(result.name == "Test User")
    #expect(result.provider == .apple)
    #expect(mockRepository.loginCallCount == 1)
    #expect(mockRepository.lastLoginProvider == .apple)
  }

  @Test("로그인 실패 테스트 - 잘못된 토큰")
  func testLoginFailure_InvalidToken() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.failure(MockAuthError.invalidToken.authError)

    // When & Then
    await #expect(throws: MockAuthError.invalidToken.authError) {
      try await mockRepository.login(provider: .google, token: "invalid_token")
    }
    #expect(mockRepository.loginCallCount == 1)
  }

  @Test("로그인 실패 테스트 - 네트워크 오류")
  func testLoginFailure_NetworkError() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.failure(MockAuthError.networkError.authError)

    // When & Then
    await #expect(throws: MockAuthError.networkError.authError) {
      try await mockRepository.login(provider: .google, token: "test_token")
    }
    #expect(mockRepository.loginCallCount == 1)
  }

  // MARK: - 토큰 재발급 테스트

  @Test("토큰 재발급 성공 테스트")
  func testRefreshSuccess() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.success()

    // When
    let result = try await mockRepository.refresh()

    // Then
    #expect(result.accessToken == "refreshed_access_token")
    #expect(result.refreshToken == "refreshed_refresh_token")
    #expect(mockRepository.refreshCallCount == 1)
  }

  @Test("토큰 재발급 실패 테스트 - 만료된 토큰")
  func testRefreshFailure_ExpiredToken() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.failure(MockAuthError.tokenExpired.authError)

    // When & Then
    await #expect(throws: MockAuthError.tokenExpired.authError) {
      try await mockRepository.refresh()
    }
    #expect(mockRepository.refreshCallCount == 1)
  }

  // MARK: - 로그아웃 테스트

  @Test("로그아웃 성공 테스트")
  func testLogoutSuccess() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.success()

    // When
    let result = try await mockRepository.logout()

    // Then
    #expect(result.code == "200")
    #expect(result.message == "logout")
    #expect(result.detail == "success")
    #expect(mockRepository.logoutCallCount == 1)
  }

  @Test("로그아웃 실패 테스트 - 서버 오류")
  func testLogoutFailure_ServerError() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.failure(MockAuthError.serverError.authError)

    // When & Then
    await #expect(throws: MockAuthError.serverError.authError) {
      try await mockRepository.logout()
    }
    #expect(mockRepository.logoutCallCount == 1)
  }

  // MARK: - 계정 삭제 테스트

  @Test("계정 삭제 성공 테스트")
  func testWithdrawSuccess() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.success()

    // When
    let result = try await mockRepository.withDraw(token: "withdraw_token")

    // Then
    #expect(result.isSuccess == true)
    #expect(result.code == "200")
    #expect(result.message == "withdraw")
    #expect(mockRepository.withDrawCallCount == 1)
    #expect(mockRepository.lastWithdrawToken == "withdraw_token")
  }

  @Test("계정 삭제 실패 테스트 - 권한 없음")
  func testWithdrawFailure_Unauthorized() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.failure(MockAuthError.unauthorized.authError)

    // When & Then
    await #expect(throws: MockAuthError.unauthorized.authError) {
      try await mockRepository.withDraw(token: "invalid_token")
    }
    #expect(mockRepository.withDrawCallCount == 1)
  }

  // MARK: - 세션 Credential 업데이트 테스트

  @Test("세션 Credential 업데이트 테스트")
  func testUpdateSessionCredential() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.success()
    let tokens = AuthTokens(
      accessToken: "new_access_token",
      refreshToken: "new_refresh_token",
      oauthRefreshToken: "new_oauth_token"
    )

    // When
    await mockRepository.updateSessionCredential(with: tokens)

    // Then
    #expect(mockRepository.updateSessionCredentialCallCount == 1)
    #expect(mockRepository.lastUpdateTokens?.accessToken == "new_access_token")
    #expect(mockRepository.lastUpdateTokens?.refreshToken == "new_refresh_token")
    #expect(mockRepository.lastUpdateTokens?.oauthRefreshToken == "new_oauth_token")
  }

  // MARK: - 동시성 테스트

  @Test("동시 로그인 요청 테스트")
  func testConcurrentLoginRequests() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.success()

    // When
    async let result1 = mockRepository.login(provider: .google, token: "token1")
    async let result2 = mockRepository.login(provider: .apple, token: "token2")

    let (login1, login2) = try await (result1, result2)

    // Then
    #expect(login1.provider == .google)
    #expect(login2.provider == .apple)
    #expect(mockRepository.loginCallCount == 2)
  }

  // MARK: - 통합 플로우 테스트

  @Test("전체 인증 플로우 테스트 - 로그인부터 로그아웃까지")
  func testFullAuthFlow() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.success()

    // When & Then
    // 1. 로그인
    let loginResult = try await mockRepository.login(provider: .google, token: "test_token")
    #expect(loginResult.name == "Test User")
    #expect(mockRepository.loginCallCount == 1)

    // 2. 토큰 재발급
    let refreshResult = try await mockRepository.refresh()
    #expect(refreshResult.accessToken == "refreshed_access_token")
    #expect(mockRepository.refreshCallCount == 1)

    // 3. 세션 업데이트
    await mockRepository.updateSessionCredential(with: refreshResult)
    #expect(mockRepository.updateSessionCredentialCallCount == 1)

    // 4. 로그아웃
    let logoutResult = try await mockRepository.logout()
    #expect(logoutResult.message == "logout")
    #expect(mockRepository.logoutCallCount == 1)
  }

  // MARK: - 에러 핸들링 테스트

  @Test("다양한 에러 상황 테스트")
  func testErrorHandling() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.failure(MockAuthError.serverError.authError)

    // When & Then
    await #expect(throws: MockAuthError.serverError.authError) {
      try await mockRepository.login(provider: .google, token: "test_token")
    }

    await #expect(throws: MockAuthError.serverError.authError) {
      try await mockRepository.refresh()
    }

    await #expect(throws: MockAuthError.serverError.authError) {
      try await mockRepository.logout()
    }

    await #expect(throws: MockAuthError.serverError.authError) {
      try await mockRepository.withDraw(token: "test_token")
    }

    // 모든 메서드가 호출되었는지 확인
    #expect(mockRepository.loginCallCount == 1)
    #expect(mockRepository.refreshCallCount == 1)
    #expect(mockRepository.logoutCallCount == 1)
    #expect(mockRepository.withDrawCallCount == 1)
  }

  // MARK: - Mock Repository 상태 관리 테스트

  @Test("Mock Repository 상태 초기화 테스트")
  func testMockRepositoryStateReset() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.success()

    // When - 첫 번째 호출
    _ = try await mockRepository.login(provider: .google, token: "first_token")
    #expect(mockRepository.loginCallCount == 1)
    #expect(mockRepository.lastLoginToken == "first_token")

    // When - 상태 초기화
    mockRepository.reset()

    // Then - 상태가 초기화되었는지 확인
    #expect(mockRepository.loginCallCount == 0)
    #expect(mockRepository.lastLoginToken == nil)

    // When - 두 번째 호출
    _ = try await mockRepository.login(provider: .apple, token: "second_token")

    // Then - 카운트가 다시 1부터 시작
    #expect(mockRepository.loginCallCount == 1)
    #expect(mockRepository.lastLoginToken == "second_token")
  }

  // MARK: - Mock Repository 팩토리 메서드 테스트

  @Test("Mock Repository success() 팩토리 메서드 테스트")
  func testMockRepositorySuccessFactory() async throws {
    // Given & When
    let mockRepository = AuthRepositorySpy.success()

    // Then
    #expect(mockRepository.shouldSucceed == true)
    #expect(mockRepository.loginCallCount == 0) // 아직 호출되지 않음

    // 실제 호출 시 성공하는지 확인
    let result = try await mockRepository.login(provider: .google, token: "test_token")
    #expect(result.name == "Test User")
    #expect(mockRepository.loginCallCount == 1)
  }

  @Test("Mock Repository failure() 팩토리 메서드 테스트")
  func testMockRepositoryFailureFactory() async throws {
    // Given & When
    let mockRepository = AuthRepositorySpy.failure(MockAuthError.networkError.authError)

    // Then
    #expect(mockRepository.shouldSucceed == false)
    #expect(mockRepository.loginCallCount == 0)

    // 실제 호출 시 실패하는지 확인
    await #expect(throws: MockAuthError.networkError.authError) {
      try await mockRepository.login(provider: .google, token: "test_token")
    }
    #expect(mockRepository.loginCallCount == 1)
  }

  // MARK: - Mock Repository 검증 테스트

  @Test("Mock Repository 호출 추적 정확성 테스트")
  func testMockRepositoryCallTrackingAccuracy() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.success()

    // When - 다양한 메서드 호출
    _ = try await mockRepository.login(provider: .google, token: "token1")
    _ = try await mockRepository.login(provider: .apple, token: "token2")
    _ = try await mockRepository.refresh()
    _ = try await mockRepository.logout()
    _ = try await mockRepository.withDraw(token: "withdraw_token")

    let tokens = AuthTokens(accessToken: "test", refreshToken: "test")
    await mockRepository.updateSessionCredential(with: tokens)

    // Then - 호출 추적 정확성 검증
    #expect(mockRepository.loginCallCount == 2)
    #expect(mockRepository.refreshCallCount == 1)
    #expect(mockRepository.logoutCallCount == 1)
    #expect(mockRepository.withDrawCallCount == 1)
    #expect(mockRepository.updateSessionCredentialCallCount == 1)

    #expect(mockRepository.lastLoginProvider == .apple)
    #expect(mockRepository.lastLoginToken == "token2")
    #expect(mockRepository.lastWithdrawToken == "withdraw_token")
    #expect(mockRepository.lastUpdateTokens?.accessToken == "test")
  }
}
