//
//  EntityMappingBehaviorTests.swift
//  DomainAssemblyTests
//
//  Created by DDD on 9/4/26.
//

import Foundation
import Testing

import AppUpdateDomainInterface
import AttendanceDomainInterface
import AuthDomainInterface
import OnBoardingDomainInterface
import ProfileDomainInterface
import ScheduleDomainInterface
import VoteDomainInterface


@Suite("Entity mapping behavior")
struct EntityMappingBehaviorTests {
  @Test("SelectParts는 표시값과 API 키를 양방향 매핑한다")
  func selectPartsMapping() {
    let expected: [(SelectParts, String, String)] = [
      (.all, "전체", "ALL"),
      (.pm, "Product Manager", "PM"),
      (.designer, "Product Designer", "DESIGNER"),
      (.android, "Android", "ANDROID"),
      (.ios, "iOS", "IOS"),
      (.frontend, "Frontend", "FRONTEND"),
      (.backend, "Backend", "BACKEND")
    ]
    for (part, description, apiKey) in expected {
      #expect(part.desc == description)
      #expect(part.apiKey == apiKey)
      #expect(SelectParts.from(apiKey: apiKey) == part)
    }
    #expect(SelectParts.from(apiKey: "BE") == .backend)
    #expect(SelectParts.from(apiKey: "FE") == .frontend)
    #expect(SelectParts.from(apiKey: "PD") == .designer)
    #expect(SelectParts.from(apiKey: "AND") == .android)
    #expect(SelectParts.from(apiKey: "UNKNOWN") == nil)
  }

  @Test("SelectTeams는 모든 화면용 문구와 서버 이름을 매핑한다")
  func selectTeamsMapping() {
    let teams: [SelectTeams] = [.and1, .and2, .ios1, .ios2, .web1, .web2, .unknown]
    let managing = ["Android 1", "Android 2", "iOS 1", "iOS 2", "WEB 1", "WEB 2", ""]
    let cards = ["Android1팀", "Android2팀", "iOS1팀", "iOS2팀", "WEB1팀", "WEB2팀", ""]

    for index in teams.indices {
      #expect(teams[index].managingTeamDesc == managing[index])
      #expect(teams[index].attandanceCardDescription == cards[index])
      #expect(teams[index].attendanceListDescription == teams[index].rawValue)
      #expect(teams[index].description == teams[index].rawValue)
      _ = teams[index].selectTeamDescription
    }
    #expect(SelectTeams.from(name: "IOS 1팀") == .ios1)
    #expect(SelectTeams.from(name: "없는 팀") == .unknown)
  }

  @Test("SelectTeamEntity는 팀 선택과 정렬을 제공한다")
  func selectTeamEntityMapping() {
    let teams = [
      SelectTeamEntity(teamId: 3, teams: .unknown),
      SelectTeamEntity(teamId: 2, teams: .web2),
      SelectTeamEntity(teamId: 1, teams: .and1)
    ]
    #expect(teams[0].id == 3)
    #expect(teams[0].toSelectTeam == nil)
    #expect(teams[1].toSelectTeam == .web2)
    #expect(teams.orderedSelectTeams() == [.and1, .web2])

    for team in [SelectTeams.and1, .and2, .ios1, .ios2, .web1, .web2] {
      #expect(SelectTeamEntity(teamId: 1, teams: team).toSelectTeam == team)
    }
  }

  @Test("Staff와 StaffManaging은 API 키와 표시값을 매핑한다")
  func staffMapping() {
    #expect(Staff.member.description == "MEMBER")
    #expect(Staff.manager.description == "MANAGER")
    #expect(Staff.from(apiKey: "MEMBER") == .member)
    #expect(Staff.from(apiKey: "manager") == .manager)
    #expect(Staff.from(apiKey: "guest") == nil)

    let descriptions = ["팀매니징", "일정 리마인드", "사진 촬영", "장소 대관", "SNS 관리", "출석 체크"]
    for (role, description) in zip(StaffManaging.allCases, descriptions) {
      #expect(role.desc == description)
      #expect(role.apiKey == role.rawValue)
      #expect(StaffManaging.from(apiKey: role.rawValue.lowercased()) == role)
      #expect(StaffManaging.from(apiKey: description) == role)
    }
    #expect(StaffManaging.from(apiKey: "UNKNOWN") == nil)
  }

  @Test("AttendanceStatus와 사용자 정보 문자열을 도메인 값으로 변환한다")
  func attendanceMapping() {
    let statuses: [(AttendanceStatus, String)] = [
      (.attended, "출석"), (.late, "지각"), (.absent, "결석"), (.defaults, "대기")
    ]
    for (status, description) in statuses {
      #expect(status.id == status.rawValue)
      #expect(status.apiKey == status.rawValue)
      #expect(status.desc == description)
      #expect(AttendanceStatus.from(apiKey: status.rawValue.lowercased()) == status)
    }
    #expect(AttendanceStatus.from(apiKey: "unknown") == nil)

    let cases: [(String, SelectTeams?, SelectParts?)] = [
      ("WEB 1팀 / FE", .web1, .frontend),
      ("WEB 2팀 / BE", .web2, .backend),
      ("IOS 1팀 / IOS", .ios1, .ios),
      ("IOS 2팀 / PM", .ios2, .pm),
      ("ANDROID 1팀 / ANDROID", .and1, .android),
      ("AND 2팀 / DESIGNER", .and2, .designer),
      ("UNKNOWN / UNKNOWN", nil, nil),
      ("IOS 1팀", .ios1, nil),
      ("", nil, nil)
    ]
    for (info, team, part) in cases {
      let attendance = Attendance(id: nil, userID: "1", userName: "사용자", userInfo: info, status: .attended)
      #expect(attendance.selectTeamEntity == team)
      #expect(attendance.selectPartEntity == part)
    }
  }

  @Test("SocialType과 VoteStatus가 외부 값을 화면 상태로 바꾼다")
  func oauthAndVoteStatusMapping() {
    #expect(SocialType.apple.id == "apple")
    #expect(SocialType.apple.description == "APPLE")
    #expect(SocialType.apple.image == "apple.logo")
    #expect(SocialType.google.id == "google")
    #expect(SocialType.google.description == "GOOGLE")
    #expect(SocialType.google.image == "google")
    #expect(VoteStatus(serverStatus: "open") == .inProgress)
    #expect(VoteStatus(serverStatus: "closed") == .after)
    #expect(VoteStatus(serverStatus: "draft") == .before)
    #expect(VoteStatus(serverStatus: "unknown") == .before)
  }

  @Test("Schedule은 지정 시간대의 자정 날짜로 변환된다")
  func scheduleDateConversion() throws {
    let timeZone = try #require(TimeZone(identifier: "Asia/Seoul"))
    let schedule = Schedule(id: 1, name: "일정", description: "설명", month: 9, day: 2, year: 2026)
    let date = try #require(schedule.toDate(timeZone: timeZone))
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
    #expect(components.year == 2026)
    #expect(components.month == 9)
    #expect(components.day == 2)
    #expect(components.hour == 0)
  }

  @Test("앱 업데이트 DTO는 Codable 왕복을 지원한다")
  func appUpdateCodableRoundTrip() throws {
    let info = AppUpdateInfo(
      currentVersion: "1.0", latestVersion: "2.0", releaseNotes: "새 기능",
      appStoreUrl: "https://example.com", isUpdateAvailable: true
    )
    let decoded = try JSONDecoder().decode(AppUpdateInfo.self, from: JSONEncoder().encode(info))
    #expect(decoded == info)

    let app = iTunesAppInfo(version: "2.0", releaseNotes: nil, trackViewUrl: "https://example.com")
    let response = iTunesLookupResponse(results: [app])
    let roundTrip = try JSONDecoder().decode(
      iTunesLookupResponse.self,
      from: JSONEncoder().encode(response)
    )
    #expect(roundTrip.results.first?.version == "2.0")
    #expect(roundTrip.results.first?.releaseNotes == nil)
  }
}
