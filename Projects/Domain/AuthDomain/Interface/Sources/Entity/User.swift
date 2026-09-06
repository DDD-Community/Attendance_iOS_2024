//
//  User.swift
//  Entity
//
//  Created by DDD on 5/12/26.
//

import Foundation

import ProfileDomainInterface

public enum UserRole: String, Equatable {
  case member
  case moderator
}

public struct User: Equatable {
  public static let shared = User()

  public var userEmail: String
  public var userName: String
  public var signUpName: String
  public var userUid: String
  public var accessToken: String
  public var refreshToken: String
  public var inviteCodeId: String?
  public var userRole: UserRole?
  public var managing: StaffManaging?
  public var role: SelectParts?
  public var memberTeam: SelectTeams?
  public var staffRole: Staff?

  public init(
    userEmail: String = "",
    userName: String = "",
    signUpName: String = "",
    userUid: String = "",
    accessToken: String = "",
    refreshToken: String = "",
    inviteCodeId: String? = nil,
    userRole: UserRole? = .moderator,
    managing: StaffManaging? = nil,
    role: SelectParts? = nil,
    memberTeam: SelectTeams? = nil,
    staffRole: Staff? = nil
  ) {
    self.userEmail = userEmail
    self.userName = userName
    self.signUpName = signUpName
    self.userUid = userUid
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.inviteCodeId = inviteCodeId
    self.userRole = userRole
    self.managing = managing
    self.role = role
    self.memberTeam = memberTeam
    self.staffRole = staffRole
  }
}
