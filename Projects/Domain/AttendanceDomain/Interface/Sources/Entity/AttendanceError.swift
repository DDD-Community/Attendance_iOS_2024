//
//  AttendanceError.swift
//  Entity
//
//  Created by DDD on 1/11/26.
//

import Foundation

import ProfileDomainInterface

/// 출석 도메인의 실패만 담는다.
/// 네트워크·디코딩·HTTP 상태 같은 전송 관심사는 DDDNetwork 의 `DDDNetworkError` 가 소유하고,
/// Repository 가 서버 응답 코드로 도메인 케이스를 고르지 못하면 `.unknown` 으로 흡수한다.
public enum AttendanceError: LocalizedError, Equatable {
  case invalidDate
  case loadFailed
  case updateFailed
  /// 서버가 사유를 붙여 거절한 경우(예: "출석일이 아닙니다"). 사용자에게 그대로 보여준다.
  case rejected(String)
  case unknown

  public var errorDescription: String? {
    switch self {
    case .invalidDate:
      return "잘못된 날짜 형식입니다"
    case .loadFailed:
      return "출석 정보를 불러오지 못했습니다"
    case .updateFailed:
      return "출석 정보를 변경하지 못했습니다"
    case let .rejected(message):
      return message
    case .unknown:
      return "알 수 없는 오류가 발생했습니다"
    }
  }

  public var failureReason: String? {
    switch self {
    case .invalidDate:
      return "날짜 형식을 확인해주세요"
    case .loadFailed:
      return "출석 정보 조회에 실패했습니다"
    case .updateFailed:
      return "출석 정보 변경에 실패했습니다"
    case .rejected:
      return "요청이 거절되었습니다"
    case .unknown:
      return "예상치 못한 오류가 발생했습니다"
    }
  }

  public var recoverySuggestion: String? {
    switch self {
    case .invalidDate:
      return "올바른 날짜를 입력해주세요"
    case .loadFailed, .updateFailed:
      return "잠시 후 다시 시도해주세요"
    case .rejected:
      return "안내된 사유를 확인한 뒤 다시 시도해주세요"
    case .unknown:
      return "문제가 지속되면 고객센터에 문의해주세요"
    }
  }
}

public extension AttendanceError {
  /// 이미 도메인 에러인 값을 그대로 통과시킨다.
  /// Repository 가 typed throws 로 던지므로 여기서는 캐스팅만 하고,
  /// 그 밖의 에러는 전송 실패로 보고 `.unknown` 으로 흡수한다.
  static func from(_ error: any Error) -> AttendanceError {
    (error as? AttendanceError) ?? .unknown
  }

  /// 서버가 내려준 에러 코드를 도메인 케이스로 옮긴다. VoteError 와 같은 계약이다.
  /// 코드로 못 가리면 HTTP status 로 한 번 더 시도하고, 그래도 없으면 `.unknown` 이다.
  static func from(
    statusCode: Int,
    code _: String? = nil,
    message: String? = nil
  ) -> AttendanceError {
    // 서버가 사유를 붙여 거절한 4xx 는 그 문구를 사용자에게 그대로 전달한다.
    if (400 ..< 500).contains(statusCode), let message, !message.isEmpty {
      return .rejected(message)
    }
    return .unknown
  }
}
