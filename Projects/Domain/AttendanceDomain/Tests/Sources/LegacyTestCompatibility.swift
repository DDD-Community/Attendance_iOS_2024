//
//  LegacyTestCompatibility.swift
//  AttendanceDomainTests
//
//  Created by DDD on 9/4/26.
//

import Testing

import AttendanceDomainInterface
import OnBoardingDomainInterface
import ProfileDomainInterface

extension Tag {
  @Tag static var unit: Self
}

extension SelectParts {
  static var developer: Self { .ios }
  static var planner: Self { .pm }
}

extension AttendanceStatus {
  static var attendance: Self { .attended }
}

extension AttendanceCount {
  init(totalCount: Int, attendanceCount: Int, lateCount: Int, absentCount: Int) {
    self.init(attendanceCount: attendanceCount, lateCount: lateCount, absentCount: absentCount)
  }

  var totalCount: Int { attendanceCount + lateCount + absentCount }
}

extension EditAttendanceInput {
  init(attendanceId: Int?, scheduleId: Int, teamId: Int, userId: String, newStatus: AttendanceStatus) {
    self.init(attendanceId: attendanceId, scheduleId: scheduleId, status: newStatus, userId: userId)
  }

  var newStatus: AttendanceStatus { status }
}

extension EditAttendance {
  init(isSuccess: Bool, message: String?, attendanceId: Int?) {
    self.init(isSuccess: isSuccess, code: attendanceId.map(String.init), message: message, detail: nil)
  }

  var attendanceId: Int? { code.flatMap(Int.init) }
}

extension Attendance {
  init(attendanceId: Int, userId: String, teamId: Int, status: AttendanceStatus) {
    let team: SelectTeams = switch teamId {
    case 1: .ios1
    case 2: .ios2
    case 3: .and1
    case 4: .and2
    default: .unknown
    }
    self.init(
      id: attendanceId,
      userID: userId,
      userName: userId,
      userInfo: "\(team.description)/IOS",
      status: status
    )
  }

  var teamId: Int {
    switch selectTeamEntity {
    case .ios1: 1
    case .ios2: 2
    case .and1: 3
    case .and2: 4
    default: 0
    }
  }
}

extension SelectTeams {
  static var android1: Self { .and1 }
  static var android2: Self { .and2 }
  static var design: Self { .web1 }
  static var planning: Self { .web2 }
  static var backend: Self { .web2 }
  static var teamA: Self { .ios1 }
  static var teamB: Self { .ios2 }
  static var teamC: Self { .and1 }
}

extension StaffManaging {
  static var ios: Self { .teamManaging }
  static var android: Self { .scheduleReminder }
  static var design: Self { .photo }
  static var planning: Self { .locationRental }
  static var backend: Self { .attendanceCheck }
  static var development: Self { .teamManaging }
}

extension SelectTeamEntity {
  init(id: Int, name: String, description: String) {
    self.init(teamId: id, teams: .from(name: name))
  }

  var id: Int { teamId }
  var name: String { teams.description }
  var description: String { teams.managingTeamDesc }
}

extension SelectManaging {
  init(id: String, name: String, description: String) {
    self.init(managingKeys: id, managing: .from(apiKey: id) ?? .teamManaging)
  }

  var name: String { managing.desc }
  var description: String { managing.desc }
}
