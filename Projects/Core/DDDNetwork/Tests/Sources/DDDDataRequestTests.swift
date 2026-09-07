//
//  DDDDataRequestTests.swift
//  DDDNetwork
//
//  엔드포인트 선언이 URLRequest 로 옮겨지는 규칙을 검증한다.
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation
import Testing

@testable import DDDNetwork
import DDDNetworkInterface

import Alamofire

/// Moya 처럼 한 enum 에 여러 케이스를 두는 선언 방식. A 방식이 성립하는지 확인하는 대상이기도 하다.
private enum SampleService: DDDDataRequest {
  case list(page: Int)
  case create(name: String)
  case remove(id: Int)
  case update(name: String)

  var path: String {
    switch self {
    case .list: "api/items"
    case .create, .update: "api/items"
    case let .remove(id): "api/items/\(id)"
    }
  }

  var method: HTTPMethod {
    switch self {
    case .list: .get
    case .create, .update: .post
    case .remove: .delete
    }
  }

  var parameters: (any Encodable & Sendable)? {
    switch self {
    case let .list(page): ["page": page]
    case let .create(name): ["name": name]
    case let .update(name): ["name": name]
    case .remove: nil
    }
  }

  var headers: HTTPHeaders {
    switch self {
    case .update:
      ["X-Request-ID": "request-id"]
    default:
      [:]
    }
  }

  var timeoutInterval: TimeInterval? {
    switch self {
    case .update: 9
    default: nil
    }
  }

  var parameterEncoder: ParameterEncoder? {
    switch self {
    case .update:
      URLEncodedFormParameterEncoder(destination: .queryString)
    default:
      nil
    }
  }
}

@Suite("DDDDataRequest — URLRequest 변환")
struct DDDDataRequestTests {
  private let baseURL = URL(string: "https://example.com")!

  @Test("path 가 baseURL 뒤에 붙는다")
  func buildsURL() throws {
    let request = try SampleService.remove(id: 7).asURLRequest(baseURL: baseURL)
    #expect(request.url?.absoluteString == "https://example.com/api/items/7")
  }

  @Test("method 가 그대로 실린다")
  func carriesMethod() throws {
    let request = try SampleService.create(name: "a").asURLRequest(baseURL: baseURL)
    #expect(request.httpMethod == "POST")
  }

  @Test("GET 은 파라미터를 쿼리스트링으로 보낸다")
  func encodesGetAsQuery() throws {
    let request = try SampleService.list(page: 3).asURLRequest(baseURL: baseURL)
    #expect(request.url?.query?.contains("page=3") == true)
    #expect(request.httpBody == nil)
  }

  @Test("POST 는 파라미터를 JSON 바디로 보낸다")
  func encodesPostAsJSONBody() throws {
    let request = try SampleService.create(name: "hello").asURLRequest(baseURL: baseURL)
    let body = try #require(request.httpBody)
    #expect(String(decoding: body, as: UTF8.self).contains("\"name\":\"hello\""))
    #expect(request.url?.query == nil)
  }

  @Test("파라미터가 없으면 바디도 쿼리도 만들지 않는다")
  func omitsEmptyParameters() throws {
    let request = try SampleService.remove(id: 1).asURLRequest(baseURL: baseURL)
    #expect(request.httpBody == nil)
    #expect(request.url?.query == nil)
  }

  @Test("타임아웃을 선언하지 않으면 세션 기본값을 쓴다")
  func keepsDefaultTimeout() throws {
    #expect(SampleService.list(page: 1).timeoutInterval == nil)
  }

  @Test("인증 정책 기본값은 automatic 이다")
  func defaultsToAutomaticAuthorization() {
    #expect(SampleService.list(page: 1).authorization == .automatic)
  }

  @Test("요청별 헤더와 타임아웃을 URLRequest에 반영한다")
  func carriesHeadersAndTimeout() throws {
    let request = try SampleService.update(name: "수정").asURLRequest(baseURL: baseURL)

    #expect(request.value(forHTTPHeaderField: "X-Request-ID") == "request-id")
    #expect(request.timeoutInterval == 9)
  }

  @Test("명시한 파라미터 인코더는 method 기본 인코더보다 우선한다")
  func respectsCustomEncoder() throws {
    let request = try SampleService.update(name: "query").asURLRequest(baseURL: baseURL)

    #expect(request.url?.query == "name=query")
    #expect(request.httpBody == nil)
  }

  @Test("DELETE 파라미터는 기본적으로 쿼리스트링에 인코딩한다")
  func encodesDeleteParametersAsQuery() throws {
    struct DeleteRequest: DDDDataRequest {
      let path = "api/items"
      let method: HTTPMethod = .delete
      let parameters: (any Encodable & Sendable)? = ["id": 3]
    }

    let request = try DeleteRequest().asURLRequest(baseURL: baseURL)

    #expect(request.url?.query == "id=3")
    #expect(request.httpBody == nil)
  }

  @Test("재시도 횟수는 음수를 0으로 보정하고 429를 재시도 대상으로 포함한다")
  func configuresRetryPolicy() {
    struct NoRetryEndpoint: DDDEndpoint {
      let path = "retry"
      let method: HTTPMethod = .get
      let maxRetryAttempts = -1
    }

    let policy = NoRetryEndpoint().retryPolicy

    #expect(policy.retryLimit == 0)
    #expect(policy.retryableHTTPStatusCodes.contains(429))
  }
}
