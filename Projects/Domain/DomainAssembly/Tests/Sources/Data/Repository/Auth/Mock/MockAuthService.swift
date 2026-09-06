//
//  MockAuthService.swift
//  Repository
//
//  Created by DDD on 4/17/26.
//

import Foundation

import APIEndpoint
import AuthDomainInterface

@MainActor
final class MockAuthService {

  // MARK: - Call Tracking
  var loginCallCount = 0
  var refreshCallCount = 0
  var logoutCallCount = 0
  var withdrawCallCount = 0

  // MARK: - Parameter Tracking
  var lastLoginProvider: String?
  var lastLoginToken: String?
  var lastRefreshToken: String?
  var lastWithdrawToken: String?

  // MARK: - Response Configuration
  var shouldSucceed = true
  var errorToThrow: Error = MockAuthError.invalidToken

  init() {}

  // MARK: - Reset Method
  func reset() {
    loginCallCount = 0
    refreshCallCount = 0
    logoutCallCount = 0
    withdrawCallCount = 0

    lastLoginProvider = nil
    lastLoginToken = nil
    lastRefreshToken = nil
    lastWithdrawToken = nil

    shouldSucceed = true
    errorToThrow = MockAuthError.invalidToken
  }

  // MARK: - Configuration Methods
  func configureSuccess() {
    shouldSucceed = true
  }

  func configureFailure(_ error: Error) {
    shouldSucceed = false
    errorToThrow = error
  }

  // MARK: - Mock Response Methods
  func mockLogin(provider: SocialType, token: String) throws -> LoginEntity {
    loginCallCount += 1
    lastLoginProvider = provider.description
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

  func mockRefresh() throws -> AuthTokens {
    refreshCallCount += 1

    guard shouldSucceed else { throw errorToThrow }

    return AuthTokens(
      accessToken: "refreshed_access_token",
      refreshToken: "refreshed_refresh_token",
      oauthRefreshToken: "refreshed_oauth_token"
    )
  }

  func mockLogout() throws -> AuthExitEntity {
    logoutCallCount += 1

    guard shouldSucceed else { throw errorToThrow }

    return AuthExitEntity(
      code: "200",
      message: "logout",
      detail: "success"
    )
  }

  func mockWithdraw(token: String) throws -> WithdrawEntity {
    withdrawCallCount += 1
    lastWithdrawToken = token

    guard shouldSucceed else { throw errorToThrow }

    return WithdrawEntity(
      isSuccess: true,
      code: "200",
      message: "withdraw",
      detail: "success"
    )
  }

  // MARK: - Static Factory Methods
  @MainActor
  static func success() -> MockAuthService {
    let mock = MockAuthService()
    mock.configureSuccess()
    return mock
  }

  @MainActor
  static func loginFailure() -> MockAuthService {
    let mock = MockAuthService()
    mock.configureFailure(MockAuthError.invalidToken)
    return mock
  }

  @MainActor
  static func networkError() -> MockAuthService {
    let mock = MockAuthService()
    mock.configureFailure(MockAuthError.networkError)
    return mock
  }

  @MainActor
  static func serverError() -> MockAuthService {
    let mock = MockAuthService()
    mock.configureFailure(MockAuthError.serverError)
    return mock
  }
}

// MARK: - Mock Error Types
enum MockAuthError: Error, Equatable {
  case invalidToken
  case tokenExpired
  case networkError
  case unauthorized
  case serverError
  case invalidCredentials
  case userNotFound

  var authError: AuthError {
    switch self {
    case .invalidToken, .invalidCredentials:
      return .invalidCredential("invalid token")
    case .tokenExpired:
      return .refreshTokenExpired
    case .networkError:
      return .loginFailed
    case .unauthorized:
      return .accountDeletionNotAllowed
    case .serverError:
      return .loginFailed
    case .userNotFound:
      return .loginFailed
    }
  }
}
