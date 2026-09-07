//
//  AuthUseCaseImpl.swift
//  AuthDomain
//
//  Created by DDD on 7/23/25.
//

import Foundation

import AuthDomainInterface

import ComposableArchitecture

public struct AuthUseCaseImpl: AuthUseCaseInterface {
  @Dependency(\.authRepository) var authRepository
  @Shared(.staffRole) var staffRole
  @Shared(.userSession) var userSession

  public init() {}

  // MARK: - API로 통해서 로그인
  public func login(
    provider: SocialType,
    token: String
  ) async throws(AuthError) -> LoginEntity {
    let authResult =  try await authRepository.login(provider: provider, token: token)
    $userSession.withLock {
      $0.oauthRefreshToken = authResult.token.oauthRefreshToken
    }
    return authResult
  }

  public func refresh() async throws(AuthError) -> AuthTokens {
    return try await authRepository.refresh()
  }

  public func logout() async throws(AuthError) -> AuthExitEntity {
    let logoutResult = try await authRepository.logout()
    $staffRole.withLock { $0 = nil }
    return logoutResult
  }

  public func withDraw(token: String) async throws(AuthError) -> WithdrawEntity {
    return try await authRepository.withDraw(token: token)
  }

  public func updateSessionCredential(with tokens: AuthTokens) async {
    await authRepository.updateSessionCredential(with: tokens)
  }
}
