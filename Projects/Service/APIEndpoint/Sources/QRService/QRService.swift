//
//  QRService.swift
//  Service
//
//  Created by DDD on 5/20/25.
//

import Foundation

import API
import DDDNetworkInterface

import Alamofire

public enum QRService: DDDDataRequest, Sendable {
  case qrAttendanceCheck(qrCode: String)
  case createQRCode(userID: Int)

  private var domain: AttendanceDomain {
    switch self {
    case .qrAttendanceCheck:
      return .attendance
    case .createQRCode:
      return .qr
    }
  }

  public var path: String {
    return domain.url + urlPath
  }

  private var urlPath: String {
    switch self {
    case .qrAttendanceCheck:
      return QRAPI.validate.description
    case let .createQRCode(userID):
      return "/\(userID)/qr"
    }
  }

  public var method: HTTPMethod {
    switch self {
    case .qrAttendanceCheck:
      return .post
    case .createQRCode:
      return .get
    }
  }

  public var parameters: (any Encodable & Sendable)? {
    switch self {
    case let .qrAttendanceCheck(qrCode):
      return QRCodeParameter(qrCode: qrCode)
    case let .createQRCode(userID):
      return UserIDParameter(id: userID)
    }
  }
}

private struct QRCodeParameter: Encodable, Sendable {
  let qrCode: String
}

private struct UserIDParameter: Encodable, Sendable {
  let id: Int
}
