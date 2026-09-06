//
//  DDDEndpoint.swift
//  DDDNetworkInterface
//
//  Copyright © 2026 DDD. All rights reserved.
//

import Foundation

import Alamofire

/// 일반 요청(`DDDDataRequest`)·멀티파트 업로드(`DDDUploadRequest`)가 공유하는 엔드포인트 메타.
/// 바디 표현(parameters / parts)만 각 프로토콜이 따로 더한다.
///
/// 출석 서버는 호스트가 하나뿐이라 엔드포인트에 host 키를 두지 않는다.
/// baseURL 은 클라이언트가 들고 있고, 여기서는 그 뒤에 붙는 `path` 만 선언한다.
///
/// 응답 타입은 여기서 고정하지 않는다. 한 enum 이 케이스마다 다른 응답을 갖는
/// Moya 식 선언(`case login` / `case logout`)을 그대로 쓸 수 있게 하기 위함이다.
/// 응답 타입까지 타입으로 묶고 싶으면 `DDDDataRequest` 를 쓴다.
public protocol DDDEndpoint {
  /// baseURL 뒤에 붙는 경로 (예: "api/votes/3/participation")
  var path: String { get }
  /// HTTP 메서드
  var method: HTTPMethod { get }
  /// 요청 헤더 (공통 헤더는 세션이 붙인다 — 여기엔 이 요청만의 헤더를 둔다)
  var headers: HTTPHeaders { get }
  /// 타임아웃(초). nil 이면 세션 기본값 사용.
  var timeoutInterval: TimeInterval? { get }
  /// 최대 재시도 횟수 (0 = 재시도 안 함)
  var maxRetryAttempts: Int { get }
  /// 인증 정책. 기본값 `.automatic` — 예외 엔드포인트만 선언한다.
  var authorization: DDDAuthorization { get }
}

public extension DDDEndpoint {
  var headers: HTTPHeaders {
    return [:]
  }

  var timeoutInterval: TimeInterval? {
    return nil
  }

  /// 기본 재시도 횟수.
  var maxRetryAttempts: Int {
    return 3
  }

  /// 기본 인증 정책 — 로그인 상태면 토큰 부착.
  var authorization: DDDAuthorization {
    return .automatic
  }
}
