//
//  URLProtocolStub.swift
//  DDDNetworkTests
//
//  Created by DDD on 9/1/26.
//

import Foundation

@testable import DDDNetwork

import Alamofire

/// 실제 통신 없이 `NetworkClient`의 요청과 응답을 검증하는 URLProtocol 스텁.
/// 정적 상태를 사용하므로 이 스텁을 사용하는 테스트 스위트는 직렬로 실행해야 한다.
final class URLProtocolStub: URLProtocol {
  private struct Stub {
    let statusCode: Int
    let body: Data
    let headerFields: [String: String]
    let error: Error?
  }

  private nonisolated(unsafe) static var stubs: [Stub] = []
  private nonisolated(unsafe) static var capturedRequests: [URLRequest] = []
  private static let lock = NSLock()

  static func set(
    statusCode: Int,
    body: Data = Data(),
    headerFields: [String: String] = ["Content-Type": "application/json"]
  ) {
    lock.withLock {
      stubs = [Stub(statusCode: statusCode, body: body, headerFields: headerFields, error: nil)]
    }
  }

  static func setSequence(_ responses: [(statusCode: Int, body: Data)]) {
    lock.withLock {
      stubs = responses.map {
        Stub(
          statusCode: $0.statusCode,
          body: $0.body,
          headerFields: ["Content-Type": "application/json"],
          error: nil
        )
      }
    }
  }

  static func setError(_ error: Error) {
    lock.withLock {
      stubs = [Stub(statusCode: 0, body: Data(), headerFields: [:], error: error)]
    }
  }

  static func reset() {
    lock.withLock {
      stubs = []
      capturedRequests = []
    }
  }

  static var recordedRequests: [URLRequest] {
    lock.withLock { capturedRequests }
  }

  static func makeClient(
    baseURL: URL? = URL(string: "https://attendance.test"),
    authorizing: AuthorizingInterceptor? = nil
  ) -> NetworkClient {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [URLProtocolStub.self]
    return NetworkClient(
      session: Session(configuration: configuration),
      baseURL: baseURL,
      authorizing: authorizing
    )
  }

  override class func canInit(with _: URLRequest) -> Bool {
    true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    let current = Self.lock.withLock { () -> Stub? in
      var capturedRequest = request
      if capturedRequest.httpBody == nil, let bodyStream = capturedRequest.httpBodyStream {
        capturedRequest.httpBody = Self.readData(from: bodyStream)
      }
      Self.capturedRequests.append(capturedRequest)
      guard !Self.stubs.isEmpty else { return nil }
      if Self.stubs.count == 1 {
        return Self.stubs[0]
      }
      return Self.stubs.removeFirst()
    }

    guard let current else {
      client?.urlProtocol(self, didFailWithError: URLError(.unknown))
      return
    }

    if let error = current.error {
      client?.urlProtocol(self, didFailWithError: error)
      return
    }

    let response = HTTPURLResponse(
      url: request.url ?? URL(string: "https://attendance.test")!,
      statusCode: current.statusCode,
      httpVersion: "HTTP/1.1",
      headerFields: current.headerFields
    )!
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    if !current.body.isEmpty {
      client?.urlProtocol(self, didLoad: current.body)
    }
    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}

  private static func readData(from stream: InputStream) -> Data {
    stream.open()
    defer { stream.close() }

    var data = Data()
    var buffer = [UInt8](repeating: 0, count: 1_024)
    while true {
      let count = stream.read(&buffer, maxLength: buffer.count)
      guard count > 0 else { break }
      data.append(buffer, count: count)
    }
    return data
  }
}
