//
//  AuthTestFixture.swift
//  UseCaseTests
//
//  Created by DDD on 2026-01-31
//

import Foundation

import AuthDomainInterface

// MARK: - Auth Test Fixtures
internal struct AuthTestFixture {

  // MARK: - Login Entities
  internal static let successfulGoogleLogin = LoginEntity(
    name: "Google Test User",
    isNewUser: false,
    provider: .google,
    token: AuthTokens(
      accessToken: "google_access_token_12345",
      refreshToken: "google_refresh_token_67890",
      oauthRefreshToken: "google_oauth_refresh_token_abcde"
    ),
    role: .member
  )

  internal static let successfulAppleLogin = LoginEntity(
    name: "Apple Test User",
    isNewUser: false,
    provider: .apple,
    token: AuthTokens(
      accessToken: "apple_access_token_54321",
      refreshToken: "apple_refresh_token_09876",
      oauthRefreshToken: nil // Apple doesn't provide OAuth refresh token
    ),
    role: .manager
  )

  internal static let newUserGoogleLogin = LoginEntity(
    name: "New Google User",
    isNewUser: true,
    provider: .google,
    token: AuthTokens(
      accessToken: "new_google_access_token",
      refreshToken: "new_google_refresh_token",
      oauthRefreshToken: "new_google_oauth_refresh"
    ),
    role: nil
  )

  internal static let newUserAppleLogin = LoginEntity(
    name: "New Apple User",
    isNewUser: true,
    provider: .apple,
    token: AuthTokens(
      accessToken: "new_apple_access_token",
      refreshToken: "new_apple_refresh_token",
      oauthRefreshToken: nil
    ),
    role: nil
  )

  // MARK: - Auth Tokens
  internal static let validAuthTokens = AuthTokens(
    accessToken: "valid_access_token_12345",
    refreshToken: "valid_refresh_token_67890",
    oauthRefreshToken: "valid_oauth_refresh_token"
  )

  internal static let expiredAuthTokens = AuthTokens(
    accessToken: "expired_access_token",
    refreshToken: "expired_refresh_token",
    oauthRefreshToken: "expired_oauth_refresh"
  )

  internal static let refreshedAuthTokens = AuthTokens(
    accessToken: "refreshed_access_token_new",
    refreshToken: "refreshed_refresh_token_new",
    oauthRefreshToken: "refreshed_oauth_token_new"
  )

  internal static let appleAuthTokens = AuthTokens(
    accessToken: "apple_access_token",
    refreshToken: "apple_refresh_token",
    oauthRefreshToken: nil
  )

  internal static let googleAuthTokens = AuthTokens(
    accessToken: "google_access_token",
    refreshToken: "google_refresh_token",
    oauthRefreshToken: "google_oauth_refresh_token"
  )

  // MARK: - Auth Exit Entities
  internal static let successfulLogout = AuthExitEntity(
    code: "200",
    message: "Successfully logged out",
    detail: "User session terminated"
  )

  internal static let failedLogout = AuthExitEntity(
    code: "500",
    message: "Logout failed",
    detail: "Server error during logout"
  )

  // MARK: - Withdraw Entities
  internal static let successfulWithdraw = WithdrawEntity(
    isSuccess: true,
    code: "200",
    message: "Account successfully deleted",
    detail: "All user data has been removed"
  )

  internal static let failedWithdraw = WithdrawEntity(
    isSuccess: false,
    code: "403",
    message: "Withdrawal failed",
    detail: "Insufficient permissions"
  )

  // MARK: - Test Tokens
  internal struct TestTokens {
    internal static let validGoogleToken = "google_token_valid_12345"
    internal static let validAppleToken = "apple_token_valid_67890"
    internal static let invalidToken = "invalid_token"
    internal static let expiredToken = "expired_token"
    internal static let emptyToken = ""
    internal static let malformedToken = "malformed..token"
    internal static let tooLongToken = String(repeating: "a", count: 1000)
    internal static let tooShortToken = "a"
    internal static let withdrawToken = "withdraw_token_12345"
  }

  // MARK: - Test User Names
  internal struct TestUserNames {
    internal static let validName = "Test User"
    internal static let longName = String(repeating: "김", count: 50)
    internal static let emptyName = ""
    internal static let specialCharacterName = "User@#$%"
    internal static let numberName = "User123"
    internal static let unicodeName = "사용자👤"
  }

  // MARK: - Common Test Scenarios
  internal struct Scenarios {
    internal static func makeLoginEntity(
      provider: SocialType,
      isNewUser: Bool = false,
      role: Staff? = .member,
      name: String = "Test User"
    ) -> LoginEntity {
      return LoginEntity(
        name: name,
        isNewUser: isNewUser,
        provider: provider,
        token: provider == .apple ? appleAuthTokens : googleAuthTokens,
        role: isNewUser ? nil : role
      )
    }

    internal static func makeUserSession(
      for loginEntity: LoginEntity
    ) -> UserSession {
      return UserSession(
        userID: loginEntity.isNewUser ? 0 : 123,
        name: loginEntity.name,
        selectPart: loginEntity.isNewUser ? SelectParts.all : SelectParts.ios,
        userRole: loginEntity.role ?? Staff.member,
        managing: loginEntity.role == Staff.manager ? [StaffManaging.teamManaging] : [],
        provider: loginEntity.provider,
        selectTeam: loginEntity.isNewUser ? SelectTeams.unknown : SelectTeams.ios1,
        selectTeamId: loginEntity.isNewUser ? nil : 1,
        token: "user_session_token",
        generationId: loginEntity.isNewUser ? 0 : 1,
        accessToken: loginEntity.token.accessToken,
        oauthRefreshToken: loginEntity.token.oauthRefreshToken,
        inviteCode: loginEntity.isNewUser ? "" : "ABC123",
        generation: loginEntity.isNewUser ? "" : "1기"
      )
    }
  }

  // MARK: - Error Test Cases
  internal struct ErrorCases {
    internal static let networkError = NSError(
      domain: "NetworkErrorDomain",
      code: -1009,
      userInfo: [NSLocalizedDescriptionKey: "The Internet connection appears to be offline."]
    )

    internal static let serverError = NSError(
      domain: "ServerErrorDomain",
      code: 500,
      userInfo: [NSLocalizedDescriptionKey: "Internal server error"]
    )

    internal static let timeoutError = NSError(
      domain: "TimeoutErrorDomain",
      code: -1001,
      userInfo: [NSLocalizedDescriptionKey: "The request timed out."]
    )

    internal static let unauthorizedError = NSError(
      domain: "AuthErrorDomain",
      code: 401,
      userInfo: [NSLocalizedDescriptionKey: "Unauthorized access"]
    )
  }

  // MARK: - Concurrent Test Data
  internal struct ConcurrentTestData {
    internal static let simultaneousLoginCount = 5
    internal static let concurrentProviders: [SocialType] = [.google, .apple, .google, .apple, .google]
    internal static let concurrentTokens = [
      "concurrent_token_1",
      "concurrent_token_2",
      "concurrent_token_3",
      "concurrent_token_4",
      "concurrent_token_5"
    ]
  }
}
