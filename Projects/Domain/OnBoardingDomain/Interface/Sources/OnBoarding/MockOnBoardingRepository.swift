//
//  MockOnBoardingRepository.swift
//  DomainInterface
//
//  Created by DDD on 12/30/25.
//

import Foundation

import AuthDomainInterface
import ProfileDomainInterface

// MARK: - OnBoarding Errors

public enum OnBoardingError: Error, LocalizedError, Sendable, Equatable {
  case invalidCode
  case verifyFailed
  case networkError
  case unknownError

  public var errorDescription: String? {
    switch self {
    case .invalidCode:
      return "유효하지 않은 인증 코드입니다"
    case .verifyFailed:
      return "인증에 실패했습니다"
    case .networkError:
      return "네트워크 연결을 확인해주세요"
    case .unknownError:
      return "알 수 없는 오류가 발생했습니다"
    }
  }
}

public extension OnBoardingError {
  static func from(_ error: Error) -> OnBoardingError {
    if let onBoardingError = error as? OnBoardingError {
      return onBoardingError
    }
    return .unknownError
  }
}

public final class MockOnBoardingRepository: OnBoardingInterface, @unchecked Sendable {
  

  // MARK: - Configuration
  public enum Configuration {
    case success
    case failure
    case invalidCode
    case networkError
    case memberRole
    case managerRole
    case customDelay(TimeInterval)

    var shouldSucceed: Bool {
      switch self {
      case .success, .memberRole, .managerRole, .customDelay:
        return true
      case .failure, .invalidCode, .networkError:
        return false
      }
    }

    var delay: TimeInterval {
      switch self {
      case .customDelay(let delay):
        return delay
      default:
        return 0.5 // 실제 네트워크 지연 시뮬레이션
      }
    }

    var staffType: Staff {
      switch self {
      case .managerRole:
        return .manager
      default:
        return .member
      }
    }

    var mockGenerationID: Int {
      switch self {
      case .managerRole:
        return 2024
      default:
        return 2025
      }
    }

    var error: OnBoardingError? {
      switch self {
      case .success, .memberRole, .managerRole, .customDelay:
        return nil
      case .failure:
        return .verifyFailed
      case .invalidCode:
        return .invalidCode
      case .networkError:
        return .networkError
      }
    }
  }

  // MARK: - Properties
  private var configuration: Configuration = .success
  private var verifyCallCount = 0
  private var lastVerifyCall: Date?
  private var fetchJobsCallCount = 0
  private var lastFetchJobsCall: Date?
  private var fetchTeamsCallCount = 0
  private var lastFetchTeamsCall: Date?
  private var fetchManagingCallCount = 0
  private var lastFetchManagingCall: Date?

  // MARK: - Initialization

  public init(configuration: Configuration = .success) {
    self.configuration = configuration
  }

  // MARK: - Configuration Methods

  public func setConfiguration(_ configuration: Configuration) {
    self.configuration = configuration
    verifyCallCount = 0
    lastVerifyCall = nil
    fetchJobsCallCount = 0
    lastFetchJobsCall = nil
    fetchTeamsCallCount = 0
    lastFetchTeamsCall = nil
    fetchManagingCallCount = 0
    lastFetchManagingCall = nil
  }

  public func getVerifyCallCount() -> Int {
    return verifyCallCount
  }

  public func getLastVerifyCall() -> Date? {
    return lastVerifyCall
  }

  public func getFetchJobsCallCount() -> Int {
    return fetchJobsCallCount
  }

  public func getLastFetchJobsCall() -> Date? {
    return lastFetchJobsCall
  }

  public func getFetchTeamsCallCount() -> Int {
    return fetchTeamsCallCount
  }

  public func getLastFetchTeamsCall() -> Date? {
    return lastFetchTeamsCall
  }

  public func getFetchManagingCallCount() -> Int {
    return fetchManagingCallCount
  }

  public func getLastFetchManagingCall() -> Date? {
    return lastFetchManagingCall
  }

  public func reset() {
    configuration = .success
    verifyCallCount = 0
    lastVerifyCall = nil
    fetchJobsCallCount = 0
    lastFetchJobsCall = nil
    fetchTeamsCallCount = 0
    lastFetchTeamsCall = nil
    fetchManagingCallCount = 0
    lastFetchManagingCall = nil
  }

  // MARK: - OnBoardingInterface Implementation

  public func verifyCode(code: String) async throws(OnBoardingError) -> VerifyCodeEntity {
    // Track call
    verifyCallCount += 1
    lastVerifyCall = Date()

    // Apply delay
    if configuration.delay > 0 {
      try? await Task.sleep(for: .seconds(configuration.delay))
    }

    // 코드 유효성 검사 (기본적인 검사)
    guard !code.isEmpty, code.count >= 4 else {
      throw OnBoardingError.invalidCode
    }

    // Configuration 기반 응답 처리
    if !configuration.shouldSucceed, let error = configuration.error {
      throw error
    }

    // 특정 코드에 따른 응답 분기 처리
    switch code {
    case "1234", "test", "member":
      return VerifyCodeEntity(
        generationID: 2025,
        type: .member
      )

    case "5678", "admin", "manager":
      return VerifyCodeEntity(
        generationID: 2024,
        type: .manager
      )

    case "error", "fail":
      throw OnBoardingError.verifyFailed

    case "network":
      throw OnBoardingError.networkError

    case "invalid", "wrong":
      throw OnBoardingError.invalidCode

    default:
      // Configuration에 따른 기본 응답
      return VerifyCodeEntity(
        generationID: configuration.mockGenerationID,
        type: configuration.staffType
      )
    }
  }

  public func fetchJobs() async throws(OnBoardingError) -> [SelectJob] {
    // Track call
    fetchJobsCallCount += 1
    lastFetchJobsCall = Date()

    // Apply delay
    if configuration.delay > 0 {
      try? await Task.sleep(for: .seconds(configuration.delay))
    }

    // Configuration 기반 응답 처리
    if !configuration.shouldSucceed, let error = configuration.error {
      throw error
    }

    // Mock jobs data - 다양한 직무를 순환하면서 반환
    let mockJobs: [SelectJob] = [
      SelectJob(
        jobKeys: "BACKEND",
        job: .backend
      ),
      SelectJob(
        jobKeys: "FRONTEND",
        job: .frontend
      ),
      SelectJob(
        jobKeys: "DESIGNER",
        job: .designer
      ),
      SelectJob(
        jobKeys: "PM",
        job: .pm
      ),
      SelectJob(
        jobKeys: "ANDROID",
        job: .android
      ),
      SelectJob(
        jobKeys: "IOS",
        job: .ios
      )
    ]

    // Configuration에 따른 응답
    switch configuration {
    case .memberRole:
      // 일반 멤버는 개발 직무들만
      return mockJobs.filter { $0.job != .pm }
    case .managerRole:
      // 매니저는 PM 직무만
      return [SelectJob(jobKeys: "PM", job: .pm)]
    default:
      // 기본적으로 모든 직무 반환
      return mockJobs
    }
  }

  public func fetchTeams(generationId: Int) async throws(OnBoardingError) -> [SelectTeamEntity] {
    // Track call
    fetchTeamsCallCount += 1
    lastFetchTeamsCall = Date()

    // Apply delay
    if configuration.delay > 0 {
      try? await Task.sleep(for: .seconds(configuration.delay))
    }

    // Configuration 기반 응답 처리
    if !configuration.shouldSucceed, let error = configuration.error {
      throw error
    }

    let availableTeams = SelectTeams.allCases.filter { $0 != .unknown }
    let baseTeamId = max(generationId, 0) * 100

    return availableTeams.enumerated().map { index, team in
      SelectTeamEntity(
        teamId: baseTeamId + index + 1,
        teams: team
      )
    }
  }

  public func fetchManaging() async throws(OnBoardingError) -> [SelectManaging] {
    // Track call
    fetchManagingCallCount += 1
    lastFetchManagingCall = Date()

    // Apply delay
    if configuration.delay > 0 {
      try? await Task.sleep(for: .seconds(configuration.delay))
    }

    // Configuration 기반 응답 처리
    if !configuration.shouldSucceed, let error = configuration.error {
      throw error
    }

    let mockManaging = StaffManaging.allCases.map { managing in
      SelectManaging(
        managingKeys: managing.apiKey,
        managing: managing
      )
    }

    switch configuration {
    case .memberRole:
      return []
    default:
      return mockManaging
    }
  }
}

// MARK: - Convenience Static Methods

public extension MockOnBoardingRepository {

  /// Creates a pre-configured instance for success scenario with member role
  static func success() -> MockOnBoardingRepository {
    return MockOnBoardingRepository(configuration: .success)
  }

  /// Creates a pre-configured instance for failure scenario
  static func failure() -> MockOnBoardingRepository {
    return MockOnBoardingRepository(configuration: .failure)
  }

  /// Creates a pre-configured instance for invalid code scenario
  static func invalidCode() -> MockOnBoardingRepository {
    return MockOnBoardingRepository(configuration: .invalidCode)
  }

  /// Creates a pre-configured instance for member role scenario
  static func memberRole() -> MockOnBoardingRepository {
    return MockOnBoardingRepository(configuration: .memberRole)
  }

  /// Creates a pre-configured instance for manager role scenario
  static func managerRole() -> MockOnBoardingRepository {
    return MockOnBoardingRepository(configuration: .managerRole)
  }

  /// Creates a pre-configured instance for network error scenario
  static func networkError() -> MockOnBoardingRepository {
    return MockOnBoardingRepository(configuration: .networkError)
  }

  /// Creates a pre-configured instance with custom delay
  static func withDelay(_ delay: TimeInterval) -> MockOnBoardingRepository {
    return MockOnBoardingRepository(configuration: .customDelay(delay))
  }
}
