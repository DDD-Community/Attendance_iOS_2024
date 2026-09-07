//
//  TokenRefresherTests.swift
//  DDDAuthTests
//
//  Created by DDD on 9/1/26.
//

import Foundation
import Testing

@testable import DDDAuth
import DDDNetworkInterface

struct TokenRefresherTests {
  @Test
  func 인증거부_응답이면_세션만료_콜백을_호출한다() async {
    let callback = CallbackSpy()
    let sut = TokenRefresher(
      client: FailingRequestClient(error: .response(ResponseError(httpStatus: 401)))
    ) {
      callback.call()
    }

    await #expect(throws: DDDNetworkError.self) {
      try await sut.refresh(DDDCredential(accessToken: "access", refreshToken: "refresh"))
    }
    #expect(callback.callCount == 1)
  }

  @Test
  func 서버장애_응답이면_세션을_유지한다() async {
    let callback = CallbackSpy()
    let sut = TokenRefresher(
      client: FailingRequestClient(error: .response(ResponseError(httpStatus: 503)))
    ) {
      callback.call()
    }

    await #expect(throws: DDDNetworkError.self) {
      try await sut.refresh(DDDCredential(accessToken: "access", refreshToken: "refresh"))
    }
    #expect(callback.callCount == 0)
  }

  @Test
  func 전송실패이면_세션을_유지한다() async {
    let callback = CallbackSpy()
    let sut = TokenRefresher(
      client: FailingRequestClient(error: .transport(.notConnected))
    ) {
      callback.call()
    }

    await #expect(throws: DDDNetworkError.self) {
      try await sut.refresh(DDDCredential(accessToken: "access", refreshToken: "refresh"))
    }
    #expect(callback.callCount == 0)
  }
}

private final class CallbackSpy: @unchecked Sendable {
  private let lock = NSLock()
  private var count = 0

  var callCount: Int {
    lock.lock()
    defer { lock.unlock() }
    return count
  }

  func call() {
    lock.lock()
    defer { lock.unlock() }
    count += 1
  }
}

private final class FailingRequestClient: DDDRequestClient, @unchecked Sendable {
  private let error: DDDNetworkError

  init(error: DDDNetworkError) {
    self.error = error
  }

  func send<R: DDDDataRequest, T: Decodable & Sendable>(
    _: R,
    as _: T.Type
  ) async throws(DDDNetworkError) -> T {
    throw error
  }

  func send<R: DDDDataRequest>(_: R) async throws(DDDNetworkError) -> R.Response {
    throw error
  }

  func sendResponse<R: DDDDataRequest>(_: R) async throws(DDDNetworkError) -> DDDHTTPResponse {
    throw error
  }
}
