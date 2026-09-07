//
//  Member.swift
//  OnBoardingDomain
//
//  Created by DDD on 11/4/24.
//

import Foundation

import OnBoardingDomainInterface

public struct Member: Codable, Sendable, Hashable, Equatable {
  /// Firebase Auth의 uid
  public var uid: String
  public var memberid: String
  public var email: String
  public var name: String
  public var role: SelectPart?
  public var memberType: MemberType
  public var managing: Managing?
  public var memberTeam: SelectTeam?
  public var snsURL: String
  public var createdAt: Date
  public var updatedAt: Date
  public var isAdmin: Bool
  
  /// 기수
  public var generation: Int
  
  public init(
    uid: String = "",
    memberid: String = "",
    email: String = "",
    name: String = "",
    role: SelectPart? = .all,
    memberType: MemberType = .notYet,
    managing: Managing? = nil,
    memberTeam: SelectTeam? = nil,
    snsURL: String? = nil,
    createdAt: Date = .now,
    updatedAt: Date = .now,
    isAdmin: Bool = false,
    generation: Int = 12
  ) {
    self.uid = uid
    self.memberid = memberid
    self.email = email
    self.name = name
    self.role = role
    self.memberType = memberType
    self.managing = managing
    self.memberTeam = memberTeam
    self.snsURL = snsURL ?? ""
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.isAdmin = isAdmin
    self.generation = generation
  }
}
