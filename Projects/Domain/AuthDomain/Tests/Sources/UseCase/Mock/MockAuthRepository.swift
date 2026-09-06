//
//  MockAuthRepository.swift
//  AuthDomainTests
//
//  Created by DDD on 9/4/26.
//

import Foundation

import AuthDomainInterface

@MainActor
final class MockAuthRepository: AuthInterface {

  init() {}
  private(set) var loginCallCount = 0
  private(set) var refreshCallCount = 0
  private(set) var logoutCallCount = 0
  private(set) var withDrawCallCount = 0
  private(set) var updateSessionCredentialCallCount = 0

  private(set) var lastLoginProvider: SocialType?
  private(set) var lastLoginToken: String?
  private(set) var lastWithdrawToken: String?
  private(set) var lastUpdateTokens: AuthTokens?

  var loginResponse: Result<LoginEntity, AuthError> = .failure(.invalidCredential("invalid token"))
  var refreshResponse: Result<AuthTokens, AuthError> = .failure(.refreshTokenExpired)
  var logoutResponse: Result<AuthExitEntity, AuthError> = .success(AuthExitEntity())
  var withdrawResponse: Result<WithdrawEntity, AuthError> = .success(WithdrawEntity(isSuccess: true))

  var loginDelay: TimeInterval = 0
  var refreshDelay: TimeInterval = 0
  var logoutDelay: TimeInterval = 0
  var withdrawDelay: TimeInterval = 0

  func login(provider: SocialType, token: String) async throws(AuthError) -> LoginEntity {
    if loginDelay > 0 {
      try? await Task.sleep(nanoseconds: UInt64(loginDelay * 1_000_000_000))
    }
    loginCallCount += 1
    lastLoginProvider = provider
    lastLoginToken = token
    return try loginResponse.get()
  }

  func refresh() async throws(AuthError) -> AuthTokens {
    if refreshDelay > 0 {
      try? await Task.sleep(nanoseconds: UInt64(refreshDelay * 1_000_000_000))
    }
    refreshCallCount += 1
    return try refreshResponse.get()
  }

  func logout() async throws(AuthError) -> AuthExitEntity {
    if logoutDelay > 0 {
      try? await Task.sleep(nanoseconds: UInt64(logoutDelay * 1_000_000_000))
    }
    logoutCallCount += 1
    return try logoutResponse.get()
  }

  func withDraw(token: String) async throws(AuthError) -> WithdrawEntity {
    if withdrawDelay > 0 {
      try? await Task.sleep(nanoseconds: UInt64(withdrawDelay * 1_000_000_000))
    }
    withDrawCallCount += 1
    lastWithdrawToken = token
    return try withdrawResponse.get()
  }

  func updateSessionCredential(with tokens: AuthTokens) async {
    updateSessionCredentialCallCount += 1
    lastUpdateTokens = tokens
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
    loginResponse = .failure(.invalidCredential("invalid token"))
    refreshResponse = .failure(.refreshTokenExpired)
    logoutResponse = .success(AuthExitEntity())
    withdrawResponse = .success(WithdrawEntity(isSuccess: true))
    loginDelay = 0
    refreshDelay = 0
    logoutDelay = 0
    withdrawDelay = 0
  }

  func configureSuccessfulLogin(
    name: String = "Test User",
    isNewUser: Bool = false,
    provider: SocialType = .google,
    role: Staff? = Staff.member
  ) {
    let tokens = AuthTokens(
      accessToken: "mock_access_token",
      refreshToken: "mock_refresh_token",
      oauthRefreshToken: provider == .apple ? nil : "mock_oauth_refresh_token"
    )
    loginResponse = .success(
      LoginEntity(name: name, isNewUser: isNewUser, provider: provider, token: tokens, role: role)
    )
  }

  func configureSuccessfulRefresh() {
    refreshResponse = .success(
      AuthTokens(accessToken: "refreshed_access_token", refreshToken: "refreshed_refresh_token")
    )
  }

  func configureLoginFailure(_ error: Error) { loginResponse = .failure(AuthError.from(error)) }
  func configureRefreshFailure(_ error: Error) { refreshResponse = .failure(AuthError.from(error)) }
  func configureLogoutFailure(_ error: Error) { logoutResponse = .failure(AuthError.from(error)) }
  func configureWithdrawFailure(_ error: Error) { withdrawResponse = .failure(AuthError.from(error)) }

  @MainActor
  static func success() -> MockAuthRepository {
    let mock = MockAuthRepository()
    mock.configureSuccessfulLogin(role: Staff.member)
    return mock
  }

  @MainActor
  static func appleSuccess() -> MockAuthRepository {
    let mock = MockAuthRepository()
    mock.configureSuccessfulLogin(name: "Apple User", provider: .apple, role: nil)
    return mock
  }

  @MainActor
  static func newUser() -> MockAuthRepository {
    let mock = MockAuthRepository()
    mock.configureSuccessfulLogin(name: "New Google User", isNewUser: true, provider: .google, role: nil)
    return mock
  }

  @MainActor
  static func invalidToken() -> MockAuthRepository {
    let mock = MockAuthRepository()
    mock.configureLoginFailure(AuthError.invalidCredential("invalid token"))
    return mock
  }

  @MainActor
  static func networkError() -> MockAuthRepository {
    let mock = MockAuthRepository()
    mock.configureLoginFailure(AuthError.unknownError("네트워크 요청에 실패했습니다"))
    return mock
  }

  @MainActor
  static func refreshSuccess() -> MockAuthRepository {
    let mock = MockAuthRepository()
    mock.configureSuccessfulRefresh()
    return mock
  }

  @MainActor
  static func logoutSuccess() -> MockAuthRepository {
    let mock = MockAuthRepository()
    mock.logoutResponse = .success(AuthExitEntity(code: "200", message: "logout", detail: "success"))
    return mock
  }

  @MainActor
  static func withdrawSuccess() -> MockAuthRepository {
    let mock = MockAuthRepository()
    mock.withdrawResponse = .success(WithdrawEntity(isSuccess: true, code: "200", message: "withdraw", detail: "success"))
    return mock
  }

  @MainActor
  static func unauthorized() -> MockAuthRepository {
    let mock = MockAuthRepository()
    mock.configureWithdrawFailure(AuthError.accountDeletionNotAllowed)
    mock.configureLoginFailure(AuthError.loginFailed)
    mock.configureRefreshFailure(AuthError.tokenRefreshFailed)
    mock.configureLogoutFailure(AuthError.logoutFailed)
    return mock
  }

  @MainActor
  static func concurrency() -> MockAuthRepository {
    let mock = MockAuthRepository.success()
    mock.loginDelay = 0.01
    return mock
  }

  @MainActor
  static func tokenExpired() -> MockAuthRepository {
    let mock = MockAuthRepository()
    mock.configureRefreshFailure(AuthError.refreshTokenExpired)
    return mock
  }

  @MainActor
  static func serverError() -> MockAuthRepository {
    let mock = MockAuthRepository()
    mock.configureLoginFailure(AuthError.loginFailed)
    mock.configureRefreshFailure(AuthError.tokenRefreshFailed)
    mock.configureLogoutFailure(AuthError.logoutFailed)
    mock.configureWithdrawFailure(AuthError.accountDeletionFailed)
    return mock
  }

  @MainActor
  static func fullFlowSuccess() -> MockAuthRepository {
    let mock = MockAuthRepository.success()
    mock.configureSuccessfulRefresh()
    mock.logoutResponse = .success(AuthExitEntity(code: "200", message: "logout", detail: "success"))
    mock.withdrawResponse = .success(WithdrawEntity(isSuccess: true, code: "200", message: "withdraw", detail: "success"))
    return mock
  }

  func getLoginCallCount() -> Int { loginCallCount }
  func getRefreshCallCount() -> Int { refreshCallCount }
  func getLogoutCallCount() -> Int { logoutCallCount }
  func getWithdrawCallCount() -> Int { withDrawCallCount }
  func getUpdateCredentialCallCount() -> Int { updateSessionCredentialCallCount }
  func getLastUpdatedTokens() -> AuthTokens? { lastUpdateTokens }
}
