//
//  LoginResponseDTO+.swift
//  AuthDomain
//
//  Created by DDD on 5/9/25.
//

import Foundation

import AuthDomainInterface

public extension LoginResponseDTO {
  func toDomain() -> LoginEntity {
    let token = AuthTokens(
      accessToken: self.accessToken ?? "",
      refreshToken: self.refreshToken ?? "",
      oauthRefreshToken: self.oauthRefreshToken
    )

    return LoginEntity(
      name: self.name ?? "",
      isNewUser: self.isNewUser,
      provider: SocialType(rawValue: oauthProvider?.lowercased() ?? "") ?? .apple,
      token: token,
      role: Staff.from(apiKey: self.role ?? "")
    )
  }
}
