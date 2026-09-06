//
//  AttendanceInterface.swift
//  DomainInterface
//
//  Created by DDD on 7/23/25.
//

import Foundation

import OnBoardingDomainInterface
import ProfileDomainInterface

import Dependencies

/// Attendance 관련 비즈니스 로직을 위한 Interface 프로토콜
public protocol AttendanceInterface: Sendable {
  func adminAttendanceCount(scheduleId: Int) async throws(AttendanceError) -> AttendanceCount
  func fetchAttendanceTeams() async throws(AttendanceError) -> [SelectTeamEntity]
  func sessionAttendance(scheduleId: Int, teamId: Int) async throws(AttendanceError) -> [Attendance]
  func fetchStatus() async throws(AttendanceError) -> [AttendanceStatus]
  func editAttendance(input: EditAttendanceInput) async throws(AttendanceError) -> EditAttendance
}

/// Attendance Repository의 DependencyKey 구조체
public enum AttendanceRepositoryDependency: TestDependencyKey {
  
  public static var testValue: AttendanceInterface {
    MockAttendanceRepository()
  }
  
  public static var previewValue: AttendanceInterface = testValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var attendanceRepository: AttendanceInterface {
    get { self[AttendanceRepositoryDependency.self] }
    set { self[AttendanceRepositoryDependency.self] = newValue }
  }
}
