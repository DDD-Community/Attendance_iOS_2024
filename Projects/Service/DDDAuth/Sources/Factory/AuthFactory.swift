//
//  AuthFactory.swift
//  DDDAuth
//
//  Created by DDD on 9/1/26.
//

import Foundation
import os

import DDDAuthInterface
import DDDNetwork
import DDDNetworkInterface
import DDDStorageInterface

/// secure storage, refresh client, authenticated client를 하나의 인증 서비스로 조립한다.
public enum AuthFactory {
  /// refresh 전용 클라이언트와 secure storage로 완성된 인증 서비스를 생성한다.
  public static func make(
    refreshClient: any DDDNetworkClient,
    storage: any SecureStorage
  ) -> any AuthService & AuthenticatedClientProvider {
    let store = GuardedCredentialStore(base: KeychainCredentialStore(storage: storage))
    let relay = AuthFailureRelay()
    let authenticated = NetworkClientFactory.unified(
      store: store,
      refresher: TokenRefresher(client: refreshClient) {
        await relay.fire()
      }
    )
    let auth = DDDAuth(
      authenticatedClient: authenticated.client,
      store: store,
      credentials: authenticated.credentials
    )
    relay.set { [weak auth] in
      await auth?.handleAuthFailure()
    }
    return auth
  }
}

private final class AuthFailureRelay: Sendable {
  /// 동기 Factory 조립 중 나중에 생성되는 DDDAuth 실패 핸들러를 연결한다.
  private let handler = OSAllocatedUnfairLock<(@Sendable () async -> Void)?>(initialState: nil)

  /// DDDAuth 생성 이후 refresh 실패 핸들러를 원자적으로 등록한다.
  func set(_ handler: @escaping @Sendable () async -> Void) {
    self.handler.withLock {
      $0 = handler
    }
  }

  /// 등록된 실패 핸들러를 lock 밖에서 비동기로 실행한다.
  func fire() async {
    let handler = handler.withLock {
      return $0
    }
    await handler?()
  }
}
