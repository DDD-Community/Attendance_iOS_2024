//
//  UserDTOMember.swift
//  OnBoardingDomain
//
//  Created by DDD on 11/4/24.
//

import Foundation

import OnBoardingDomainInterface

public struct UserDTOMember: Codable, Sendable, Equatable, Hashable {
  public var uid: String
  public var memberid: String
  public var name: String
  public var email: String
  public var role: SelectPart
  public var memberType: MemberType
  public var managing: Managing
  public var memberTeam: SelectTeam?
  public var isAdmin: Bool
  /// 기수
  public var generation: Int
  
  public init(
    uid: String,
    memberid: String,
    name: String,
    email: String,
    role: SelectPart,
    memberType: MemberType,
    managing: Managing,
    memberTeam: SelectTeam? = nil,
    isAdmin: Bool,
    generation: Int
  ) {
    self.uid = uid
    self.memberid = memberid
    self.name = name
    self.email = email
    self.role = role
    self.memberType = memberType
    self.managing = managing
    self.memberTeam = memberTeam
    self.isAdmin = isAdmin
    self.generation = generation
  }
}
