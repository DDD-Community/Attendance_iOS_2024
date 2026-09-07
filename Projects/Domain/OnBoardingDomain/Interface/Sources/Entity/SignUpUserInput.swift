//
//  SignUpUserInput.swift
//  Entity
//
//  Created by DDD on 1/1/26.
//

import Foundation

import AuthDomainInterface
import ProfileDomainInterface

public struct SignUpUserInput  {
  public let name: String
  public let generationId: Int
  public let jobRole: SelectParts
  public let teamId: Int?
  public let managerRoles: [StaffManaging]?
  public let provider: SocialType
  public let token: String
  public let oauthRefreshToken: String?
  public let invitationCode: String

  public init(
    name: String,
    generationId: Int,
    jobRole: SelectParts,
    teamId: Int?,
    managerRoles: [StaffManaging]?,
    provider: SocialType,
    token: String,
    oauthRefreshToken: String?,
    invitationCode: String
  ) {
    self.name = name
    self.generationId = generationId
    self.jobRole = jobRole
    self.teamId = teamId
    self.managerRoles = managerRoles
    self.provider = provider
    self.token = token
    self.oauthRefreshToken = oauthRefreshToken
    self.invitationCode = invitationCode
  }
}
