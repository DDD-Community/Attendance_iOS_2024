//
//  AttendanceUseCaseInterface.swift
//  AttendanceDomainInterface
//
//  Created by DDD on 9/3/26.
//

import OnBoardingDomainInterface

import Dependencies

public protocol AttendanceUseCaseInterface: Sendable {
  func adminAttendanceCount(scheduleId: Int) async throws(AttendanceError) -> AttendanceCount
  func fetchAttendanceTeams() async throws(AttendanceError) -> [SelectTeamEntity]
  func sessionAttendance(scheduleId: Int, teamId: Int) async throws(AttendanceError) -> [Attendance]
  func fetchStatus() async throws(AttendanceError) -> [AttendanceStatus]
  func editAttendance(input: EditAttendanceInput) async throws(AttendanceError) -> EditAttendance
}

extension MockAttendanceRepository: AttendanceUseCaseInterface {}

public enum AttendanceUseCaseDependency: TestDependencyKey {
  public static let testValue: any AttendanceUseCaseInterface = MockAttendanceRepository()
  public static let previewValue: any AttendanceUseCaseInterface = testValue
}

public extension DependencyValues {
  var attendanceUseCase: any AttendanceUseCaseInterface {
    get { self[AttendanceUseCaseDependency.self] }
    set { self[AttendanceUseCaseDependency.self] = newValue }
  }
}
