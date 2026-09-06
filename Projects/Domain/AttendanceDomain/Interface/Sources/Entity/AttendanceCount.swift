//
//  AttendanceCount.swift
//  Entity
//
//  Created by DDD on 1/11/26.
//

import Foundation

import ProfileDomainInterface

public struct AttendanceCount: Equatable {
  public let attendanceCount: Int
  public let lateCount: Int
  public let absentCount: Int

  public init(
    attendanceCount: Int,
    lateCount: Int,
    absentCount: Int
  ) {
    self.attendanceCount = attendanceCount
    self.lateCount = lateCount
    self.absentCount = absentCount
  }

}
