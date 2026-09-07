//
//  CredentialUpdater.swift
//  DDDNetwork
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

import DDDNetworkInterface

import Alamofire

/// `AuthenticationInterceptor` 의 credential 을 교체하는 `CredentialUpdating` 구현.
/// 인터셉터 내부가 스레드 안전(@Protected)하므로 그대로 위임한다.
final class CredentialUpdater: CredentialUpdating, @unchecked Sendable {
  private let interceptor: AuthenticationInterceptor<DDDAuthenticator>

  init(interceptor: AuthenticationInterceptor<DDDAuthenticator>) {
    self.interceptor = interceptor
  }

  func update(_ credential: DDDCredential?) {
    interceptor.credential = credential
  }
}
