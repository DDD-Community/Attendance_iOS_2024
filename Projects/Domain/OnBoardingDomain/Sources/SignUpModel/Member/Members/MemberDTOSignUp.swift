//
//  MemberDTOSignUp.swift
//  OnBoardingDomain
//
//  Created by DDD on 11/4/24.
//

import Foundation

import OnBoardingDomainInterface

public struct MemberDTOSignUp: Codable, Sendable, Equatable {
  public var uid: String
  public var memberid: String
  public var email: String
  public var name: String
  public var role: SelectPart
  public var memberType: MemberType
  public var memberTeam: SelectTeam
  public var isAdmin: Bool
  /// 기수
  public var generation: Int
  
  public init(
    uid: String,
    memberid: String,
    email: String,
    name: String,
    role: SelectPart,
    memberType: MemberType,
    memberTeam: SelectTeam,
    isAdmin: Bool,
    generation: Int
  ) {
    self.uid = uid
    self.memberid = memberid
    self.email = email
    self.name = name
    self.role = role
    self.memberType = memberType
    self.memberTeam = memberTeam
    self.isAdmin = isAdmin
    self.generation = generation
  }
}
