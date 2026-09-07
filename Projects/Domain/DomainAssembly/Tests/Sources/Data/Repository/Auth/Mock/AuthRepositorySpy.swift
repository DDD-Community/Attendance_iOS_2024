//
//  AuthRepositorySpy.swift
//  Repository
//
//  Created by DDD on 4/17/26.
//

import Foundation

import AuthDomainInterface

@MainActor
final class AuthRepositorySpy: AuthInterface {

  // MARK: - Call Tracking
  var loginCallCount = 0
  var refreshCallCount = 0
  var logoutCallCount = 0
  var withDrawCallCount = 0
  var updateSessionCredentialCallCount = 0

  // MARK: - Parameter Tracking
  var lastLoginProvider: SocialType?
  var lastLoginToken: String?
  var lastWithdrawToken: String?
  var lastUpdateTokens: AuthTokens?

  // MARK: - Response Configuration
  var shouldSucceed = true
  var errorToThrow: AuthError = .invalidCredential("invalid token")

  init() {}

  // MARK: - Configuration Methods
  func configureSuccess() {
    shouldSucceed = true
  }

  func configureFailure(_ error: AuthError) {
    shouldSucceed = false
    errorToThrow = error
  }

  func reset() {
    loginCallCount = 0
    refreshCallCount = 0
    logoutCallCount = 0
    withDrawCallCount = 0
    updateSessionCredentialCallCount = 0

    lastLoginProvider = nil
    lastLoginToken = nil
    lastWithdrawToken = nil
    lastUpdateTokens = nil

    shouldSucceed = true
    errorToThrow = .invalidCredential("invalid token")
  }

  // MARK: - AuthInterface Implementation
  func login(provider: SocialType, token: String) async throws(AuthError) -> LoginEntity {
    loginCallCount += 1
    lastLoginProvider = provider
    lastLoginToken = token

    guard shouldSucceed else { throw errorToThrow }

    return LoginEntity(
      name: "Test User",
      isNewUser: false,
      provider: provider,
      token: AuthTokens(
        accessToken: "mock_access_token",
        refreshToken: "mock_refresh_token",
        oauthRefreshToken: "mock_oauth_token"
      ),
      role: .member
    )
  }

  func refresh() async throws(AuthError) -> AuthTokens {
    refreshCallCount += 1

    guard shouldSucceed else { throw errorToThrow }

    return AuthTokens(
      accessToken: "refreshed_access_token",
      refreshToken: "refreshed_refresh_token",
      oauthRefreshToken: "refreshed_oauth_token"
    )
  }

  func logout() async throws(AuthError) -> AuthExitEntity {
    logoutCallCount += 1

    guard shouldSucceed else { throw errorToThrow }

    return AuthExitEntity(
      code: "200",
      message: "logout",
      detail: "success"
    )
  }

  func withDraw(token: String) async throws(AuthError) -> WithdrawEntity {
    withDrawCallCount += 1
    lastWithdrawToken = token

    guard shouldSucceed else { throw errorToThrow }

    return WithdrawEntity(
      isSuccess: true,
      code: "200",
      message: "withdraw",
      detail: "success"
    )
  }

  func updateSessionCredential(with tokens: AuthTokens) async {
    updateSessionCredentialCallCount += 1
    lastUpdateTokens = tokens
  }

  // MARK: - Static Factory Methods
  @MainActor
  static func success() -> AuthRepositorySpy {
    let mock = AuthRepositorySpy()
    mock.configureSuccess()
    return mock
  }

  @MainActor
  static func failure(_ error: AuthError) -> AuthRepositorySpy {
    let mock = AuthRepositorySpy()
    mock.configureFailure(error)
    return mock
  }
}
