//
//  AppleOAuthProvider.swift
//  AuthDomain
//
//  Created by DDD on 12/29/25.
//

import AuthenticationServices
import Foundation

import AuthDomainInterface
import DDDCoreLogger

import Dependencies
import Sharing

public final class AppleOAuthProvider: AppleOAuthProviderInterface, @unchecked Sendable {
  @Dependency(\.appleOAuthRepository) private var appleRepository: AppleOAuthInterface
  @Shared(.userSession) var userSession
  public init() {}

  public func signInWithCredential(
    credential: ASAuthorizationAppleIDCredential,
    nonce: String
  ) async throws(AuthError) -> AppleOAuthPayload {
    let payload = try await appleRepository.signInWithCredential(credential, nonce: nonce)
    DDDLogger.info("Apple sign-in completed through repository with credential", category: .auth)
    return payload
  }

  public func signIn() async throws(AuthError) -> AppleOAuthPayload {
    let payload = try await appleRepository.signIn()
    DDDLogger.info("Apple sign-in completed through repository (direct)", category: .auth)
    return payload
  }

  private func formatDisplayName(_ components: PersonNameComponents?) -> String? {
    guard let components else { return nil }
    let formatter = PersonNameComponentsFormatter()
    let name = formatter.string(from: components).trimmingCharacters(in: .whitespacesAndNewlines)
    return name.isEmpty ? nil : name
  }
}
