//
//  MockUserSession.swift
//  DomainInterface
//
//  Created by DDD on 2026-04-16
//

import Foundation

import ProfileDomainInterface

public final class MockUserSession: @unchecked Sendable {
  // MARK: - Configuration
  public enum Configuration {
    case success
    case newUser
    case existingUser
    case appleUser
    case googleUser
    case managerUser
  }

  // MARK: - State
  private var configuration: Configuration = .success
  private var updateSessionCallCount = 0
  private var updateStaffRoleCallCount = 0
  private var updateOAuthTokenCallCount = 0
  private var currentSession: UserSession = .empty
  private var currentStaffRole: Staff?
  private var sessionHistory: [UserSession] = []

  // MARK: - Public Configuration Methods
  public init(configuration: Configuration = .success) {
    self.configuration = configuration
    setupInitialState()
  }

  public static func success() -> MockUserSession {
    MockUserSession(configuration: .success)
  }

  public static func newUser() -> MockUserSession {
    MockUserSession(configuration: .newUser)
  }

  public static func existingUser() -> MockUserSession {
    MockUserSession(configuration: .existingUser)
  }

  public static func appleUser() -> MockUserSession {
    MockUserSession(configuration: .appleUser)
  }

  public static func googleUser() -> MockUserSession {
    MockUserSession(configuration: .googleUser)
  }

  public static func managerUser() -> MockUserSession {
    MockUserSession(configuration: .managerUser)
  }

  // MARK: - Call Count Getters
  public func getUpdateSessionCallCount() -> Int { updateSessionCallCount }
  public func getUpdateStaffRoleCallCount() -> Int { updateStaffRoleCallCount }
  public func getUpdateOAuthTokenCallCount() -> Int { updateOAuthTokenCallCount }
  public func getCurrentSession() -> UserSession { currentSession }
  public func getCurrentStaffRole() -> Staff? { currentStaffRole }
  public func getSessionHistory() -> [UserSession] { sessionHistory }

  // MARK: - Session Management Methods
  public func updateSession(_ session: UserSession) {
    updateSessionCallCount += 1
    sessionHistory.append(currentSession)
    currentSession = session
  }

  public func updateStaffRole(_ role: Staff?) {
    updateStaffRoleCallCount += 1
    currentStaffRole = role
  }

  public func updateOAuthRefreshToken(_ token: String?) {
    updateOAuthTokenCallCount += 1
    sessionHistory.append(currentSession)

    currentSession = UserSession(
      userID: currentSession.userID,
      name: currentSession.name,
      selectPart: currentSession.selectPart,
      userRole: currentSession.userRole,
      managing: currentSession.managing,
      provider: currentSession.provider,
      selectTeam: currentSession.selectTeam,
      selectTeamId: currentSession.selectTeamId,
      token: currentSession.token,
      generationId: currentSession.generationId,
      accessToken: currentSession.accessToken,
      oauthRefreshToken: token,
      inviteCode: currentSession.inviteCode,
      generation: currentSession.generation
    )
  }

  // MARK: - Verification Helpers
  public func wasSessionUpdated() -> Bool {
    return updateSessionCallCount > 0
  }

  public func wasStaffRoleUpdated() -> Bool {
    return updateStaffRoleCallCount > 0
  }

  public func verifyOAuthRefreshToken(_ expectedToken: String?) -> Bool {
    return currentSession.oauthRefreshToken == expectedToken
  }

  public func hasOAuthRefreshToken() -> Bool {
    return currentSession.oauthRefreshToken != nil
  }

  public func reset() {
    configuration = .success
    updateSessionCallCount = 0
    updateStaffRoleCallCount = 0
    updateOAuthTokenCallCount = 0
    currentSession = .empty
    currentStaffRole = nil
    sessionHistory.removeAll()
    setupInitialState()
  }

  // MARK: - Private Helper Methods
  private func setupInitialState() {
    switch configuration {
    case .success:
      currentSession = .empty
      currentStaffRole = nil

    case .newUser:
      currentSession = UserSession(
        userID: 0,
        name: "New User",
        selectPart: .all,
        userRole: .member,
        managing: [],
        provider: .google,
        selectTeam: .unknown,
        selectTeamId: nil,
        token: "",
        generationId: 0,
        accessToken: "",
        oauthRefreshToken: nil,
        inviteCode: "",
        generation: ""
      )
      currentStaffRole = nil

    case .existingUser:
      currentSession = UserSession(
        userID: 123,
        name: "Existing User",
        selectPart: .ios,
        userRole: .member,
        managing: [],
        provider: .google,
        selectTeam: .ios1,
        selectTeamId: 1,
        token: "existing_token",
        generationId: 1,
        accessToken: "existing_access_token",
        oauthRefreshToken: "existing_oauth_token",
        inviteCode: "ABC123",
        generation: "1기"
      )
      currentStaffRole = .member

    case .appleUser:
      currentSession = UserSession(
        userID: 456,
        name: "Apple User",
        selectPart: .designer,
        userRole: .member,
        managing: [],
        provider: .apple,
        selectTeam: .ios2,
        selectTeamId: 2,
        token: "apple_token",
        generationId: 2,
        accessToken: "apple_access_token",
        oauthRefreshToken: nil, // Apple doesn't provide OAuth refresh token
        inviteCode: "XYZ789",
        generation: "2기"
      )
      currentStaffRole = .member

    case .googleUser:
      currentSession = UserSession(
        userID: 789,
        name: "Google User",
        selectPart: .ios,
        userRole: .member,
        managing: [],
        provider: .google,
        selectTeam: .and1,
        selectTeamId: 3,
        token: "google_token",
        generationId: 1,
        accessToken: "google_access_token",
        oauthRefreshToken: "google_oauth_refresh",
        inviteCode: "DEF456",
        generation: "1기"
      )
      currentStaffRole = .member

    case .managerUser:
      currentSession = UserSession(
        userID: 999,
        name: "Manager User",
        selectPart: .ios,
        userRole: .manager,
        managing: [.teamManaging],
        provider: .google,
        selectTeam: .ios1,
        selectTeamId: 1,
        token: "manager_token",
        generationId: 1,
        accessToken: "manager_access_token",
        oauthRefreshToken: "manager_oauth_refresh",
        inviteCode: "MGR123",
        generation: "1기"
      )
      currentStaffRole = .manager
    }
  }
}