//
//  MockUserSession.swift
//  AuthDomainTests
//
//  Created by DDD on 9/4/26.
//

import Foundation

import AuthDomainInterface

@MainActor
final class MockUserSession {
  var currentSession: UserSession
  var staffRole: Staff?

  private(set) var sessionUpdateCount = 0
  private(set) var staffRoleUpdateCount = 0
  private var sessionHistory: [UserSession] = []
  private var staffRoleHistory: [Staff?] = []

  init(
    initialSession: UserSession = .empty,
    initialStaffRole: Staff? = nil
  ) {
    self.currentSession = initialSession
    self.staffRole = initialStaffRole
  }

  func updateSession(_ session: UserSession) {
    sessionUpdateCount += 1
    sessionHistory.append(currentSession)
    currentSession = session
  }

  func updateStaffRole(_ role: Staff?) {
    staffRoleUpdateCount += 1
    staffRoleHistory.append(staffRole)
    staffRole = role
  }

  func updateOAuthRefreshToken(_ token: String?) {
    sessionUpdateCount += 1
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

  func reset() {
    currentSession = .empty
    staffRole = nil
    sessionUpdateCount = 0
    staffRoleUpdateCount = 0
    sessionHistory.removeAll()
    staffRoleHistory.removeAll()
  }

  func setupNewUser(name: String, provider: SocialType) {
    currentSession = UserSession(
      userID: 0,
      name: name,
      selectPart: SelectParts.all,
      userRole: Staff.member,
      managing: [],
      provider: provider,
      selectTeam: SelectTeams.unknown,
      selectTeamId: nil,
      token: "",
      generationId: 0,
      accessToken: "",
      oauthRefreshToken: nil,
      inviteCode: "",
      generation: ""
    )
  }

  func setupExistingUser(
    userID: Int = 123,
    name: String = "Existing User",
    role: Staff = .member,
    provider: SocialType = .google
  ) {
    currentSession = UserSession(
      userID: userID,
      name: name,
      selectPart: SelectParts.ios,
      userRole: role,
      managing: [],
      provider: provider,
      selectTeam: SelectTeams.ios1,
      selectTeamId: 1,
      token: "existing_token",
      generationId: 1,
      accessToken: "existing_access_token",
      oauthRefreshToken: provider == .apple ? nil : "existing_oauth_token",
      inviteCode: "ABC123",
      generation: "1기"
    )
    staffRole = role
  }

  func wasSessionUpdated() -> Bool { sessionUpdateCount > 0 }
  func wasStaffRoleUpdated() -> Bool { staffRoleUpdateCount > 0 }
  func getPreviousSession() -> UserSession? { sessionHistory.last }
  func getPreviousStaffRole() -> Staff?? { staffRoleHistory.last }
  func hasOAuthRefreshToken() -> Bool { currentSession.oauthRefreshToken != nil }
  func verifyOAuthRefreshToken(_ expectedToken: String?) -> Bool {
    currentSession.oauthRefreshToken == expectedToken
  }

  @MainActor
  static func success() -> MockUserSession {
    let mock = MockUserSession()
    mock.setupExistingUser()
    return mock
  }

  func getCurrentStaffRole() -> Staff? { staffRole }
}

extension UserSession {
  static func makeTestSession(
    userID: Int = 123,
    name: String = "Test User",
    provider: SocialType = .google,
    role: Staff = .member,
    isNewUser: Bool = false
  ) -> UserSession {
    UserSession(
      userID: isNewUser ? 0 : userID,
      name: name,
      selectPart: isNewUser ? .all : .ios,
      userRole: role,
      managing: [],
      provider: provider,
      selectTeam: isNewUser ? .unknown : .ios1,
      selectTeamId: isNewUser ? nil : 1,
      token: isNewUser ? "" : "test_token",
      generationId: isNewUser ? 0 : 1,
      accessToken: "",
      oauthRefreshToken: provider == .apple ? nil : "test_oauth_token",
      inviteCode: isNewUser ? "" : "ABC123",
      generation: isNewUser ? "" : "1기"
    )
  }

  static let mockAppleUser = UserSession(
    userID: 456,
    name: "Apple User",
    selectPart: SelectParts.designer,
    userRole: Staff.manager,
    managing: [StaffManaging.teamManaging, StaffManaging.photo],
    provider: .apple,
    selectTeam: SelectTeams.ios2,
    selectTeamId: 2,
    token: "apple_token",
    generationId: 2,
    accessToken: "apple_access_token",
    oauthRefreshToken: nil,
    inviteCode: "XYZ789",
    generation: "2기"
  )

  static let mockGoogleUser = UserSession(
    userID: 789,
    name: "Google User",
    selectPart: SelectParts.ios,
    userRole: Staff.member,
    managing: [],
    provider: .google,
    selectTeam: SelectTeams.and1,
    selectTeamId: 3,
    token: "google_token",
    generationId: 1,
    accessToken: "google_access_token",
    oauthRefreshToken: "google_oauth_refresh",
    inviteCode: "DEF456",
    generation: "1기"
  )
}
