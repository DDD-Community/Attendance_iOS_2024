//
//  MockSignUpRepository.swift
//  DomainInterface
//
//  Created by DDD on 7/23/25.
//  Moved from Repository module
//

import Foundation

import AuthDomainInterface
import ProfileDomainInterface

/// SignUp Repository의 기본 구현체 (테스트/프리뷰용)
final public class MockSignUpRepository: SignUpInterface, @unchecked Sendable {

  // MARK: - Configuration
  public enum Configuration {
    case success
    case failure
    case invalidInviteCode
    case expiredInviteCode
    case networkError
    case serverError
    case customDelay(TimeInterval)

    var shouldSucceed: Bool {
      switch self {
      case .success, .customDelay:
        return true
      case .failure, .invalidInviteCode, .expiredInviteCode, .networkError, .serverError:
        return false
      }
    }

    var delay: TimeInterval {
      switch self {
      case .customDelay(let delay):
        return delay
      default:
        return 1.0 // 실제 네트워크 지연 시뮬레이션
      }
    }

    var signUpError: SignUpError? {
      switch self {
      case .success, .customDelay:
        return nil
      case .failure:
        return .accountCreationFailed
      case .invalidInviteCode:
        return .invalidInviteCode
      case .expiredInviteCode:
        return .expiredInviteCode
      case .networkError:
        return .unknownError("네트워크 요청에 실패했습니다")
      case .serverError:
        return .unknownError("서버 요청에 실패했습니다")
      }
    }
  }

  // MARK: - Properties
  private var configuration: Configuration = .success
  private var registerCallCount = 0
  private var validateCallCount = 0
  private var checkEmailCallCount = 0
  private var lastCall: Date?

  // MARK: - Initialization

  public init(configuration: Configuration = .success) {
    self.configuration = configuration
  }

  // MARK: - Configuration Methods

  public func setConfiguration(_ configuration: Configuration) {
    self.configuration = configuration
    registerCallCount = 0
    validateCallCount = 0
    checkEmailCallCount = 0
    lastCall = nil
  }

  public func getRegisterCallCount() -> Int { registerCallCount }
  public func getValidateCallCount() -> Int { validateCallCount }
  public func getCheckEmailCallCount() -> Int { checkEmailCallCount }
  public func getLastCall() -> Date? { lastCall }

  public func reset() {
    configuration = .success
    registerCallCount = 0
    validateCallCount = 0
    checkEmailCallCount = 0
    lastCall = nil
  }

  // MARK: - SignUpInterface Implementation

  public func registerUser(
    input: SignUpUserInput
  ) async throws(SignUpError) -> SignUpUser {
    // Track call
    registerCallCount += 1
    lastCall = Date()

    // Apply delay
    if configuration.delay > 0 {
      do {
        try await Task.sleep(for: .seconds(configuration.delay))
      } catch {
        throw SignUpError.from(error)
      }
    }

    // 입력 값 검증
    guard !input.name.isEmpty else {
      throw SignUpError.missingRequiredField("이름")
    }

    guard !input.token.isEmpty else {
      throw SignUpError.missingRequiredField("토큰")
    }

    if input.generationId <= 0 {
      throw SignUpError.missingRequiredField("기수")
    }

    // Configuration 기반 응답 처리
    if !configuration.shouldSucceed, let error = configuration.signUpError {
      throw error
    }

    // Success case
    return SignUpUser(
      name: input.name,
      email: "",
      generation: String(input.generationId),
      team: input.teamId == nil ? nil : .unknown,
      managing: input.managerRoles,
      selectPart: input.jobRole
    )
  }
}

// MARK: - Convenience Static Methods

public extension MockSignUpRepository {

  /// Creates a pre-configured instance for success scenario
  static func success() -> MockSignUpRepository {
    return MockSignUpRepository(configuration: .success)
  }

  /// Creates a pre-configured instance for failure scenario
  static func failure() -> MockSignUpRepository {
    return MockSignUpRepository(configuration: .failure)
  }

  /// Creates a pre-configured instance for invalid invite code scenario
  static func invalidInviteCode() -> MockSignUpRepository {
    return MockSignUpRepository(configuration: .invalidInviteCode)
  }

  /// Creates a pre-configured instance for expired invite code scenario
  static func expiredInviteCode() -> MockSignUpRepository {
    return MockSignUpRepository(configuration: .expiredInviteCode)
  }

  /// Creates a pre-configured instance for network error scenario
  static func networkError() -> MockSignUpRepository {
    return MockSignUpRepository(configuration: .networkError)
  }

  /// Creates a pre-configured instance with custom delay
  static func withDelay(_ delay: TimeInterval) -> MockSignUpRepository {
    return MockSignUpRepository(configuration: .customDelay(delay))
  }
}
