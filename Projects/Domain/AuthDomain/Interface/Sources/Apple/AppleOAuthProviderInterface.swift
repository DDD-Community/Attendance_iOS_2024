//
//  AppleOAuthProviderInterface.swift
//  DomainInterface
//
//  Created by DDD on 12/29/25.
//

import AuthenticationServices
import Foundation

import ProfileDomainInterface

import Dependencies

/// Apple OAuth Provider Interface 프로토콜
public protocol AppleOAuthProviderInterface: Sendable {
  func signInWithCredential(
    credential: ASAuthorizationAppleIDCredential,
    nonce: String
  ) async throws(AuthError) -> AppleOAuthPayload

  func signIn() async throws(AuthError) -> AppleOAuthPayload
}

/// Apple OAuth Provider의 DependencyKey 구조체
public enum AppleOAuthProviderDependency: TestDependencyKey {

  public static var testValue: AppleOAuthProviderInterface {
    MockAppleOAuthProvider()
  }

  public static var previewValue: AppleOAuthProviderInterface = testValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var appleOAuthProvider: AppleOAuthProviderInterface {
    get { self[AppleOAuthProviderDependency.self] }
    set { self[AppleOAuthProviderDependency.self] = newValue }
  }
}

/// 테스트용 Mock 구현체
public struct MockAppleOAuthProvider: AppleOAuthProviderInterface {
  public init() {}

  public func signInWithCredential(
    credential: ASAuthorizationAppleIDCredential,
    nonce: String
  ) async throws(AuthError) -> AppleOAuthPayload {
    return AppleOAuthPayload(
      idToken: "mock_id_token",
      authorizationCode: "mock_auth_code",
      displayName: "Mock User",
      nonce: nonce
    )
  }

  public func signIn() async throws(AuthError) -> AppleOAuthPayload {
    return AppleOAuthPayload(
      idToken: "mock_id_token",
      authorizationCode: "mock_auth_code",
      displayName: "Mock User",
      nonce: "mock_nonce"
    )
  }
}
