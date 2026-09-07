//
//  AttendanceCountDTO+.swift
//  AttendanceDomain
//
//  Created by DDD on 1/11/26.
//

import Foundation

import AttendanceDomainInterface

public extension AttendanceCountDTO {
  func toDomain() -> AttendanceCount {
    return AttendanceCount(
      attendanceCount: self.totalAttended,
      lateCount: self.totalLate,
      absentCount: self.totalAbsent
    )
  }
}
