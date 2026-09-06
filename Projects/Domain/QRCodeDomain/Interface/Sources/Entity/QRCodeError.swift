//
//  QRCodeError.swift
//  Entity
//
//  Created by DDD on 5/12/26.
//

import Foundation

import AttendanceDomainInterface

public enum QRCodeError: Error, LocalizedError, Equatable {
  // MARK: - QR Code Generation Errors

  case generationFailed
  case invalidPayload
  case imageRenderingFailed

  // MARK: - QR Code Fetch Errors

  case createFailed
  case validationFailed(String)
  case userNotFound
  case invalidSession

  // MARK: - General Errors

  case unknownError(String)

  public var errorDescription: String? {
    switch self {
    case .generationFailed:
      return "QR 코드 생성에 실패했습니다"
    case .invalidPayload:
      return "잘못된 QR 코드 데이터입니다"
    case .imageRenderingFailed:
      return "QR 코드 이미지 변환에 실패했습니다"
    case .createFailed:
      return "QR 코드 발급에 실패했습니다"
    case let .validationFailed(message):
      return message
    case .userNotFound:
      return "사용자 정보를 찾을 수 없습니다"
    case .invalidSession:
      return "세션이 유효하지 않습니다"
    case let .unknownError(message):
      return "알 수 없는 오류가 발생했습니다: \(message)"
    }
  }

  public var recoverySuggestion: String? {
    switch self {
    case .generationFailed, .createFailed, .validationFailed, .imageRenderingFailed:
      return "잠시 후 다시 시도해주세요"
    case .invalidPayload:
      return "QR 코드를 다시 발급받아주세요"
    case .userNotFound, .invalidSession:
      return "다시 로그인해주세요"
    case .unknownError:
      return "문제가 지속되면 고객센터에 문의해주세요"
    }
  }
}

// MARK: - Convenience Methods

public extension QRCodeError {
  static func from(_ error: Error) -> QRCodeError {
    if let qrCodeError = error as? QRCodeError {
      return qrCodeError
    }
    return .unknownError(error.localizedDescription)
  }
}
