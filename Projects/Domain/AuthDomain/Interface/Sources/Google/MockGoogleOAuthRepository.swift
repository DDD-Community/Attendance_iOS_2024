//
//  MockGoogleOAuthRepository.swift
//  DomainInterface
//
//  Created by DDD on 12/29/25.
//

import Foundation

import ProfileDomainInterface

public actor MockGoogleOAuthRepository: GoogleOAuthInterface {

  public init() {}

  // MARK: - Configuration
  public enum Configuration {
    case success
    case failure
    case customUser(String)
    case networkError
    case customDelay(TimeInterval)
    
    var shouldSucceed: Bool {
      switch self {
        case .success, .customUser, .customDelay:
          return true
        case .failure, .networkError:
          return false
      }
    }
    
    var delay: TimeInterval {
      switch self {
        case .customDelay(let delay):
          return delay
        default:
          return 0.1
      }
    }
    
    var mockUserName: String {
      switch self {
        case .customUser(let name):
          return name
        default:
          return "Mock Google User"
      }
    }
  }
  
  // MARK: - State
  
  private var configuration: Configuration = .success
  private var signInCallCount = 0
  private var lastSignInCall: Date?
  
  // MARK: - Public Configuration Methods
  
  public init(configuration: Configuration = .success) {
    self.configuration = configuration
  }
  
  public func setConfiguration(_ configuration: Configuration) {
    self.configuration = configuration
    signInCallCount = 0
    lastSignInCall = nil
  }
  
  public func getSignInCallCount() -> Int {
    return signInCallCount
  }
  
  public func getLastSignInCall() -> Date? {
    return lastSignInCall
  }
  
  public func reset() {
    configuration = .success
    signInCallCount = 0
    lastSignInCall = nil
  }
  
  // MARK: - GoogleOAuthRepositoryProtocol Implementation
  
  public func signIn() async throws(AuthError) -> GoogleOAuthPayload {
    // Track call
    signInCallCount += 1
    lastSignInCall = Date()
    
    // Apply delay
    if configuration.delay > 0 {
      do {
        try await Task.sleep(for: .seconds(configuration.delay))
      } catch {
        throw AuthError.from(error)
      }
    }
    
    // Handle failure scenarios
    if !configuration.shouldSucceed {
      switch configuration {
        case .failure:
          throw AuthError.invalidCredential("Mock Google OAuth sign in failed")
        case .networkError:
          throw AuthError.unknownError("Mock Google OAuth network error")
        default:
          throw AuthError.unknownError("Mock Google OAuth unknown error")
      }
    }
    
    // Return success payload
    return GoogleOAuthPayload(
      idToken: createMockIDToken(),
      accessToken: createMockAccessToken(),
      authorizationCode: createMockAuthCode(),
      displayName: configuration.mockUserName
    )
  }
  
  // MARK: - Private Helper Methods
  
  private func createMockIDToken() -> String {
    return "mock.google.idtoken.\(UUID().uuidString.prefix(8))"
  }
  
  private func createMockAccessToken() -> String {
    return "ya29.mock-google-access-token-\(UUID().uuidString.prefix(12))"
  }
  
  private func createMockAuthCode() -> String {
    return "4/mock-google-auth-code-\(UUID().uuidString.prefix(10))"
  }
}

// MARK: - Convenience Static Methods

public extension MockGoogleOAuthRepository {
  
  /// Creates a pre-configured actor for success scenario
  static func success() -> MockGoogleOAuthRepository {
    return MockGoogleOAuthRepository(configuration: .success)
  }
  
  /// Creates a pre-configured actor for failure scenario
  static func failure() -> MockGoogleOAuthRepository {
    return MockGoogleOAuthRepository(configuration: .failure)
  }
  
  /// Creates a pre-configured actor for custom user scenario
  static func customUser(_ name: String) -> MockGoogleOAuthRepository {
    return MockGoogleOAuthRepository(configuration: .customUser(name))
  }
  
  /// Creates a pre-configured actor for network error scenario
  static func networkError() -> MockGoogleOAuthRepository {
    return MockGoogleOAuthRepository(configuration: .networkError)
  }
  
  /// Creates a pre-configured actor with custom delay
  static func withDelay(_ delay: TimeInterval) -> MockGoogleOAuthRepository {
    return MockGoogleOAuthRepository(configuration: .customDelay(delay))
  }
}

// MARK: - Mock Errors

public enum MockGoogleOAuthError: Error, LocalizedError {
  case signInFailed
  case networkError
  case invalidCredentials
  case userCancelled
  case unknownError
  
  public var errorDescription: String? {
    switch self {
      case .signInFailed:
        return "Mock Google OAuth sign in failed"
      case .networkError:
        return "Mock Google OAuth network error"
      case .invalidCredentials:
        return "Mock Google OAuth invalid credentials"
      case .userCancelled:
        return "Mock Google OAuth user cancelled"
      case .unknownError:
        return "Mock Google OAuth unknown error"
    }
  }
}
