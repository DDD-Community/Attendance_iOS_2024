//
//  MockAuthRepository.swift
//  DomainInterface
//
//  Created by DDD on 2026-04-16
//

import Foundation

import ProfileDomainInterface

public final class MockAuthRepository: AuthInterface, @unchecked Sendable {
    // MARK: - Configuration
    public enum Configuration {
        case success
        case appleSuccess
        case newUser
        case invalidToken
        case networkError
        case refreshSuccess
        case tokenExpired
        case logoutSuccess
        case serverError
        case withdrawSuccess
        case unauthorized
        case fullFlowSuccess
        case concurrency
    }

    // MARK: - State
    private var configuration: Configuration = .success
    private var loginCallCount = 0
    private var refreshCallCount = 0
    private var logoutCallCount = 0
    private var withdrawCallCount = 0
    private var updateCredentialCallCount = 0
    private var lastUpdatedTokens: AuthTokens?
    private var lastLoginProvider: SocialType?
    private var lastLoginToken: String?

    // MARK: - Public Configuration Methods
    public init(configuration: Configuration = .success) {
        self.configuration = configuration
    }

    public static func success() -> MockAuthRepository {
        MockAuthRepository(configuration: .success)
    }

    public static func appleSuccess() -> MockAuthRepository {
        MockAuthRepository(configuration: .appleSuccess)
    }

    public static func newUser() -> MockAuthRepository {
        MockAuthRepository(configuration: .newUser)
    }

    public static func invalidToken() -> MockAuthRepository {
        MockAuthRepository(configuration: .invalidToken)
    }

    public static func networkError() -> MockAuthRepository {
        MockAuthRepository(configuration: .networkError)
    }

    public static func refreshSuccess() -> MockAuthRepository {
        MockAuthRepository(configuration: .refreshSuccess)
    }

    public static func tokenExpired() -> MockAuthRepository {
        MockAuthRepository(configuration: .tokenExpired)
    }

    public static func logoutSuccess() -> MockAuthRepository {
        MockAuthRepository(configuration: .logoutSuccess)
    }

    public static func serverError() -> MockAuthRepository {
        MockAuthRepository(configuration: .serverError)
    }

    public static func withdrawSuccess() -> MockAuthRepository {
        MockAuthRepository(configuration: .withdrawSuccess)
    }

    public static func unauthorized() -> MockAuthRepository {
        MockAuthRepository(configuration: .unauthorized)
    }

    public static func fullFlowSuccess() -> MockAuthRepository {
        MockAuthRepository(configuration: .fullFlowSuccess)
    }

    public static func concurrency() -> MockAuthRepository {
        MockAuthRepository(configuration: .concurrency)
    }

    // MARK: - Call Count Getters
    public func getLoginCallCount() -> Int { loginCallCount }
    public func getRefreshCallCount() -> Int { refreshCallCount }
    public func getLogoutCallCount() -> Int { logoutCallCount }
    public func getWithdrawCallCount() -> Int { withdrawCallCount }
    public func getUpdateCredentialCallCount() -> Int { updateCredentialCallCount }
    public func getLastUpdatedTokens() -> AuthTokens? { lastUpdatedTokens }
    public func getLastLoginProvider() -> SocialType? { lastLoginProvider }
    public func getLastLoginToken() -> String? { lastLoginToken }

    // MARK: - AuthInterface Implementation

    public func login(provider: SocialType, token: String) async throws(AuthError) -> LoginEntity {
        loginCallCount += 1
        lastLoginProvider = provider
        lastLoginToken = token

        // Apply delay for testing
        try? await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .success, .fullFlowSuccess, .concurrency:
            return LoginEntity(
                name: provider == .google ? "Google User" : "Mock User",
                isNewUser: false,
                provider: provider,
                token: AuthTokens(
                    accessToken: "mock-access-token",
                    refreshToken: "mock-refresh-token",
                    oauthRefreshToken: "mock-oauth-refresh-token"
                ),
                role: nil
            )

        case .appleSuccess:
            return LoginEntity(
                name: "Apple User",
                isNewUser: false,
                provider: provider,
                token: AuthTokens(
                    accessToken: "mock-access-token",
                    refreshToken: "mock-refresh-token",
                    oauthRefreshToken: nil // Apple 특화 정책
                ),
                role: nil
            )

        case .newUser:
            return LoginEntity(
                name: "New User",
                isNewUser: true,
                provider: provider,
                token: AuthTokens(
                    accessToken: "mock-access-token",
                    refreshToken: "mock-refresh-token",
                    oauthRefreshToken: "mock-oauth-refresh-token"
                ),
                role: nil
            )

        case .invalidToken:
            throw AuthError.invalidCredential("Mock invalid token")

        case .networkError:
            throw AuthError.unknownError("네트워크 요청에 실패했습니다")

        default:
            throw AuthError.unknownError("Mock unknown error")
        }
    }

    public func refresh() async throws(AuthError) -> AuthTokens {
        refreshCallCount += 1

        try? await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .success, .refreshSuccess, .fullFlowSuccess:
            return AuthTokens(
                accessToken: "new-access-token",
                refreshToken: "new-refresh-token",
                oauthRefreshToken: "new-oauth-refresh-token"
            )

        case .tokenExpired:
            throw AuthError.refreshTokenExpired

        default:
            throw AuthError.unknownError("Mock unknown error")
        }
    }

    public func logout() async throws(AuthError) -> AuthExitEntity {
        logoutCallCount += 1

        try? await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .success, .logoutSuccess, .fullFlowSuccess:
            return AuthExitEntity()

        case .serverError:
            throw AuthError.logoutFailed

        default:
            throw AuthError.unknownError("Mock unknown error")
        }
    }

    public func withDraw(token: String) async throws(AuthError) -> WithdrawEntity {
        withdrawCallCount += 1

        try? await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .success, .withdrawSuccess:
            return WithdrawEntity(isSuccess: true)

        case .unauthorized:
            throw AuthError.accountDeletionNotAllowed

        default:
            throw AuthError.unknownError("Mock unknown error")
        }
    }

    public func updateSessionCredential(with tokens: AuthTokens) async {
        updateCredentialCallCount += 1
        lastUpdatedTokens = tokens
    }
}

// MARK: - Mock Errors
public enum MockAuthError: Error, LocalizedError {
    case invalidToken
    case networkError
    case tokenExpired
    case serverError
    case unauthorized
    case unknownError

    public var errorDescription: String? {
        switch self {
        case .invalidToken:
            return "Invalid authentication token"
        case .networkError:
            return "Network connection error"
        case .tokenExpired:
            return "Authentication token has expired"
        case .serverError:
            return "Internal server error"
        case .unauthorized:
            return "Unauthorized access"
        case .unknownError:
            return "Unknown authentication error"
        }
    }
}
