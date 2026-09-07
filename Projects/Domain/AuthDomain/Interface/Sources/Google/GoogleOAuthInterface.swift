//
//  GoogleOAuthInterface.swift
//  DomainInterface
//
//  Created by DDD on 12/29/25.
//

import Foundation

import ProfileDomainInterface

import Dependencies

public protocol GoogleOAuthInterface: Sendable {
  func signIn() async throws(AuthError) -> GoogleOAuthPayload
}

public enum GoogleOAuthRepositoryDependencyKey: TestDependencyKey {
  public static var previewValue:  GoogleOAuthInterface {
    MockGoogleOAuthRepository()
  }
  public static var testValue:  GoogleOAuthInterface = MockGoogleOAuthRepository()
}

public extension DependencyValues {
  var googleOAuthRepository:  GoogleOAuthInterface {
    get { self[GoogleOAuthRepositoryDependencyKey.self] }
    set { self[GoogleOAuthRepositoryDependencyKey.self] = newValue }
  }
}
