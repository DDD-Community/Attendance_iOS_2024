//
//  DDDAuth.swift
//  DDDAuth
//
//  Created by DDD on 9/1/26.
//

import Foundation

import DDDAuthInterface
import DDDNetworkInterface

/// 토큰 저장소와 네트워크 인증 세션의 상태를 하나의 생명주기로 관리한다.
actor DDDAuth: AuthService, AuthenticatedClientProvider {
  /// 인증 상태와 함께 조립되지만 actor 격리 없이 안전하게 공유할 수 있는 불변 클라이언트다.
  nonisolated let authenticatedClient: any DDDNetworkClient

  /// 로그인·로그아웃과 refresh 저장 간 경쟁 상태를 차단하는 credential 저장소다.
  private let store: GuardedCredentialStore
  /// 실행 중인 네트워크 세션에 최신 credential을 반영하는 갱신기다.
  private let credentials: any CredentialUpdating

  /// 동일한 저장소와 네트워크 세션을 하나의 인증 생명주기로 묶는다.
  init(
    authenticatedClient: any DDDNetworkClient,
    store: GuardedCredentialStore,
    credentials: any CredentialUpdating
  ) {
    self.authenticatedClient = authenticatedClient
    self.store = store
    self.credentials = credentials
  }

  /// 저장소에 사용할 수 있는 credential이 남아 있는지 반환한다.
  var isLoggedIn: Bool {
    return store.load() != nil
  }

  var refreshToken: String? {
    return store.load()?.refreshToken
  }

  /// 새 로그인 토큰을 저장하고 이후 인증 요청에 즉시 반영한다.
  func signIn(accessToken: String, refreshToken: String) {
    store.allowSaves()
    let credential = DDDCredential(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: JWTDecoder.decodeExpiration(accessToken)
    )
    store.save(credential)
    credentials.update(credential)
  }

  /// 영속 credential과 실행 중인 네트워크 세션을 함께 비운다.
  func signOut() {
    store.clear()
    credentials.update(nil)
  }

  /// refresh token 거부 시 세션을 정리하고 App 계층에 만료 이벤트를 전달한다.
  func handleAuthFailure() {
    signOut()
    // 화면 전환은 App 계층의 책임이므로 서비스는 세션 정리 후 이벤트만 알린다.
    NotificationCenter.default.post(name: .dddAuthSessionDidExpire, object: nil)
  }
}
