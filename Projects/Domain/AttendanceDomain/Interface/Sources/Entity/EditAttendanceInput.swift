//
//  EditAttendanceInput.swift
//  Entity
//
//  Created by DDD on 1/13/26.
//

import Foundation

import ProfileDomainInterface

public struct EditAttendanceInput {
  public let attendanceId: Int?
  public let scheduleId: Int
  public let status: AttendanceStatus
  public let userId: String

  public init(
    attendanceId: Int? = nil,
    scheduleId: Int,
    status: AttendanceStatus,
    userId: String
  ) {
    self.attendanceId = attendanceId
    self.scheduleId = scheduleId
    self.status = status
    self.userId = userId
  }
}
