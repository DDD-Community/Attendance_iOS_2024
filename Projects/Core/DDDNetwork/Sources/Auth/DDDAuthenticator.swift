//
//  DDDAuthenticator.swift
//  DDDNetwork
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

import DDDNetworkInterface

import Alamofire

/// Alamofire `Authenticator` 구현. 토큰 주입 / refresh / 401 판정을 담당한다.
/// refresh 동시요청 중복 방지(single-flight)는 `AuthenticationInterceptor` 가 처리한다.
final class DDDAuthenticator: Authenticator {
  typealias Credential = DDDCredential

  private let refresher: TokenRefreshing
  private let store: CredentialStore

  init(refresher: TokenRefreshing, store: CredentialStore) {
    self.refresher = refresher
    self.store = store
  }

  /// 요청에 Bearer 토큰 주입.
  func apply(_ credential: DDDCredential, to urlRequest: inout URLRequest) {
    urlRequest.headers.add(.authorization(bearerToken: credential.accessToken))
  }

  /// 만료 / 401 시 새 토큰 발급. async refresher 를 completion 으로 연결한다.
  func refresh(
    _ credential: DDDCredential,
    for _: Session,
    completion: @escaping @Sendable (Result<DDDCredential, any Error>) -> Void
  ) {
    Task {
      do {
        let renewed = try await refresher.refresh(credential)
        store.save(renewed) // refresh 된 토큰 영속화
        completion(.success(renewed))
      } catch {
        completion(.failure(error))
      }
    }
  }

  /// 401 이면 인증 에러로 간주 → refresh 트리거.
  func didRequest(
    _: URLRequest,
    with response: HTTPURLResponse,
    failDueToAuthenticationError _: any Error
  ) -> Bool {
    response.statusCode == 401
  }

  /// 요청의 Authorization 헤더가 현재 credential 토큰과 일치하는지.
  func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: DDDCredential) -> Bool {
    urlRequest.headers["Authorization"] == HTTPHeader.authorization(bearerToken: credential.accessToken).value
  }
}
