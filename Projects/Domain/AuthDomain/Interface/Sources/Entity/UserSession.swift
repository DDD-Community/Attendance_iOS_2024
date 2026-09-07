//
//  UserSession.swift
//  Entity
//
//  Created by DDD on 12/31/25.
//

import Foundation

import ProfileDomainInterface

public struct UserSession: Equatable, Sendable {
  public var userID: Int
  public var name: String
  public var selectPart: SelectParts
  public var userRole: Staff
  public var managing: [StaffManaging]
  public var provider: SocialType
  public var selectTeam: SelectTeams
  public var selectTeamId: Int?
  public var token: String
  public var accessToken: String
  public var oauthRefreshToken: String?
  public var generationId : Int
  public var generation : String
  public var inviteCode: String

  public init(
    userID: Int = 0,
    name: String = "",
    selectPart: SelectParts = .all,
    userRole: Staff = .member,
    managing: [StaffManaging] = [],
    provider: SocialType = .apple,
    selectTeam: SelectTeams = .unknown,
    selectTeamId: Int? = nil,
    token: String = "",
    generationId: Int = .zero,
    accessToken: String = "",
    oauthRefreshToken: String? = nil,
    inviteCode: String = "",
    generation: String = ""
  ) {
    self.userID = userID
    self.name = name
    self.selectPart = selectPart
    self.userRole = userRole
    self.managing = managing
    self.provider = provider
    self.selectTeam = selectTeam
    self.token = token
    self.generationId = generationId
    self.selectTeamId = selectTeamId
    self.accessToken = accessToken
    self.oauthRefreshToken = oauthRefreshToken
    self.inviteCode = inviteCode
    self.generation = generation
  }

}


public extension UserSession {
  static let empty = UserSession()
}