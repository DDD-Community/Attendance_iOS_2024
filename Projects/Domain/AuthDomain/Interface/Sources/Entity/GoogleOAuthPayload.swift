//
//  GoogleOAuthPayload.swift
//  Entity
//
//  Created by DDD on 12/29/25.
//

import Foundation

import ProfileDomainInterface

public struct GoogleOAuthPayload {
  public let idToken: String
  public let accessToken: String?
  public let authorizationCode: String?
  public let displayName: String?
  
  public init(
    idToken: String,
    accessToken: String?,
    authorizationCode: String?,
    displayName: String?
  ) {
    self.idToken = idToken
    self.accessToken = accessToken
    self.authorizationCode = authorizationCode
    self.displayName = displayName
  }
}
