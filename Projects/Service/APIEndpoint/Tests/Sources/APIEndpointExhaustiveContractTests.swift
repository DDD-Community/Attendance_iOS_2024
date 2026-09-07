//
//  APIEndpointExhaustiveContractTests.swift
//  APIEndpointTests
//
//  Created by DDD on 9/4/26.
//

import Foundation
import Testing

@testable import APIEndpoint
import VoteDomainInterface

@Suite("APIEndpoint exhaustive contracts")
struct APIEndpointExhaustiveContractTests {
  @Test("AuthRequest의 모든 method, path, authorization, parameter 계약")
  func authContracts() throws {
    let loginBody = OAuthLoginRequest(provider: "apple", token: "id-token")
    let login = AuthRequest.login(body: loginBody)
    let refresh = AuthRequest.refresh(refreshToken: "refresh-token")
    let withdraw = AuthRequest.withdraw(token: "access-token")
    let logout = AuthRequest.logout

    #expect(login.path == "api/auth/login")
    #expect(refresh.path == "api/auth/refresh")
    #expect(withdraw.path == "api/users/me")
    #expect(logout.path == "api/auth/logout")
    #expect(login.method.rawValue == "POST")
    #expect(refresh.method.rawValue == "POST")
    #expect(withdraw.method.rawValue == "DELETE")
    #expect(logout.method.rawValue == "POST")
    #expect(login.authorization == .none)
    #expect(refresh.authorization == .none)
    #expect(withdraw.authorization == .automatic)
    #expect(logout.authorization == .automatic)
    #expect(try dictionary(login.parameters)["provider"] as? String == "apple")
    #expect(try dictionary(refresh.parameters)["refreshToken"] as? String == "refresh-token")
    #expect(try dictionary(withdraw.parameters)["token"] as? String == "access-token")
    #expect(logout.parameters == nil)
  }

  @Test("AttendanceRequest의 모든 method, path, parameter 계약")
  func attendanceContracts() throws {
    let sessionBody = AttendanceRequestDTO(scheduleId: 22, teamId: 4)
    let editBody = EditAttendanceRequestDTO(
      attendanceId: "91",
      status: "ATTENDANCE",
      userId: "user-2",
      scheduleId: "22"
    )
    let requests: [(AttendanceRequest, String, String)] = [
      (.adminAttendanceCount(scheduleId: 22), "api/admin/me/schedules/22/attendances", "GET"),
      (.fetchTeams, "api/admin/me/generations/teams", "GET"),
      (.sessionAttendance(body: sessionBody), "api/admin/me/schedules/22/teams/4/attendances", "GET"),
      (.status, "api/attendances/status", "GET"),
      (.editAttendance(body: editBody), "api/attendances", "PUT")
    ]

    for (request, path, method) in requests {
      #expect(request.path == path)
      #expect(request.method.rawValue == method)
    }
    #expect(AttendanceRequest.adminAttendanceCount(scheduleId: 22).parameters == nil)
    #expect(AttendanceRequest.fetchTeams.parameters == nil)
    #expect(AttendanceRequest.status.parameters == nil)
    #expect(try dictionary(AttendanceRequest.sessionAttendance(body: sessionBody).parameters)["teamId"] as? Int == 4)
    let edit = try dictionary(AttendanceRequest.editAttendance(body: editBody).parameters)
    #expect(edit["attendanceId"] as? String == "91")
    #expect(edit["status"] as? String == "ATTENDANCE")
  }

  @Test("MyPage와 Schedule request의 모든 계약")
  func myPageAndScheduleContracts() {
    #expect(MyPageService.fetchAttendances.path == "api/me/attendances")
    #expect(MyPageService.fetchSchedules.path == "api/me/schedules")
    #expect(MyPageService.fetchAttendances.method.rawValue == "GET")
    #expect(MyPageService.fetchSchedules.method.rawValue == "GET")
    #expect(ScheduleRequest.getSchedule.path == "api/schedules")
    #expect(ScheduleRequest.getSchedule.method.rawValue == "GET")
  }

  @Test("OnBoardingService의 모든 path와 parameter 계약")
  func onboardingContracts() throws {
    let requests: [(OnBoardingService, String)] = [
      (.verifyCode(code: "ABC123"), "api/onboarding/verify-code"),
      (.jobs, "api/onboarding/jobs"),
      (.teams(generationId: 12), "api/onboarding/teams"),
      (.mangerRole, "api/onboarding/manager-roles")
    ]
    for (request, path) in requests {
      #expect(request.path == path)
      #expect(request.method.rawValue == "GET")
      #expect(request.authorization == .none)
    }
    #expect(try dictionary(OnBoardingService.verifyCode(code: "ABC123").parameters)["code"] as? String == "ABC123")
    #expect(try dictionary(OnBoardingService.teams(generationId: 12).parameters)["generationId"] as? Int == 12)
    #expect(OnBoardingService.jobs.parameters == nil)
    #expect(OnBoardingService.mangerRole.parameters == nil)
  }

  @Test("ProfileService의 모든 path, method, parameter 계약")
  func profileContracts() throws {
    let editBody = EditProfileRequestDTO(
      name: "수지원",
      generationId: 12,
      jobRole: "IOS",
      teamId: 3,
      managerRoles: ["LEADER"],
      invitationCode: "DDD"
    )
    #expect(ProfileService.getUserProfile.path == "api/me")
    #expect(ProfileService.getAdminProfile.path == "api/admin/me")
    #expect(ProfileService.editProfile(body: editBody).path == "api/users/me")
    #expect(ProfileService.getUserProfile.method.rawValue == "GET")
    #expect(ProfileService.getAdminProfile.method.rawValue == "GET")
    #expect(ProfileService.editProfile(body: editBody).method.rawValue == "PUT")
    #expect(ProfileService.getUserProfile.parameters == nil)
    #expect(ProfileService.getAdminProfile.parameters == nil)
    #expect(try dictionary(ProfileService.editProfile(body: editBody).parameters)["managerRoles"] as? [String] == ["LEADER"])
  }

  @Test("EditProfileRequestDTO는 역할 상태에 따라 managerRoles를 구분한다")
  func editProfileEncodingContracts() throws {
    let manager = EditProfileRequestDTO(
      name: "관리자", generationId: 12, jobRole: "IOS", teamId: 1,
      managerRoles: ["LEADER"], invitationCode: "DDD"
    )
    let emptyManager = EditProfileRequestDTO(
      name: "관리자", generationId: 12, jobRole: "IOS", teamId: 1,
      managerRoles: [], invitationCode: "DDD"
    )
    let member = EditProfileRequestDTO(
      name: "멤버", generationId: 12, jobRole: "IOS", teamId: nil,
      managerRoles: nil, invitationCode: "DDD"
    )

    #expect(try dictionary(manager)["managerRoles"] as? [String] == ["LEADER"])
    #expect(try dictionary(emptyManager)["managerRoles"] is NSNull)
    #expect(try dictionary(member)["managerRoles"] == nil)
    #expect(try dictionary(member)["teamId"] is NSNull)
  }

  @Test("QRService의 두 요청 계약")
  func qrContracts() throws {
    let check = QRService.qrAttendanceCheck(qrCode: "qr-value")
    let create = QRService.createQRCode(userID: 77)
    #expect(check.path == "api/attendances")
    #expect(create.path == "api/users/77/qr")
    #expect(check.method.rawValue == "POST")
    #expect(create.method.rawValue == "GET")
    #expect(try dictionary(check.parameters)["qrCode"] as? String == "qr-value")
    #expect(try dictionary(create.parameters)["id"] as? Int == 77)
  }

  @Test("SignUpService와 DTO의 Google, Apple 인코딩 계약")
  func signUpContracts() throws {
    let profile = BaseUserProfileDTO(
      name: "회원", generationId: 12, jobRole: "IOS", teamId: 3,
      managerRoles: nil, invitationCode: "DDD"
    )
    let apple = SignUpUserRequestDTO(
      profile: profile,
      authentication: AuthenticationDTO(provider: "Apple", token: "apple-token", oauthRefreshToken: "refresh")
    )
    let google = SignUpUserRequestDTO(
      name: "회원", generationId: 12, jobRole: "IOS", teamId: 3,
      managerRoles: nil, provider: "google", token: "google-token",
      invitationCode: "DDD"
    )

    let request = SignUpService.signUpUser(body: apple)
    #expect(request.path == "api/users")
    #expect(request.method.rawValue == "POST")
    #expect(request.authorization == .none)
    #expect(try dictionary(request.parameters)["oauthRefreshToken"] as? String == "refresh")
    #expect(try dictionary(google)["oauthRefreshToken"] == nil)
    #expect(try dictionary(google)["token"] as? String == "google-token")
  }

  @Test("VoteRequest의 모든 path와 method 계약")
  func voteContracts() {
    let create = CreateVoteInput(generationId: 12, title: "투표", teamVoteTemplate: nil, feedbackTemplate: nil)
    let submission = VoteSubmission(teamVote: [], feedback: [])
    let contracts: [(VoteRequest, String, String)] = [
      (.list, "api/votes", "GET"),
      (.create(body: create), "api/votes", "POST"),
      (.detail(voteId: 5), "api/votes/5", "GET"),
      (.participation(voteId: 5), "api/votes/5/participation", "GET"),
      (.nonResponders(voteId: 5), "api/votes/5/non-responders", "GET"),
      (.open(voteId: 5), "api/votes/5/open", "PATCH"),
      (.close(voteId: 5), "api/votes/5/close", "PATCH"),
      (.teamVoteResults(voteId: 5), "api/votes/5/team-vote/results", "GET"),
      (.feedbackResults(voteId: 5), "api/votes/5/feedback/results", "GET"),
      (.active, "api/votes/active", "GET"),
      (.teamVoteTemplate(voteId: 5), "api/votes/5/team-vote/template", "GET"),
      (.feedbackTemplate(voteId: 5), "api/votes/5/feedback/template", "GET"),
      (.submit(voteId: 5, body: submission), "api/votes/5/responses", "POST"),
      (.myResponse(voteId: 5), "api/votes/5/responses/me", "GET")
    ]

    for (request, path, method) in contracts {
      #expect(request.path == path)
      #expect(request.method.rawValue == method)
    }
    #expect(VoteRequest.create(body: create).parameters != nil)
    #expect(VoteRequest.submit(voteId: 5, body: submission).parameters != nil)
    #expect(VoteRequest.list.parameters == nil)
  }

  @Test("Encodable helper는 dictionary 변환 성공과 실패를 구분한다")
  func encodableHelpers() {
    #expect("value".toDictionary(key: "key")["key"] as? String == "value")
    #expect(7.toDictionary(key: "id")["id"] as? Int == 7)
    #expect(BaseUserProfileDTO(
      name: "회원", generationId: 12, jobRole: "IOS", teamId: nil,
      managerRoles: nil, invitationCode: "DDD"
    ).toDictionary?["name"] as? String == "회원")
    #expect(ThrowingEncodable().toDictionary == nil)
    #expect("scalar".toDictionary == nil)
  }
}

private func dictionary(_ value: (any Encodable & Sendable)?) throws -> [String: Any] {
  let value = try #require(value)
  return try dictionary(value)
}

private func dictionary(_ value: some Encodable) throws -> [String: Any] {
  let data = try JSONEncoder().encode(EndpointAnyEncodable(value))
  return try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
}

private struct EndpointAnyEncodable: Encodable {
  private let encodeValue: (Encoder) throws -> Void

  init(_ value: some Encodable) {
    encodeValue = value.encode(to:)
  }

  func encode(to encoder: Encoder) throws {
    try encodeValue(encoder)
  }
}

private struct ThrowingEncodable: Encodable {
  func encode(to _: Encoder) throws {
    throw EncodingError.invalidValue(
      "failure",
      .init(codingPath: [], debugDescription: "의도한 테스트 오류")
    )
  }
}
