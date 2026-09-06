//
//  EditAttendanceDTO+.swift
//  AttendanceDomain
//
//  Created by DDD on 1/13/26.
//

import Foundation

import AttendanceDomainInterface

public extension EditAttendanceDTO {
  func toDomain(isSuccess: Bool) -> EditAttendance {
    EditAttendance(
      isSuccess: isSuccess,
      code: code,
      message: message,
      detail: detail
    )
  }
}
