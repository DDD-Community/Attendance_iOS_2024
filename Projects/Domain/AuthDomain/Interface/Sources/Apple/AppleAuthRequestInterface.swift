//
//  AppleAuthRequestInterface.swift
//  DomainInterface
//
//  Created by DDD on 12/26/25.
//

import AuthenticationServices
import Foundation

import ProfileDomainInterface

import Dependencies

public protocol AppleAuthRequestInterface: Sendable {
  func prepare(_ request: ASAuthorizationAppleIDRequest) -> String
}

///// OAuth Repository의 DependencyKey 구조체도
public enum AppleAuthRequestDependency: TestDependencyKey {

  public static var testValue: AppleAuthRequestInterface {
    MockAppleAuthRequest()
  }

  public static var previewValue: AppleAuthRequestInterface = testValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var appleManger: AppleAuthRequestInterface {
    get { self[AppleAuthRequestDependency.self] }
    set { self[AppleAuthRequestDependency.self] = newValue }
  }
}

