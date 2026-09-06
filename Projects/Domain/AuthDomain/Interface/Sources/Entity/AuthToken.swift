//
//  AuthToken.swift
//  Entity
//
//  Created by DDD on 12/29/25.
//

import Foundation

import ProfileDomainInterface

public struct AuthTokens: Equatable, Hashable {
  public let accessToken: String
  public let refreshToken: String
  public let oauthRefreshToken: String?

  public init(
    accessToken: String,
    refreshToken: String,
    oauthRefreshToken: String? = nil
  ) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.oauthRefreshToken = oauthRefreshToken
  }
}
