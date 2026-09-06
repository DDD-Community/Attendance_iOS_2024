//
//  AuthError.swift
//  Entity
//
//  Created by DDD on 12/29/25.
//

import Foundation

import ProfileDomainInterface

public enum AuthError: Error, Equatable, LocalizedError, Hashable {
  /// 설정 누락 (Google/Supabase 키 등)
  case configurationMissing
  /// 프레젠트할 컨트롤러가 없음
  case missingPresentingController
  /// ID 토큰 없음
  case missingIDToken
  /// 사용자가 로그인 플로우를 취소한 경우
  case userCancelled
  /// 자격 증명 문제 (예: 잘못된 nonce, credential 등)
  case invalidCredential(String)
  /// 로그인 처리 실패
  case loginFailed
  /// 토큰 갱신 처리 실패
  case tokenRefreshFailed
  /// 로그아웃 처리 실패
  case logoutFailed
  /// 약관 동의가 필요한 경우
  case needsTermsAgreement(String)
  /// 회원 탈퇴 실패
  case accountDeletionFailed
  /// 회원 탈퇴 권한 없음
  case accountDeletionNotAllowed
  /// 이미 탈퇴된 계정
  case accountAlreadyDeleted
  /// refresh token이 만료된 경우
  case refreshTokenExpired
  /// 그 외 알 수 없는 에러
  case unknownError(String)

  // MARK: - LocalizedError

  public var errorDescription: String? {
    switch self {
    case .configurationMissing:
      return "인증 설정이 올바르게 구성되지 않았습니다."
    case .missingPresentingController:
      return "프레젠트할 뷰 컨트롤러를 찾을 수 없습니다."
    case .missingIDToken:
      return "ID 토큰을 가져오지 못했습니다."
    case .userCancelled:
      return "사용자가 로그인을 취소했습니다."
    case .invalidCredential(let message):
      return "잘못된 자격 증명입니다: \(message)"
    case .loginFailed:
      return "로그인에 실패했습니다."
    case .tokenRefreshFailed:
      return "로그인 정보를 갱신하지 못했습니다."
    case .logoutFailed:
      return "로그아웃에 실패했습니다."
    case .needsTermsAgreement(let message):
      return "\(message)"
    case .accountDeletionFailed:
      return "회원 탈퇴에 실패했습니다."
    case .accountDeletionNotAllowed:
      return "회원 탈퇴 권한이 없습니다."
    case .accountAlreadyDeleted:
      return "이미 탈퇴된 계정입니다."
    case .refreshTokenExpired:
      return "로그인이 만료되었습니다. 다시 로그인해주세요."
    case .unknownError(let message):
      return "알 수 없는 오류가 발생했습니다: \(message)"
    }
  }
}

// MARK: - Convenience Methods

public extension AuthError {
  static func from(_ error: Error) -> AuthError {
    if let authError = error as? AuthError {
      return authError
    }
    return .unknownError(error.localizedDescription)
  }

  var isNetworkError: Bool {
    switch self {
    default:
      return false
    }
  }

  var isRetryable: Bool {
    switch self {
    case .loginFailed, .tokenRefreshFailed, .logoutFailed:
      return true
    default:
      return false
    }
  }

  var isAccountDeletionError: Bool {
    switch self {
    case .accountDeletionFailed, .accountDeletionNotAllowed, .accountAlreadyDeleted:
      return true
    default:
      return false
    }
  }

  var isTokenExpiredError: Bool {
    switch self {
    case .refreshTokenExpired:
      return true
    default:
      return false
    }
  }
}
