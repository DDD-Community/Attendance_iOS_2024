//
//  AuthInterface.swift
//  DomainInterface
//
//  Created by DDD on 7/23/25.
//

import Foundation

import ProfileDomainInterface

import Dependencies

/// Auth 관련 비즈니스 로직을 위한 Interface 프로토콜
public protocol AuthInterface: Sendable {
  func login(provider: SocialType, token: String) async throws(AuthError) -> LoginEntity
  func refresh() async throws(AuthError) -> AuthTokens
  func withDraw(token: String) async throws(AuthError) -> WithdrawEntity
  func logout() async throws(AuthError) -> AuthExitEntity
  func updateSessionCredential(with tokens: AuthTokens) async
}

/// Auth Repository의 DependencyKey 구조체
public enum AuthRepositoryDependency: TestDependencyKey {

  public static var testValue: AuthInterface {
    MockAuthRepository()
  }

  public static var previewValue: AuthInterface = testValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var authRepository: AuthInterface {
    get { self[AuthRepositoryDependency.self] }
    set { self[AuthRepositoryDependency.self] = newValue }
  }
}
