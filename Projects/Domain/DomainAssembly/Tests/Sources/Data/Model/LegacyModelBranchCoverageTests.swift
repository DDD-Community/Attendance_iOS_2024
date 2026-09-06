//
//  LegacyModelBranchCoverageTests.swift
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

@Suite("Legacy model branch coverage")
struct LegacyModelBranchCoverageTests {
  @Test("모든 출석 상태는 API, 한글, 이미지 표현을 제공한다")
  func attendanceTypeRepresentations() throws {
    let cases: [AttendanceType] = [
      .present, .absent, .late, .earlyLeave, .disease, .run, .notAttendance, .tbd
    ]

    #expect(cases.map(\.desc) == [
      "PRESENT", "ABSENT", "LATE", "EARLY_LEAVE", "DISEASE", "RUN", "NOT_ATTENDANCE", "THD"
    ])
    #expect(cases.map(\.koreanDesc) == ["출석", "결석", "지각", "조퇴", "병결", "탈주", "미참여", "대기"])
    #expect(cases.map(\.imageDesc) == [
      "Present_icons", "Abesent_icons", "Late_icons", "EarlyLeave_icons",
      "Disease_icons", "Run_icons", "None_icons", "Thd_icons"
    ])

    let data = try JSONEncoder().encode(AttendanceType.earlyLeave)
    #expect(try JSONDecoder().decode(AttendanceType.self, from: data) == .earlyLeave)
    #expect(try decodeAttendance("unexpected") == .tbd)
    #expect(try decodeAttendance("") == .tbd)
  }

  @Test("모든 팀 표기와 목록을 제공하고 알 수 없는 디코딩을 흡수한다")
  func selectTeamRepresentations() throws {
    let teams = SelectTeam.allCases
    #expect(teams.map(\.description).count == 8)
    #expect(teams.map(\.managingTeamDesc).count == 8)
    #expect(teams.map(\.selectTeamDescription).count == 8)
    #expect(teams.map(\.attendanceListDescription).count == 8)
    #expect(teams.map(\.attandanceCardDescription).count == 8)
    #expect(teams.map(\.isDescEqualToAttendanceListDescription).count == 8)
    #expect(SelectTeam.teamList.count == 6)
    #expect(SelectTeam.attandanceList.count == 6)
    #expect(try decodeTeam("") == .unknown)
    #expect(try decodeTeam("new-team") == .unknown)
    #expect(try decodeTeam("iOS_1") == .ios1)
  }

  @Test("모든 파트와 운영 역할의 표시 분기를 제공한다")
  func partAndManagingRepresentations() throws {
    #expect(SelectPart.allCases.map(\.desc).count == 7)
    #expect(SelectPart.allCases.map(\.attendanceListDesc).count == 7)
    #expect(SelectPart.allCases.map(\.isDescEqualToAttendanceListDesc).count == 7)
    #expect(SelectPart.allParts.count == 6)

    #expect(Managing.allCases.map(\.managingDesc).count == 9)
    #expect(Managing.managingList.count == 7)
    #expect(try decodeManaging("   ") == .notManaging)
    #expect(try decodeManaging("new-role") == .notManaging)
    #expect(try decodeManaging("Attendance_Check") == .attendanceCheck)
  }

  @Test("모든 멤버 유형은 사용자 표시명을 제공한다")
  func memberTypeDescriptions() {
    #expect([
      MemberType.master.memberDesc,
      MemberType.coreMember.memberDesc,
      MemberType.member.memberDesc,
      MemberType.run.memberDesc,
      MemberType.notYet.memberDesc
    ] == ["회장", "운영진", "멤버", "탈주", ""])
  }

  @Test("CustomError는 모든 설명과 복구 안내를 제공하고 기존 오류를 보존한다")
  func customErrorMessagesAndMapping() {
    let errors: [CustomError] = [
      .wrongQueryType,
      .networkDisconnected,
      .unAuthorized,
      .internalServer,
      .responseBodyEmpty,
      .decodeFailed,
      .invalidURL,
      .invalidEventId,
      .unknownError("원인"),
      .firestoreError("저장 실패"),
      .encodingError("인코딩 실패"),
      .none
    ]

    #expect(errors.dropLast().allSatisfy { $0.errorDescription != nil })
    #expect(errors.dropLast().allSatisfy { $0.recoverySuggestion != nil })
    #expect(errors.last?.errorDescription == nil)
    #expect(errors.last?.recoverySuggestion == nil)
    #expect(CustomError.map(CustomError.invalidURL) == .invalidURL)
    #expect(CustomError.map(SampleError()) != .none)
  }
}

private struct SampleError: Error {}

private func decodeAttendance(_ value: String) throws -> AttendanceType {
  try JSONDecoder().decode(AttendanceType.self, from: Data(#""\#(value)""#.utf8))
}

private func decodeTeam(_ value: String) throws -> SelectTeam {
  try JSONDecoder().decode(SelectTeam.self, from: Data(#""\#(value)""#.utf8))
}

private func decodeManaging(_ value: String) throws -> Managing {
  try JSONDecoder().decode(Managing.self, from: Data(#""\#(value)""#.utf8))
}
