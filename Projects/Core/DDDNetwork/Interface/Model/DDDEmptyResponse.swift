//
//  DDDEmptyResponse.swift
//  DDDNetworkInterface
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

import Alamofire

/// 본문(payload)이 없는 응답. 성공만 받으면 되는 요청(POST/DELETE 등)의
/// `Response` 로 쓰면, 서버가 바디를 안 내려도 에러 없이 성공 처리된다.
///
/// Alamofire 의 `EmptyResponse` 를 채택해, 응답 바디가 비었을 때
/// 시리얼라이저가 이 값을 직접 만들어 성공으로 처리하게 한다.
public struct DDDEmptyResponse: Decodable, Sendable, EmptyResponse {
  public init() {}

  /// 바디가 `{}` 가 아니어도(빈 배열·빈 문자열 등) 실패하지 않도록 키 컨테이너를 열지 않는다.
  public init(from _: Decoder) throws {}

  public static func emptyValue() -> DDDEmptyResponse {
    return DDDEmptyResponse()
  }
}
