//
//  AttendanceRepositoryImplTests.swift
//  DomainAssemblyTests
//
//  Created by DDD on 9/4/26.
//

import Foundation
import Testing

@testable import AppUpdateDomain
@testable import AttendanceDomain
@testable import AuthDomain
import DDDNetworkInterface
@testable import MyPageDomain
@testable import OnBoardingDomain
@testable import ProfileDomain
@testable import QRCodeDomain
@testable import ScheduleDomain
@testable import VoteDomain

struct AttendanceRepositoryImplTests {
  private let input = EditAttendanceInput(
    attendanceId: 3,
    scheduleId: 9,
    status: .attended,
    userId: "11"
  )

  @Test("출석 조회 API 성공 응답을 도메인으로 변환")
  func readSuccessPaths() async throws {
    let client = StubNetworkClient([
      .response(200, #"{"totalAttended":3,"totalLate":2,"totalAbsent":1}"#),
      .response(200, "[]"),
      .response(200, "[]"),
      .response(200, "[]")
    ])
    let repository = makeRepository(client: client) { AttendanceRepositoryImpl() }

    let count = try await repository.adminAttendanceCount(scheduleId: 1)
    #expect(count.attendanceCount == 3)
    #expect(try await repository.fetchAttendanceTeams().isEmpty)
    #expect(try await repository.sessionAttendance(scheduleId: 1, teamId: 2).isEmpty)
    #expect(try await repository.fetchStatus().isEmpty)
  }

  @Test("출석 조회 실패는 loadFailed")
  func readFailure() async {
    let repository = makeRepository(client: StubNetworkClient(error: .response(.init(httpStatus: 500)))) { AttendanceRepositoryImpl() }
    await #expect(throws: AttendanceError.loadFailed) {
      try await repository.fetchStatus()
    }
  }

  @Test("출석 변경 성공 응답의 세 가지 형태를 허용", arguments: [
    (204, ""),
    (200, #"{"message":"ok"}"#),
    (200, "not-json")
  ])
  func editSuccess(status: Int, json: String) async throws {
    let repository = makeRepository(client: StubNetworkClient(statusCode: status, json: json)) { AttendanceRepositoryImpl() }
    #expect(try await repository.editAttendance(input: input).isSuccess)
  }

  @Test("4xx 상세 메시지는 rejected")
  func editRejected() async {
    let repository = makeRepository(client: StubNetworkClient(statusCode: 400, json: #"{"message":"출석일이 아닙니다"}"#)) { AttendanceRepositoryImpl() }
    await #expect(throws: AttendanceError.rejected("출석일이 아닙니다")) {
      try await repository.editAttendance(input: input)
    }
  }

  @Test("메시지 없는 오류 응답은 updateFailed", arguments: [400, 500])
  func editResponseFailure(status: Int) async {
    let repository = makeRepository(client: StubNetworkClient(statusCode: status, json: "{}")) { AttendanceRepositoryImpl() }
    await #expect(throws: AttendanceError.updateFailed) {
      try await repository.editAttendance(input: input)
    }
  }

  @Test("출석 변경 전송 실패는 updateFailed")
  func editTransportFailure() async {
    let repository = makeRepository(client: StubNetworkClient(error: .response(.init(httpStatus: 503)))) { AttendanceRepositoryImpl() }
    await #expect(throws: AttendanceError.updateFailed) {
      try await repository.editAttendance(input: input)
    }
  }
}
