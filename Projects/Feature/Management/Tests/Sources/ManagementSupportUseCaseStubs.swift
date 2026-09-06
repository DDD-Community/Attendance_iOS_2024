//
//  ManagementSupportUseCaseStubs.swift
//  ManagementTests
//
//  StaffMain / QrCode / AttendanceCheckFeature 리듀서 테스트용 UseCase 스텁과 고정 픽스처.
//

import Foundation
import SwiftUI

import ComposableArchitecture
import AttendanceDomainInterface
import OnBoardingDomainInterface
import QRCodeDomainInterface
import ScheduleDomainInterface
import VoteDomainInterface

// MARK: - Fixture

enum ManagementSupportFixture {
  static let attendanceCount = AttendanceCount(
    attendanceCount: 10,
    lateCount: 2,
    absentCount: 1
  )

  static let teams: [SelectTeamEntity] = [
    SelectTeamEntity(teamId: 1, teams: .ios1),
    SelectTeamEntity(teamId: 2, teams: .web1)
  ]

  static let attendances: [Attendance] = [
    Attendance(
      id: 100,
      userID: "user-1",
      userName: "김철수",
      userInfo: "iOS1팀/iOS",
      status: .attended
    ),
    Attendance(
      id: 101,
      userID: "user-2",
      userName: "이영희",
      userInfo: "iOS1팀/iOS",
      status: .late
    )
  ]

  static let statuses: [AttendanceStatus] = [.attended, .late, .absent]

  static let editAttendance = EditAttendance(
    isSuccess: true,
    code: "200",
    message: "성공",
    detail: nil
  )

  static let qrValidateSuccess = QRValidateEntity(
    isSuccess: true,
    code: "200",
    message: "출석 완료",
    detail: nil,
    status: .attended
  )

  static let qrValidateFailure = QRValidateEntity(
    isSuccess: false,
    code: "400",
    message: "이미 출석했습니다",
    detail: nil,
    status: nil
  )

  static let schedules: [Schedule] = [EntityFixtureSchedule.value]
}

/// EntityTesting 의존 없이 동작하도록 Schedule 픽스처를 로컬에 둔다.
enum EntityFixtureSchedule {
  static let value = Schedule(
    id: 1,
    name: "OT",
    description: "오리엔테이션",
    month: 9,
    day: 2,
    year: 2026
  )
}

// MARK: - Attendance UseCase Stub

struct ManagementSupportAttendanceUseCase: AttendanceUseCaseInterface, @unchecked Sendable {
  var countResult: Result<AttendanceCount, AttendanceError> = .success(ManagementSupportFixture.attendanceCount)
  var teamsResult: Result<[SelectTeamEntity], AttendanceError> = .success(ManagementSupportFixture.teams)
  var attendanceResult: Result<[Attendance], AttendanceError> = .success(ManagementSupportFixture.attendances)
  var statusResult: Result<[AttendanceStatus], AttendanceError> = .success(ManagementSupportFixture.statuses)
  var editResult: Result<EditAttendance, AttendanceError> = .success(ManagementSupportFixture.editAttendance)

  func adminAttendanceCount(scheduleId _: Int) async throws(AttendanceError) -> AttendanceCount {
    switch countResult {
    case let .success(value): return value
    case let .failure(error): throw error
    }
  }

  func fetchAttendanceTeams() async throws(AttendanceError) -> [SelectTeamEntity] {
    switch teamsResult {
    case let .success(value): return value
    case let .failure(error): throw error
    }
  }

  func sessionAttendance(
    scheduleId _: Int,
    teamId _: Int
  ) async throws(AttendanceError) -> [Attendance] {
    switch attendanceResult {
    case let .success(value): return value
    case let .failure(error): throw error
    }
  }

  func fetchStatus() async throws(AttendanceError) -> [AttendanceStatus] {
    switch statusResult {
    case let .success(value): return value
    case let .failure(error): throw error
    }
  }

  func editAttendance(input _: EditAttendanceInput) async throws(AttendanceError) -> EditAttendance {
    switch editResult {
    case let .success(value): return value
    case let .failure(error): throw error
    }
  }
}

// MARK: - Schedule UseCase Stub

struct ManagementSupportScheduleUseCase: ScheduleUseCaseInterface, @unchecked Sendable {
  var scheduleResult: Result<[Schedule], ScheduleError> = .success(ManagementSupportFixture.schedules)
  var cachedSchedule: [Schedule]?

  func getSchedule() async throws(ScheduleError) -> [Schedule] {
    switch scheduleResult {
    case let .success(value): return value
    case let .failure(error): throw error
    }
  }

  func getCachedSchedule() async -> [Schedule]? {
    cachedSchedule
  }
}

// MARK: - QRCode UseCase Stub

struct ManagementSupportQRCodeUseCase: QRCodeUseCaseInterface, @unchecked Sendable {
  var createResult: Result<String, QRCodeError> = .success("qr-payload")
  var validateResult: Result<QRValidateEntity, QRCodeError> = .success(ManagementSupportFixture.qrValidateSuccess)

  func createQRCode(userID _: Int) async throws(QRCodeError) -> String {
    switch createResult {
    case let .success(value): return value
    case let .failure(error): throw error
    }
  }

  func generateQRCode(from _: String) async -> Image? {
    nil
  }

  func qrValidateCheck(from _: String) async throws(QRCodeError) -> QRValidateEntity {
    switch validateResult {
    case let .success(value): return value
    case let .failure(error): throw error
    }
  }
}
