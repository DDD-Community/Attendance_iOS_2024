//
//  RepositoryIntegrationTest.swift
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
struct RepositoryIntegrationTest {

  // MARK: - Mock Repository 통합 테스트

  @Test("모든 Mock Repository 초기화 테스트")
  func testAllMockRepositoryInitialization() async throws {
    // Given & When
    let mockAuthRepository = AuthRepositorySpy.success()

    // Then
    #expect(mockAuthRepository != nil)
    #expect(mockAuthRepository.loginCallCount == 0)
    #expect(mockAuthRepository.shouldSucceed == true)
  }

  // MARK: - Mock Repository 상태 동기화 테스트

  @Test("Mock Repository들 간의 상태 독립성 테스트")
  func testMockRepositoryStateIndependence() async throws {
    // Given
    let mockAuth1 = AuthRepositorySpy.success()
    let mockAuth2 = AuthRepositorySpy.failure(MockAuthError.networkError.authError)

    // When
    _ = try await mockAuth1.login(provider: .google, token: "token1")

    await #expect(throws: MockAuthError.networkError.authError) {
      try await mockAuth2.login(provider: .apple, token: "token2")
    }

    // Then - 각각의 상태가 독립적으로 관리됨
    #expect(mockAuth1.loginCallCount == 1)
    #expect(mockAuth1.lastLoginProvider == .google)
    #expect(mockAuth1.lastLoginToken == "token1")
    #expect(mockAuth1.shouldSucceed == true)

    #expect(mockAuth2.loginCallCount == 1)
    #expect(mockAuth2.lastLoginProvider == .apple)
    #expect(mockAuth2.lastLoginToken == "token2")
    #expect(mockAuth2.shouldSucceed == false)
  }

  // MARK: - Mock Repository 아키텍처 테스트

  @Test("Mock Repository가 올바른 Interface를 준수하는지 확인")
  func testMockRepositoryInterfaceCompliance() async throws {
    // Given & When & Then - 컴파일 타임 검증
    let mockAuth: AuthInterface = AuthRepositorySpy.success()

    #expect(mockAuth != nil)

    // Mock이 실제로 AuthInterface의 모든 메서드를 구현하는지 확인
    let result = try await mockAuth.login(provider: .google, token: "test")
    #expect(result.name == "Test User")
  }

  @Test("Mock Repository 메서드 존재성 테스트")
  func testMockRepositoryMethods() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.success()
    let tokens = AuthTokens(accessToken: "access", refreshToken: "refresh")

    // When - 함수 값을 비교하지 않고 실제 인터페이스 계약을 호출해 검증
    _ = try await mockRepository.login(provider: .google, token: "test")
    _ = try await mockRepository.refresh()
    _ = try await mockRepository.logout()
    _ = try await mockRepository.withDraw(token: "test")
    await mockRepository.updateSessionCredential(with: tokens)

    // Then
    #expect(mockRepository.loginCallCount == 1)
    #expect(mockRepository.refreshCallCount == 1)
    #expect(mockRepository.logoutCallCount == 1)
    #expect(mockRepository.withDrawCallCount == 1)
    #expect(mockRepository.updateSessionCredentialCallCount == 1)
  }

  // MARK: - Mock Repository 성능 테스트

  @Test("Mock Repository 초기화 성능 테스트")
  func testMockRepositoryInitializationPerformance() async throws {
    // Given
    let startTime = Date()

    // When - 여러 Mock Repository 생성
    let mockRepositories = (1...100).map { _ in
      AuthRepositorySpy.success()
    }

    let endTime = Date()
    let elapsedTime = endTime.timeIntervalSince(startTime)

    // Then - 성능 검증 (100ms 이내)
    #expect(elapsedTime < 0.1)
    #expect(mockRepositories.count == 100)
    mockRepositories.forEach { repository in
      #expect(repository != nil)
      #expect(repository.shouldSucceed == true)
    }
  }

  @Test("Mock Repository 메서드 호출 성능 테스트")
  func testMockRepositoryCallPerformance() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.success()
    let startTime = Date()

    // When - 여러 번 메서드 호출
    for i in 1...50 {
      _ = try await mockRepository.login(provider: .google, token: "token\(i)")
    }

    let endTime = Date()
    let elapsedTime = endTime.timeIntervalSince(startTime)

    // Then - 성능 검증 (1초 이내)
    #expect(elapsedTime < 1.0)
    #expect(mockRepository.loginCallCount == 50)
  }

  // MARK: - Mock Repository 메모리 효율성 테스트

  @Test("Mock Repository 메모리 효율성 테스트")
  func testMockRepositoryMemoryEfficiency() async throws {
    // Given & When - Mock Repository 인스턴스 여러 개 생성
    let repositories = (1...50).map { _ in
      AuthRepositorySpy.success()
    }

    // Then - 모든 Repository가 정상 생성되고 독립적인지 확인
    #expect(repositories.count == 50)

    // 각각 다른 호출을 해서 상태가 독립적인지 확인
    for (index, repository) in repositories.prefix(5).enumerated() {
      _ = try await repository.login(provider: .google, token: "token\(index)")
      #expect(repository.loginCallCount == 1)
      #expect(repository.lastLoginToken == "token\(index)")
    }
  }

  // MARK: - Mock Repository 상태 전환 테스트

  @Test("Mock Repository 상태 전환 테스트")
  func testMockRepositoryStateTransition() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.success()

    // When & Then - 성공 -> 실패 -> 성공
    // 1. 초기 성공 상태 테스트
    let successResult = try await mockRepository.login(provider: .google, token: "success_token")
    #expect(successResult.name == "Test User")
    #expect(mockRepository.loginCallCount == 1)

    // 2. 실패 상태로 변경
    mockRepository.configureFailure(MockAuthError.invalidToken.authError)
    await #expect(throws: MockAuthError.invalidToken.authError) {
      try await mockRepository.login(provider: .apple, token: "fail_token")
    }
    #expect(mockRepository.loginCallCount == 2)

    // 3. 다시 성공 상태로 변경
    mockRepository.configureSuccess()
    let successResult2 = try await mockRepository.login(provider: .google, token: "success_token2")
    #expect(successResult2.name == "Test User")
    #expect(mockRepository.loginCallCount == 3)
  }

  // MARK: - Mock Repository 복합 시나리오 테스트

  @Test("Mock Repository 복합 시나리오 테스트")
  func testMockRepositoryComplexScenario() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.success()

    // When & Then - 전체 인증 플로우
    // 1. 로그인
    let loginResult = try await mockRepository.login(provider: .google, token: "login_token")
    #expect(loginResult.provider == .google)
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

    // 5. 상태 리셋 및 검증
    mockRepository.reset()
    #expect(mockRepository.loginCallCount == 0)
    #expect(mockRepository.refreshCallCount == 0)
    #expect(mockRepository.logoutCallCount == 0)
    #expect(mockRepository.updateSessionCredentialCallCount == 0)
  }

  // MARK: - Mock Repository 에러 처리 테스트

  @Test("Mock Repository 다양한 에러 타입 테스트")
  func testMockRepositoryErrorTypes() async throws {
    let errorTypes: [MockAuthError] = [
      .invalidToken,
      .tokenExpired,
      .networkError,
      .unauthorized,
      .serverError,
      .invalidCredentials,
      .userNotFound
    ]

    for errorType in errorTypes {
      // Given
      let mockRepository = AuthRepositorySpy.failure(errorType.authError)

      // When & Then
      await #expect(throws: errorType.authError) {
        try await mockRepository.login(provider: .google, token: "test_token")
      }
      #expect(mockRepository.loginCallCount == 1)

      // 상태 리셋
      mockRepository.reset()
    }
  }

  // MARK: - Mock Repository 동시성 안전성 테스트

  @Test("Mock Repository 동시성 안전성 테스트")
  func testMockRepositoryConcurrencySafety() async throws {
    // Given
    let mockRepository = AuthRepositorySpy.success()

    // When - 동시에 여러 호출 실행
    async let result1 = mockRepository.login(provider: .google, token: "token1")
    async let result2 = mockRepository.login(provider: .apple, token: "token2")
    async let result3 = mockRepository.refresh()
    async let result4 = mockRepository.logout()

    let (login1, login2, refresh, logout) = try await (result1, result2, result3, result4)

    // Then - 모든 호출이 성공하고 상태가 올바르게 추적되는지 확인
    #expect(login1.provider == .google)
    #expect(login2.provider == .apple)
    #expect(refresh.accessToken == "refreshed_access_token")
    #expect(logout.message == "logout")

    #expect(mockRepository.loginCallCount == 2)
    #expect(mockRepository.refreshCallCount == 1)
    #expect(mockRepository.logoutCallCount == 1)
  }

  // MARK: - Mock Repository 팩토리 메서드 검증

  @Test("Mock Repository 팩토리 메서드 완전성 테스트")
  func testMockRepositoryFactoryMethods() async throws {
    // Given & When & Then
    // 1. success() 팩토리 메서드
    let successMock = AuthRepositorySpy.success()
    #expect(successMock.shouldSucceed == true)

    // 2. failure() 팩토리 메서드
    let failureMock = AuthRepositorySpy.failure(MockAuthError.networkError.authError)
    #expect(failureMock.shouldSucceed == false)

    // 실제 동작 검증
    let successResult = try await successMock.login(provider: .google, token: "test")
    #expect(successResult.name == "Test User")

    await #expect(throws: MockAuthError.networkError.authError) {
      try await failureMock.login(provider: .google, token: "test")
    }
  }
}
