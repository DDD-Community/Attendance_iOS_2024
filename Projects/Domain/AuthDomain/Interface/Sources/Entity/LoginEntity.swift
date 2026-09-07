//
//  LoginEntity.swift
//  Entity
//
//  Created by DDD on 12/29/25.
//

import Foundation

import ProfileDomainInterface

public struct LoginEntity: Equatable {
  public let name: String
  public let provider: SocialType
  public let token: AuthTokens
  public let isNewUser: Bool
  public let role: Staff?

  public init(
    name: String,
    isNewUser: Bool,
    provider: SocialType,
    token: AuthTokens,
    role: Staff?
  ) {
    self.name = name
    self.isNewUser = isNewUser
    self.provider = provider
    self.token = token
    self.role = role
  }
}
