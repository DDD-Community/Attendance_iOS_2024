//
//  AttendanceUseCaseImpl.swift
//  AttendanceDomain
//
//  Created by DDD on 7/23/25.
//

import AttendanceDomainInterface
import OnBoardingDomainInterface

import Dependencies


public struct AttendanceUseCaseImpl: AttendanceUseCaseInterface {
  @Dependency(\.attendanceRepository) var repository
  
  public init() { }


  public func adminAttendanceCount(scheduleId: Int) async throws(AttendanceError) -> AttendanceCount {
    return try await repository.adminAttendanceCount(scheduleId: scheduleId)
  }

  public func fetchAttendanceTeams() async throws(AttendanceError) -> [SelectTeamEntity] {
    return try await repository.fetchAttendanceTeams()
  }

  public func sessionAttendance(
    scheduleId: Int,
    teamId: Int
  ) async throws(AttendanceError) -> [Attendance] {
    return try await repository.sessionAttendance(scheduleId: scheduleId, teamId: teamId)
  }

  public func fetchStatus() async throws(AttendanceError) -> [AttendanceStatus] {
    return try await repository.fetchStatus()
  }

  public func editAttendance(
    input: EditAttendanceInput
  ) async throws(AttendanceError) -> EditAttendance {
    return try await repository.editAttendance(input: input)
  }
}
