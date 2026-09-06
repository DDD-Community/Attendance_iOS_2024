//
//  QRValidateEntity.swift
//  Entity
//
//  Created by DDD on 1/12/26.
//

import Foundation

import AttendanceDomainInterface

public struct QRValidateEntity: Equatable {
  public let isSuccess: Bool
  public let code: String?
  public let message: String?
  public let detail: String?
  public let status: AttendanceStatus?

  public init(
    isSuccess: Bool,
    code: String? = nil,
    message: String? = nil,
    detail: String? = nil,
    status: AttendanceStatus? = nil
  ) {
    self.isSuccess = isSuccess
    self.code = code
    self.message = message
    self.detail = detail
    self.status = status
  }
}

