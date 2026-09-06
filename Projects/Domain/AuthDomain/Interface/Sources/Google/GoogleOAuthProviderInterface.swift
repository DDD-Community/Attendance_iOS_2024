//
//  GoogleOAuthProviderInterface.swift
//  DomainInterface
//
//  Created by DDD on 12/29/25.
//

import Foundation

import ProfileDomainInterface

import Dependencies

/// Google OAuth Provider Interface 프로토콜
public protocol GoogleOAuthProviderInterface: Sendable {
  func signInWithToken(
    token: String
  ) async throws(AuthError) -> String
}

/// Google OAuth Provider의 DependencyKey 구조체
public enum GoogleOAuthProviderDependency: TestDependencyKey {

  public static var testValue: GoogleOAuthProviderInterface {
    MockGoogleOAuthProvider()
  }

  public static var previewValue: GoogleOAuthProviderInterface = testValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var googleOAuthProvider: GoogleOAuthProviderInterface {
    get { self[GoogleOAuthProviderDependency.self] }
    set { self[GoogleOAuthProviderDependency.self] = newValue }
  }
}

/// 테스트용 Mock 구현체
public struct MockGoogleOAuthProvider: GoogleOAuthProviderInterface {
  public init() {}

  public func signInWithToken(
    token: String
  ) async throws(AuthError) -> String {
    return "mock_google_token"
  }
}
