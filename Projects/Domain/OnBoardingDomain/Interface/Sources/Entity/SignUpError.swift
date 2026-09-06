//
//  SignUpError.swift
//  Entity
//
//  Created by DDD on 12/30/25.
//

import Foundation

import AuthDomainInterface
import ProfileDomainInterface

public enum SignUpError: Error, LocalizedError, Equatable {
  // MARK: - Invite Code Related Errors
  case invalidInviteCode
  case expiredInviteCode

  // MARK: - Job Related Errors
  case invalidJob
  case jobNotSelected
  case jobNotAvailable

  // MARK: - Account Related Errors
  case accountAlreadyExists
  case accountCreationFailed

  // MARK: - Validation Errors
  case nameTooShort
  case nameTooLong

  // MARK: - Network & Server Errors

  // MARK: - General Errors
  case unknownError(String)
  case userCancelled
  case missingRequiredField(String)

  public var errorDescription: String? {
    switch self {
    // Invite Code Related Errors
    case .invalidInviteCode:
      return "초대 코드가 잘못 되었습니다"
    case .expiredInviteCode:
      return "만료된 초대 코드입니다"

    // Job Related Errors
    case .invalidJob:
      return "유효하지 않은 직무입니다"
    case .jobNotSelected:
      return "직무를 선택해주세요"
    case .jobNotAvailable:
      return "선택한 직무를 사용할 수 없습니다"

    // Account Related Errors
    case .accountAlreadyExists:
      return "이미 존재하는 계정입니다"
    case .accountCreationFailed:
      return "계정 생성에 실패했습니다"

    // Validation Errors
    case .nameTooShort:
      return "이름이 너무 짧습니다"
    case .nameTooLong:
      return "이름이 너무 깁니다"

    // Network & Server Errors
    case .unknownError(let message):
      return "알 수 없는 오류가 발생했습니다: \(message)"
    case .userCancelled:
      return "사용자가 취소했습니다"
    case .missingRequiredField(let field):
      return "\(field)은(는) 필수 입력 항목입니다"
    }
  }

  public var failureReason: String? {
    switch self {
    case .invalidInviteCode:
      return "초대 코드 검증 실패"
    case .invalidJob:
      return "직무 검증 실패"
    case .jobNotSelected:
      return "직무 선택 실패"
    default:
      return nil
    }
  }

  public var recoverySuggestion: String? {
    switch self {
    case .invalidInviteCode:
      return "초대 코드를 다시 확인하거나 관리자에게 문의해주세요"
    case .invalidJob:
      return "유효한 직무를 선택해주세요"
    case .jobNotSelected:
      return "목록에서 직무를 선택해주세요"
    case .jobNotAvailable:
      return "다른 직무를 선택하거나 관리자에게 문의해주세요"
    default:
      return "문제가 지속되면 고객센터에 문의해주세요"
    }
  }
}

// MARK: - Convenience Methods

public extension SignUpError {
  static func from(_ error: Error) -> SignUpError {
    if let signUpError = error as? SignUpError {
      return signUpError
    }
    return .unknownError(error.localizedDescription)
  }

  /// 초대 코드 관련 에러인지 확인
  var isInviteCodeError: Bool {
    switch self {
    case .invalidInviteCode, .expiredInviteCode:
      return true
    default:
      return false
    }
  }

  /// 직무 관련 에러인지 확인
  var isJobError: Bool {
    switch self {
    case .invalidJob, .jobNotSelected, .jobNotAvailable:
      return true
    default:
      return false
    }
  }

  /// 네트워크 관련 에러인지 확인
  var isNetworkError: Bool {
    switch self {
    default:
      return false
    }
  }

  /// 재시도 가능한 에러인지 확인
  var isRetryable: Bool {
    // 전송 실패는 도메인이 구분하지 않으므로 재시도 판단 대상이 아니다.
    return false
  }
}
