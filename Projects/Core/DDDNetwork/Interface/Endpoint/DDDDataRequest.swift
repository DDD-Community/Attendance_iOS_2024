//
//  DDDDataRequest.swift
//  DDDNetworkInterface
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

import Alamofire

/// 일반(비-멀티파트) 요청. 엔드포인트 메타는 `DDDEndpoint`, 바디는 `parameters` 로 표현한다.
/// (Alamofire 의 DataRequest / UploadRequest 분류와 결을 맞춘 이름)
public protocol DDDDataRequest: DDDEndpoint {
  /// 디코딩될 응답 타입
  associatedtype Response: Decodable & Sendable = DDDEmptyResponse
  /// 요청 파라미터(Encodable). 쿼리 / 바디 위치는 인코더가 결정한다.
  var parameters: (any Encodable & Sendable)? { get }
  /// 파라미터 인코더 오버라이드. nil 이면 method 기준 기본(GET/DELETE 쿼리스트링, 그 외 JSON 바디).
  /// 예: POST 인데 쿼리 파라미터가 필요하면 `URLEncodedFormParameterEncoder(destination: .queryString)`.
  var parameterEncoder: ParameterEncoder? { get }
}

public extension DDDDataRequest {
  var parameters: (any Encodable & Sendable)? {
    return nil
  }

  var parameterEncoder: ParameterEncoder? {
    return nil
  }
}
