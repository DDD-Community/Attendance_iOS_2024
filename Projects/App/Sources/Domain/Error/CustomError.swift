//
//  CustomError.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/15/24.
//

import Foundation

public enum CustomError: Error, Equatable {
    case wrongQueryType
    case networkDisconnected
    case unAuthorized
    case internalServer
    case responseBodyEmpty
    case decodeFailed
    case invalidURL
    case invalidEventId
    case unknownError(String)
    case firestoreError(String)
    case encodingError(String)
    case none
}

extension CustomError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .wrongQueryType:
            return "잘못된 요청입니다"
        case .networkDisconnected:
            return "네트워크 상태가 원활하지 않습니다"
        case .unAuthorized:
            return "알 수 없는 사용자입니다"
        case .internalServer:
            return "서버 에러 발생"
        case .responseBodyEmpty:
            return "내부 에러 발생"
        case .decodeFailed:
            return "내부 에러 발생"
        case .invalidURL:
            return "잘못된 접근입니다"
        case .invalidEventId:
            return "알 수 없는 eventId 입니다"
        case .unknownError:
            return "원인을 알 수 없는 에러 발생"
        case .firestoreError(let message):
            return "파이어 베이스 에러 발생: \(message)"
        case .encodingError(let message):
            return "파이어 인코딩 에러 발생: \(message)"
        case .none:
            return nil
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .wrongQueryType:
            return "다시 시도해주세요"
        case .networkDisconnected:
            return "Wi-Fi 혹은 데이터 확인 후 다시 시도해주세요"
        case .unAuthorized:
            return "로그인 정보를 다시 확인해주세요"
        case .internalServer:
            return "개발팀에게 문의해주세요"
        case .responseBodyEmpty:
            return "개발팀에게 문의해주세요"
        case .decodeFailed:
            return "개발팀에게 문의해주세요"
        case .invalidURL:
            return "개발팀에게 문의해주세요"
        case .invalidEventId:
            return "개발팀에게 문의해주세요"
        case .unknownError:
            return "개발팀에게 문의해주세요"
        case .firestoreError(_):
            return "개발팀에게 문의해주세요"
        case .encodingError(_):
            return "개발팀에게 문의해주세요"
        case .none:
            return nil
        }
    }

    static func map(_ error: Error) -> CustomError {
        if let customError = error as? CustomError {
            return customError
        } else {
            return .unknownError(error.localizedDescription)
        }
    }
}
