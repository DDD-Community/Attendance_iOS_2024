//
//  CoreMemberDTOSignUp.swift
//  OnBoardingDomain
//
//  Created by DDD on 11/4/24.
//

import Foundation

import OnBoardingDomainInterface

public struct CoreMemberDTOSignUp: Codable, Sendable, Equatable {
  public var uid: String
  public var memberid: String
  public var name: String
  public var email: String
  public var role: SelectPart
  public var memberType: MemberType
  public var managing: Managing
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
    managing: Managing,
    isAdmin: Bool,
    generation: Int
  ) {
    self.uid = uid
    self.memberid = memberid
    self.email = email
    self.name = name
    self.role = role
    self.memberType = memberType
    self.managing = managing
    self.isAdmin = isAdmin
    self.generation = generation
  }
}
