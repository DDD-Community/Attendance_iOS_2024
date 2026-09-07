//
//  AuthorizingInterceptor.swift
//  DDDNetwork
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

import Alamofire

/// 공유 `AuthenticationInterceptor` 를 감싸, credential 유무로 인증 파이프라인을 우회하는 조건부 래퍼.
/// 비로그인 상태에서 인터셉터가 `missingCredential` 로 요청을 실패시키는 걸 막는다.
struct AuthorizingInterceptor: RequestInterceptor {
  let base: AuthenticationInterceptor<DDDAuthenticator>

  func adapt(
    _ urlRequest: URLRequest,
    for session: Session,
    completion: @escaping @Sendable (Result<URLRequest, any Error>) -> Void
  ) {
    guard base.credential != nil else {
      completion(.success(urlRequest))
      return
    }
    base.adapt(urlRequest, for: session, completion: completion)
  }

  func retry(
    _ request: Request,
    for session: Session,
    dueTo error: any Error,
    completion: @escaping @Sendable (RetryResult) -> Void
  ) {
    guard base.credential != nil else {
      completion(.doNotRetry)
      return
    }
    base.retry(request, for: session, dueTo: error, completion: completion)
  }
}
