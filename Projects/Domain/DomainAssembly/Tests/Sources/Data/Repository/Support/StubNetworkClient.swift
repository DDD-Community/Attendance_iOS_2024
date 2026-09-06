//
//  StubNetworkClient.swift
//  DomainAssemblyTests
//
//  Created by DDD on 9/4/26.
//

import Foundation

import DDDNetworkInterface

actor StubNetworkClient: DDDNetworkClient {
  private var results: [Result<DDDHTTPResponse, DDDNetworkError>]

  init(_ results: [Result<DDDHTTPResponse, DDDNetworkError>]) {
    self.results = results
  }

  init(statusCode: Int = 200, json: String) {
    self.results = [.success(.init(statusCode: statusCode, data: Data(json.utf8)))]
  }

  init(error: DDDNetworkError) {
    self.results = [.failure(error)]
  }

  func send<R: DDDDataRequest, T: Decodable & Sendable>(
    _: R,
    as _: T.Type
  ) async throws(DDDNetworkError) -> T {
    let response = try next()
    do {
      return try JSONDecoder().decode(T.self, from: response.data)
    } catch {
      throw .decoding(.failed(error))
    }
  }

  func send<R: DDDDataRequest>(_ request: R) async throws(DDDNetworkError) -> R.Response {
    try await send(request, as: R.Response.self)
  }

  func sendResponse<R: DDDDataRequest>(_: R) async throws(DDDNetworkError) -> DDDHTTPResponse {
    try next()
  }

  func upload<R: DDDUploadRequest>(_: R) async throws(DDDNetworkError) -> R.Response {
    fatalError("Repository 테스트에서는 multipart upload를 사용하지 않습니다")
  }

  func upload(_: some DDDFileUploadRequest) async throws(DDDNetworkError) {
    fatalError("Repository 테스트에서는 file upload를 사용하지 않습니다")
  }

  private func next() throws(DDDNetworkError) -> DDDHTTPResponse {
    guard !results.isEmpty else {
      return .init(statusCode: 204, data: Data())
    }
    return try results.removeFirst().get()
  }
}

extension Result where Success == DDDHTTPResponse, Failure == DDDNetworkError {
  static func response(_ statusCode: Int = 200, _ json: String = "") -> Self {
    .success(.init(statusCode: statusCode, data: Data(json.utf8)))
  }
}
