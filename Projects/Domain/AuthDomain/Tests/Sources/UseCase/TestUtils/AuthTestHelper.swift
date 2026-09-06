//
//  AuthTestHelper.swift
//  UseCaseTests
//
//  Created by DDD on 2026-01-31
//

import Foundation
import Testing

@testable import AuthDomain
import AuthDomainInterface

import ComposableArchitecture

// MARK: - Auth Test Helper
@MainActor
struct AuthTestHelper {

    // MARK: - Dependency Setup
    static func withMockDependencies<T>(
        mockAuthRepository: MockAuthRepository,
        mockUserSession: MockUserSession? = nil,
        operation: @MainActor () async throws -> T
    ) async rethrows -> T {

        return try await withDependencies {
            $0.authRepository = mockAuthRepository
        } operation: {
            try await operation()
        }
    }

    // MARK: - Assertion Helpers
    static func verifyLoginSuccess(
        result: LoginEntity,
        expectedProvider: SocialType,
        expectedName: String,
        expectedIsNewUser: Bool,
        expectedRole: Staff?,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(result.provider == expectedProvider,
               "Provider should be \(expectedProvider.rawValue), got \(result.provider.rawValue)",
               sourceLocation: sourceLocation)

        #expect(result.name == expectedName,
               "Name should be '\(expectedName)', got '\(result.name)'",
               sourceLocation: sourceLocation)

        #expect(result.isNewUser == expectedIsNewUser,
               "IsNewUser should be \(expectedIsNewUser), got \(result.isNewUser)",
               sourceLocation: sourceLocation)

        #expect(result.role == expectedRole,
               "Role should be \(String(describing: expectedRole)), got \(String(describing: result.role))",
               sourceLocation: sourceLocation)
    }



    // MARK: - UserSession Verification
    static func verifyUserSessionUpdated(
        mockSession: MockUserSession,
        expectedOAuthToken: String?,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(mockSession.wasSessionUpdated(),
               "UserSession should have been updated",
               sourceLocation: sourceLocation)

        #expect(mockSession.verifyOAuthRefreshToken(expectedOAuthToken),
               "OAuth refresh token should match expected value",
               sourceLocation: sourceLocation)
    }

    static func verifyStaffRoleCleared(
        mockSession: MockUserSession,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(mockSession.wasStaffRoleUpdated(),
               "Staff role should have been updated",
               sourceLocation: sourceLocation)

        #expect(mockSession.getCurrentStaffRole() == nil,
               "Staff role should be nil after logout",
               sourceLocation: sourceLocation)
    }

    // MARK: - Error Verification
    static func verifyError<T: Error & Equatable>(
        _ error: Error,
        expectedError: T,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        guard let actualError = error as? T else {
            Issue.record("Error type mismatch. Expected \(T.self), got \(type(of: error))",
                        sourceLocation: sourceLocation)
            return
        }

        #expect(actualError == expectedError,
               "Error should be \(expectedError), got \(actualError)",
               sourceLocation: sourceLocation)
    }

    // MARK: - Repository Call Verification
    static func verifyRepositoryCalls(
        mockRepository: MockAuthRepository,
        expectedLoginCalls: Int = 0,
        expectedRefreshCalls: Int = 0,
        expectedLogoutCalls: Int = 0,
        expectedWithdrawCalls: Int = 0,
        expectedUpdateCredentialCalls: Int = 0,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(mockRepository.getLoginCallCount() == expectedLoginCalls,
               "Login call count should be \(expectedLoginCalls), got \(mockRepository.getLoginCallCount())",
               sourceLocation: sourceLocation)

        #expect(mockRepository.getRefreshCallCount() == expectedRefreshCalls,
               "Refresh call count should be \(expectedRefreshCalls), got \(mockRepository.getRefreshCallCount())",
               sourceLocation: sourceLocation)

        #expect(mockRepository.getLogoutCallCount() == expectedLogoutCalls,
               "Logout call count should be \(expectedLogoutCalls), got \(mockRepository.getLogoutCallCount())",
               sourceLocation: sourceLocation)

        #expect(mockRepository.getWithdrawCallCount() == expectedWithdrawCalls,
               "Withdraw call count should be \(expectedWithdrawCalls), got \(mockRepository.getWithdrawCallCount())",
               sourceLocation: sourceLocation)

        #expect(mockRepository.getUpdateCredentialCallCount() == expectedUpdateCredentialCalls,
               "Update credential call count should be \(expectedUpdateCredentialCalls), got \(mockRepository.getUpdateCredentialCallCount())",
               sourceLocation: sourceLocation)
    }

    // MARK: - Concurrent Testing Helpers
    static func performConcurrentOperations<T>(
        operations: [() async throws -> T],
        timeout: TimeInterval = 5.0
    ) async throws -> [Result<T, Error>] {
        return try await withThrowingTaskGroup(of: Result<T, Error>.self) { group in
            var results: [Result<T, Error>] = []

            for operation in operations {
                group.addTask {
                    do {
                        let result = try await operation()
                        return .success(result)
                    } catch {
                        return .failure(error)
                    }
                }
            }

            for try await result in group {
                results.append(result)
            }

            return results
        }
    }

    // MARK: - Test Data Validation
    static func validateAuthTokens(
        _ tokens: AuthTokens,
        shouldHaveOAuthToken: Bool,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(!tokens.accessToken.isEmpty,
               "Access token should not be empty",
               sourceLocation: sourceLocation)

        #expect(!tokens.refreshToken.isEmpty,
               "Refresh token should not be empty",
               sourceLocation: sourceLocation)

        if shouldHaveOAuthToken {
            #expect(tokens.oauthRefreshToken != nil,
                   "OAuth refresh token should not be nil for providers that support it",
                   sourceLocation: sourceLocation)
        } else {
            #expect(tokens.oauthRefreshToken == nil,
                   "OAuth refresh token should be nil for Apple provider",
                   sourceLocation: sourceLocation)
        }
    }

    // MARK: - Time-based Testing
    static func measureExecutionTime<T>(
        of operation: () async throws -> T
    ) async rethrows -> (result: T, duration: TimeInterval) {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await operation()
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        return (result, duration)
    }

}
