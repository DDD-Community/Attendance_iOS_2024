//
//  AuthenticationTests.swift
//  DDDNetworkTests
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation
import Testing

@testable import DDDNetwork
import DDDNetworkInterface

import Alamofire

@Suite("DDD 인증 파이프라인")
struct AuthenticationTests {
  private let current = DDDCredential(accessToken: "old-access", refreshToken: "refresh")
  private let renewed = DDDCredential(accessToken: "new-access", refreshToken: "new-refresh")

  @Test("Authenticator는 Bearer 토큰을 적용하고 인증된 요청을 판별한다")
  func appliesAndRecognizesCredential() {
    let authenticator = DDDAuthenticator(
      refresher: StubTokenRefresher(result: .success(renewed)),
      store: RecordingCredentialStore()
    )
    var request = URLRequest(url: URL(string: "https://attendance.test/private")!)

    authenticator.apply(current, to: &request)

    #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer old-access")
    #expect(authenticator.isRequest(request, authenticatedWith: current))
    #expect(authenticator.isRequest(request, authenticatedWith: renewed) == false)
  }

  @Test("401만 인증 실패로 판별한다")
  func detectsAuthenticationFailure() {
    let authenticator = DDDAuthenticator(
      refresher: StubTokenRefresher(result: .success(renewed)),
      store: RecordingCredentialStore()
    )
    let request = URLRequest(url: URL(string: "https://attendance.test/private")!)
    let unauthorized = HTTPURLResponse(
      url: request.url!,
      statusCode: 401,
      httpVersion: nil,
      headerFields: nil
    )!
    let forbidden = HTTPURLResponse(
      url: request.url!,
      statusCode: 403,
      httpVersion: nil,
      headerFields: nil
    )!

    #expect(
      authenticator.didRequest(
        request,
        with: unauthorized,
        failDueToAuthenticationError: URLError(.userAuthenticationRequired)
      )
    )
    #expect(
      authenticator.didRequest(
        request,
        with: forbidden,
        failDueToAuthenticationError: URLError(.userAuthenticationRequired)
      ) == false
    )
  }

  @Test("토큰 갱신 성공 결과를 저장하고 호출자에게 돌려준다")
  func refreshPersistsCredential() async throws {
    let store = RecordingCredentialStore()
    let authenticator = DDDAuthenticator(
      refresher: StubTokenRefresher(result: .success(renewed)),
      store: store
    )

    let result = try await refresh(authenticator, credential: current)

    #expect(result == renewed)
    #expect(store.saved == renewed)
  }

  @Test("토큰 갱신 실패를 그대로 전달하고 저장하지 않는다")
  func refreshPropagatesFailure() async {
    let store = RecordingCredentialStore()
    let expected = ResponseError(httpStatus: 401, code: "REFRESH_EXPIRED")
    let authenticator = DDDAuthenticator(
      refresher: StubTokenRefresher(result: .failure(.response(expected))),
      store: store
    )

    do {
      _ = try await refresh(authenticator, credential: current)
      Issue.record("갱신 실패가 전달되어야 한다")
    } catch {
      guard case let DDDNetworkError.response(error) = error else {
        Issue.record("response 에러 기대, got \(error)")
        return
      }
      #expect(error == expected)
      #expect(store.saved == nil)
    }
  }

  @Test("credential이 없으면 AuthorizingInterceptor가 요청을 변경하지 않는다")
  func authorizingBypassesMissingCredential() async throws {
    let store = RecordingCredentialStore()
    let (authorizing, _) = SessionFactory.authorization(
      store: store,
      refresher: StubTokenRefresher(result: .success(renewed))
    )
    let request = URLRequest(url: URL(string: "https://attendance.test/public")!)

    let adapted = try await adapt(authorizing, request: request)

    #expect(adapted.value(forHTTPHeaderField: "Authorization") == nil)
  }

  @Test("credential이 있으면 AuthorizingInterceptor가 토큰을 적용한다")
  func authorizingApCredential() async throws {
    let store = RecordingCredentialStore(initial: current)
    let (authorizing, _) = SessionFactory.authorization(
      store: store,
      refresher: StubTokenRefresher(result: .success(renewed))
    )
    let request = URLRequest(url: URL(string: "https://attendance.test/private")!)

    let adapted = try await adapt(authorizing, request: request)

    #expect(adapted.value(forHTTPHeaderField: "Authorization") == "Bearer old-access")
  }

  @Test("CredentialUpdater는 로그인과 로그아웃 credential을 같은 interceptor에 반영한다")
  func credentialUpdaterChangesSharedCredential() {
    let store = RecordingCredentialStore()
    let (authorizing, updater) = SessionFactory.authorization(
      store: store,
      refresher: StubTokenRefresher(result: .success(renewed))
    )

    updater.update(current)
    #expect(authorizing.base.credential == current)

    updater.update(nil)
    #expect(authorizing.base.credential == nil)
  }

  private func adapt(
    _ interceptor: AuthorizingInterceptor,
    request: URLRequest
  ) async throws -> URLRequest {
    try await withCheckedThrowingContinuation { continuation in
      interceptor.adapt(request, for: Session()) { result in
        continuation.resume(with: result)
      }
    }
  }

  private func refresh(
    _ authenticator: DDDAuthenticator,
    credential: DDDCredential
  ) async throws -> DDDCredential {
    try await withCheckedThrowingContinuation { continuation in
      authenticator.refresh(credential, for: Session()) { result in
        continuation.resume(with: result)
      }
    }
  }
}

private struct StubTokenRefresher: TokenRefreshing {
  let result: Result<DDDCredential, DDDNetworkError>

  func refresh(_ current: DDDCredential) async throws(DDDNetworkError) -> DDDCredential {
    try result.get()
  }
}

private final class RecordingCredentialStore: CredentialStore, @unchecked Sendable {
  private let lock = NSLock()
  private var credential: DDDCredential?

  init(initial: DDDCredential? = nil) {
    credential = initial
  }

  var saved: DDDCredential? {
    lock.withLock { credential }
  }

  func load() -> DDDCredential? {
    lock.withLock { credential }
  }

  func save(_ credential: DDDCredential) {
    lock.withLock {
      self.credential = credential
    }
  }

  func clear() {
    lock.withLock {
      credential = nil
    }
  }
}
