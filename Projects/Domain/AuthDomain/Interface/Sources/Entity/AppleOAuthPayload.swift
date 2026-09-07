//
//  AppleOAuthPayload.swift
//  Entity
//
//  Created by DDD on 12/29/25.
//

import Foundation

import ProfileDomainInterface

public struct AppleOAuthPayload {
  public let idToken: String
  public let authorizationCode: String?
  public let displayName: String?
  public let nonce: String
  
  public init(
    idToken: String,
    authorizationCode: String?,
    displayName: String?,
    nonce: String,
  ) {
    self.idToken = idToken
    self.authorizationCode = authorizationCode
    self.displayName = displayName
    self.nonce = nonce
  }
}
