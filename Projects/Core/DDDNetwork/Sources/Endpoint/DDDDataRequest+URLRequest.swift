//
//  DDDDataRequest+URLRequest.swift
//  DDDNetwork
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

import DDDNetworkInterface

import Alamofire

extension DDDDataRequest {
  func asURLRequest(baseURL: URL) throws -> URLRequest {
    var urlRequest = try URLRequest(
      url: baseURL.appendingPathComponent(path),
      method: method,
      headers: headers
    )

    if let timeoutInterval {
      urlRequest.timeoutInterval = timeoutInterval
    }

    guard let parameters else { return urlRequest }
    return try encode(parameters, using: resolvedEncoder, into: urlRequest)
  }

  /// 요청이 인코더를 오버라이드하면 그대로, 아니면 method 기준(GET/DELETE 쿼리스트링 · 그 외 JSON 바디).
  private var resolvedEncoder: ParameterEncoder {
    if let parameterEncoder {
      return parameterEncoder
    }
    return (method == .get || method == .delete)
      ? URLEncodedFormParameterEncoder.default
      : JSONParameterEncoder.default
  }

  /// 파라미터 인코딩. 호출부가 `any Encodable` 을 넘기면 이 제네릭 시점에 열린다(implicit opening).
  /// 인코딩 실패는 raw 로 던지고, 호출부(NetworkClient)가 `.request(.encodingFailed)` 로 감싼다.
  private func encode(
    _ parameters: some Encodable & Sendable,
    using encoder: ParameterEncoder,
    into request: URLRequest
  ) throws -> URLRequest {
    try encoder.encode(parameters, into: request)
  }
}
