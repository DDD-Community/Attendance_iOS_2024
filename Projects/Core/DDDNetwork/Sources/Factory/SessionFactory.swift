//
//  SessionFactory.swift
//  DDDNetwork
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

import DDDNetworkInterface

import Alamofire

enum SessionFactory {
  static func plain() -> Session {
    Session(
      configuration: configuration,
      eventMonitors: [DDDEventMonitor()]
    )
  }

  /// 요청별 인증 조립용 공유 인터셉터 묶음.
  /// `AuthenticationInterceptor` 인스턴스가 하나여야 refresh single-flight 가 보장된다 —
  /// authorizing(요청 조립)과 credentials(로그인 / 로그아웃 교체)가 같은 인스턴스를 본다.
  static func authorization(
    store: CredentialStore,
    refresher: TokenRefreshing
  ) -> (authorizing: AuthorizingInterceptor, credentials: any CredentialUpdating) {
    let interceptor = AuthenticationInterceptor(
      authenticator: DDDAuthenticator(refresher: refresher, store: store),
      credential: store.load()
    )
    return (
      AuthorizingInterceptor(base: interceptor),
      CredentialUpdater(interceptor: interceptor)
    )
  }

  private static var configuration: URLSessionConfiguration {
    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = DefaultHeaders.headers.dictionary
    return configuration
  }
}
