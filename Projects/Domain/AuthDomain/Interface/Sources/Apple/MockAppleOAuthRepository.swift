//
//  MockAppleOAuthRepository.swift
//  DomainInterface
//
//  Created by DDD on 12/29/25.
//

import AuthenticationServices
import Foundation

import ProfileDomainInterface

public actor MockAppleOAuthRepository: AppleOAuthInterface {
  public init() {}
  // MARK: - Configuration
  public enum Configuration {
    case success
    case failure
    case userCancelled
    case invalidCredentials
    case customUser(String)
    case networkError
    case customDelay(TimeInterval)
    
    var shouldSucceed: Bool {
      switch self {
        case .success, .customUser, .customDelay:
          return true
        case .failure, .userCancelled, .invalidCredentials, .networkError:
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
          return "Mock Apple User"
      }
    }
    
    var error: AuthError? {
      switch self {
        case .success, .customUser, .customDelay:
          return nil
        case .failure:
          return .unknownError("Mock Apple OAuth sign in failed")
        case .userCancelled:
          return .userCancelled
        case .invalidCredentials:
          return .invalidCredential("Mock Apple OAuth invalid credentials")
        case .networkError:
          return .unknownError("Mock Apple OAuth network error")
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
  
  // MARK: - AppleOAuthRepositoryProtocol Implementation

  public func signInWithCredential(
    _ credential: ASAuthorizationAppleIDCredential,
    nonce: String
  ) async throws(AuthError) -> AppleOAuthPayload {
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
    if !configuration.shouldSucceed, let error = configuration.error {
      throw error
    }

    // Return success payload using provided nonce
    return AppleOAuthPayload(
      idToken: createMockIDToken(),
      authorizationCode: createMockAuthCode(),
      displayName: configuration.mockUserName.isEmpty ? nil : configuration.mockUserName,
      nonce: nonce
    )
  }

  public func signIn() async throws(AuthError) -> AppleOAuthPayload {
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
    if !configuration.shouldSucceed, let error = configuration.error {
      throw error
    }
    
    // Return success payload
    return AppleOAuthPayload(
      idToken: createMockIDToken(),
      authorizationCode: createMockAuthCode(),
      displayName: configuration.mockUserName.isEmpty ? nil : configuration.mockUserName,
      nonce: createMockNonce()
    )
  }
  
  // MARK: - Private Helper Methods
  
  private func createMockIDToken() -> String {
    let header = "eyJhbGciOiJSUzI1NiIsImtpZCI6Im1vY2sta2lkIn0"
    let payload = "eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLm1vY2suYXBwIiwic3ViIjoibW9jay5hcHBsZS51c2VyIn0"
    let signature = "mock-apple-signature-\(UUID().uuidString.prefix(10))"
    return "\(header).\(payload).\(signature)"
  }
  
  private func createMockNonce() -> String {
    return "mock-apple-nonce-\(UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(16))"
  }
  
  private func createMockAuthCode() -> String {
    return "c_\(UUID().uuidString.prefix(20)).0.\(configuration.mockUserName.prefix(5))"
  }
}

// MARK: - Convenience Static Methods

public extension MockAppleOAuthRepository {
  
  /// Creates a pre-configured actor for success scenario
  static func success() -> MockAppleOAuthRepository {
    return MockAppleOAuthRepository(configuration: .success)
  }
  
  /// Creates a pre-configured actor for failure scenario
  static func failure() -> MockAppleOAuthRepository {
    return MockAppleOAuthRepository(configuration: .failure)
  }
  
  /// Creates a pre-configured actor for user cancelled scenario
  static func userCancelled() -> MockAppleOAuthRepository {
    return MockAppleOAuthRepository(configuration: .userCancelled)
  }
  
  /// Creates a pre-configured actor for custom user scenario
  static func customUser(_ name: String) -> MockAppleOAuthRepository {
    return MockAppleOAuthRepository(configuration: .customUser(name))
  }
  
  /// Creates a pre-configured actor for network error scenario
  static func networkError() -> MockAppleOAuthRepository {
    return MockAppleOAuthRepository(configuration: .networkError)
  }
  
  /// Creates a pre-configured actor with custom delay
  static func withDelay(_ delay: TimeInterval) -> MockAppleOAuthRepository {
    return MockAppleOAuthRepository(configuration: .customDelay(delay))
  }
}
