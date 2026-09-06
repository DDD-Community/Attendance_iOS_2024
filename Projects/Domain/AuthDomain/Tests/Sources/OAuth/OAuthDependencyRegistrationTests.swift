//
//  OAuthDependencyRegistrationTests.swift
//  UseCaseTests
//
//  Created by DDD on 9/1/26.
//

import Testing

@testable import AuthDomain
import AuthDomainInterface

import Dependencies
import Sharing

@Suite("OAuth 라이브 의존성 등록", .serialized)
struct OAuthDependencyRegistrationTests {
  @Test("Google 로그인 결과가 프로필 API 역할 선택값을 갱신한다")
  @MainActor
  func googleLoginSynchronizesPersistedRole() async throws {
    @Shared(.staffRole) var staffRole
    $staffRole.withLock { $0 = .manager }
    defer { $staffRole.withLock { $0 = nil } }

    let authRepository = MockAuthRepository()
    authRepository.configureSuccessfulLogin(provider: .google, role: .member)

    let useCase = withDependencies {
      $0.authRepository = authRepository
      $0.googleOAuthProvider = MockGoogleOAuthProvider()
    } operation: {
      UnifiedOAuthUseCase()
    }

    _ = try await useCase.googleLogin(token: "google-token")

    #expect(staffRole == .member)
  }

  @Test("신규 사용자는 이전 계정의 프로필 API 역할 선택값을 제거한다")
  @MainActor
  func newGoogleUserClearsPersistedRole() async throws {
    @Shared(.staffRole) var staffRole
    $staffRole.withLock { $0 = .manager }
    defer { $staffRole.withLock { $0 = nil } }

    let authRepository = MockAuthRepository()
    authRepository.configureSuccessfulLogin(isNewUser: true, provider: .google, role: nil)

    let useCase = withDependencies {
      $0.authRepository = authRepository
      $0.googleOAuthProvider = MockGoogleOAuthProvider()
    } operation: {
      UnifiedOAuthUseCase()
    }

    _ = try await useCase.googleLogin(token: "google-token")

    #expect(staffRole == nil)
  }

  @Test("Apple 로그인 필수 값이 없으면 credential 오류를 반환한다")
  func appleLoginRequiresCredentialAndNonce() async {
    let useCase = UnifiedOAuthUseCase()

    await #expect(throws: AuthError.invalidCredential("Apple 로그인에 필요한 credential 또는 nonce가 없습니다")) {
      try await useCase.socialLogin(with: .apple)
    }
  }

  @Test("Google 로그인 토큰이 없으면 credential 오류를 반환한다")
  func googleLoginRequiresToken() async {
    let useCase = UnifiedOAuthUseCase()

    await #expect(throws: AuthError.invalidCredential("Google 로그인에 필요한 token이 없습니다")) {
      try await useCase.socialLogin(with: .google)
    }
  }

  @Test("OAuth flow는 로그인 오류를 Result failure로 반환한다")
  @MainActor
  func oauthFlowReturnsFailure() async {
    let result = await UnifiedOAuthUseCase().processOAuthFlow(with: .google)

    switch result {
    case .success:
      Issue.record("필수 토큰이 없으므로 실패해야 한다")
    case let .failure(error):
      #expect(error == .invalidCredential("Google 로그인에 필요한 token이 없습니다"))
    }
  }

  @Test("Google provider는 repository token을 반환하고 access token을 세션에 저장한다")
  @MainActor
  func googleProviderSynchronizesAccessToken() async throws {
    @Shared(.userSession) var userSession
    $userSession.withLock { $0 = .empty }
    defer { $userSession.withLock { $0 = .empty } }

    let provider = withDependencies {
      $0.googleOAuthRepository = GoogleOAuthRepositoryStub(
        payload: GoogleOAuthPayload(
          idToken: "id-token",
          accessToken: "access-token",
          authorizationCode: "authorization-code",
          displayName: "사용자"
        )
      )
    } operation: {
      GoogleOAuthProvider()
    }

    let token = try await provider.signInWithToken(token: "ignored-sdk-token")

    #expect(token == "id-token")
    #expect(userSession.accessToken == "access-token")
  }
}

private struct GoogleOAuthRepositoryStub: GoogleOAuthInterface {
  let payload: GoogleOAuthPayload

  func signIn() async throws(AuthError) -> GoogleOAuthPayload {
    payload
  }
}
