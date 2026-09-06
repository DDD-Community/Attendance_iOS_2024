//
//  ProfileScheduleRepositoryImplTests.swift
//  DomainAssemblyTests
//
//  Created by DDD on 9/4/26.
//

import APIEndpoint
import Dependencies
import DDDNetworkInterface
import Foundation
import SQLiteData
import Testing

@testable import AppUpdateDomain
@testable import AttendanceDomain
@testable import AuthDomain
@testable import DDDStorage
@testable import MyPageDomain
@testable import OnBoardingDomain
@testable import ProfileDomain
@testable import QRCodeDomain
@testable import ScheduleDomain
@testable import VoteDomain

@Suite("ProfileRepositoryImpl")
struct ProfileRepositoryImplTests {
  @Test("캐시된 프로필을 네트워크 호출 없이 반환한다")
  func getCachedProfileReturnsLocalValue() async {
    let cached = Self.cachedProfile
    let localDataSource = ProfileLocalDataSourceStub(profile: cached)
    let client = ProfileScheduleClient(error: .transport(.notConnected))
    let repository = withDependencies {
      $0.profileLocalDataSource = localDataSource
    } operation: {
      makeRepository(client: client) { ProfileRepositoryImpl() }
    }

    let result = await repository.getCachedProfile()

    #expect(result == cached)
  }

  @Test("getProfile은 캐시가 있으면 즉시 캐시를 반환한다")
  func getProfileReturnsCacheHit() async throws {
    let cached = Self.cachedProfile
    let localDataSource = ProfileLocalDataSourceStub(profile: cached)
    let client = ProfileScheduleClient(error: .transport(.notConnected))
    let repository = withDependencies {
      $0.profileLocalDataSource = localDataSource
    } operation: {
      makeRepository(client: client) { ProfileRepositoryImpl() }
    }

    let result = try await repository.getProfile()

    #expect(result == cached)
  }

  @Test("프로필 DTO를 도메인 모델로 변환한다")
  func refreshProfileMapsDTO() async throws {
    let client = ProfileScheduleClient(json: Self.profileJSON)
    let repository = makeProfileRepository(client: client)

    let profile = try await repository.refreshProfile()

    #expect(profile.userID == 17)
    #expect(profile.name == "테스터")
    #expect(profile.generation == "12")
    #expect(profile.team == .ios1)
    #expect(profile.jobRole == .ios)
    #expect(profile.role == .manager)
    #expect(profile.manger == [.attendanceCheck, .photo])
  }

  @Test("프로필 조회 HTTP 오류를 도메인 오류로 변환한다", arguments: [
    (401, ProfileError.invalidSession),
    (403, ProfileError.profileAccessDenied),
    (404, ProfileError.profileNotFound),
    (500, ProfileError.loadFailed)
  ])
  func refreshProfileMapsResponseError(status: Int, expected: ProfileError) async {
    let client = ProfileScheduleClient(error: .response(.init(httpStatus: status)))
    let repository = makeProfileRepository(client: client)

    await #expect(throws: expected) {
      try await repository.refreshProfile()
    }
  }

  @Test("프로필 디코딩 실패를 손상된 데이터 오류로 변환한다")
  func refreshProfileMapsDecodingFailure() async {
    let client = ProfileScheduleClient(json: #"{"userId":"invalid"}"#)
    let repository = makeProfileRepository(client: client)

    await #expect(throws: ProfileError.profileDataCorrupted) {
      try await repository.refreshProfile()
    }
  }

  @Test("프로필 수정 입력을 요청 DTO에 빠짐없이 전달한다")
  func editProfileForwardsInput() async throws {
    let client = ProfileScheduleClient(json: Self.profileJSON)
    let database = try DatabaseQueue()
    try AppDatabaseMigrator.migrate(database)
    let localDataSource = ProfileLocalDataSource(database: database)
    let repository = withDependencies {
      $0.profileLocalDataSource = localDataSource
    } operation: {
      makeRepository(client: client) { ProfileRepositoryImpl() }
    }
    let input = EditProfileInput(
      name: "수정 이름",
      generationId: 13,
      jobRole: .backend,
      teamId: 4,
      managerRoles: [.teamManaging, .scheduleReminder],
      inviteCode: "INVITE-13"
    )

    let profile = try await repository.editProfile(input: input)
    let body = await client.lastEditProfileBody
    let cachedProfile = try await localDataSource.loadUser()

    #expect(profile.userID == 17)
    #expect(cachedProfile == profile)
    #expect(body?.name == "수정 이름")
    #expect(body?.generationId == 13)
    #expect(body?.jobRole == "BACKEND")
    #expect(body?.teamId == 4)
    #expect(body?.managerRoles == ["TEAM_MANAGING", "SCHEDULE_REMINDER"])
    #expect(body?.invitationCode == "INVITE-13")
  }

  @Test("프로필 수정 오류를 도메인 오류로 변환한다", arguments: [
    (404, EditProfileError.profileNotFound),
    (423, EditProfileError.profileLocked),
    (500, EditProfileError.profileUpdateFailed)
  ])
  func editProfileMapsResponseError(status: Int, expected: EditProfileError) async {
    let client = ProfileScheduleClient(error: .response(.init(httpStatus: status)))
    let repository = makeProfileRepository(client: client)

    await #expect(throws: expected) {
      try await repository.editProfile(input: Self.editInput)
    }
  }

  @Test("프로필 수정 전송 실패를 업데이트 실패로 변환한다")
  func editProfileMapsTransportFailure() async {
    let client = ProfileScheduleClient(error: .transport(.notConnected))
    let repository = makeProfileRepository(client: client)

    await #expect(throws: EditProfileError.profileUpdateFailed) {
      try await repository.editProfile(input: Self.editInput)
    }
  }

  private func makeProfileRepository(client: ProfileScheduleClient) -> ProfileRepositoryImpl {
    withDependencies {
      $0.profileLocalDataSource = ProfileLocalDataSourceStub()
    } operation: {
      makeRepository(client: client) { ProfileRepositoryImpl() }
    }
  }

  private static let editInput = EditProfileInput(
    name: "이름",
    generationId: 12,
    jobRole: .ios,
    teamId: 1,
    managerRoles: nil,
    inviteCode: "CODE"
  )

  private static let cachedProfile = ProfileEntity(
    userID: 99,
    name: "캐시 사용자",
    generation: "12",
    team: .ios2,
    jobRole: .ios,
    role: .member,
    manger: nil
  )

  private static let profileJSON = #"""
  {
    "userId": 17,
    "name": "테스터",
    "email": "tester@example.com",
    "generation": "12",
    "team": "IOS 1팀",
    "jobRole": "IOS",
    "role": "MANAGER",
    "managerRoles": ["ATTENDANCE_CHECK", "PHOTO"]
  }
  """#
}

@Suite("ScheduleRepositoryImpl")
struct ScheduleRepositoryImplTests {
  @Test("캐시된 일정을 네트워크 호출 없이 반환한다")
  func getCachedScheduleReturnsLocalValue() async {
    let cached = [Self.cachedSchedule]
    let localDataSource = ScheduleLocalDataSourceStub(schedules: cached)
    let client = ProfileScheduleClient(error: .transport(.notConnected))
    let repository = withDependencies {
      $0.scheduleLocalDataSource = localDataSource
    } operation: {
      makeRepository(client: client) { ScheduleRepositoryImpl() }
    }

    let result = await repository.getCachedSchedule()

    #expect(result == cached)
  }

  @Test("getSchedule은 비어 있지 않은 캐시를 즉시 반환한다")
  func getScheduleReturnsCacheHit() async throws {
    let cached = [Self.cachedSchedule]
    let localDataSource = ScheduleLocalDataSourceStub(schedules: cached)
    let client = ProfileScheduleClient(error: .transport(.notConnected))
    let repository = withDependencies {
      $0.scheduleLocalDataSource = localDataSource
    } operation: {
      makeRepository(client: client) { ScheduleRepositoryImpl() }
    }

    let result = try await repository.getSchedule()

    #expect(result == cached)
  }

  @Test("일정 DTO를 날짜순 도메인 모델로 변환한다")
  func getScheduleMapsAndSortsDTO() async throws {
    let client = ProfileScheduleClient(json: #"""
    [
      {"id": 3, "name": "셋째", "desc": "3", "year": 2026, "month": 9, "day": 20},
      {"id": 1, "name": "첫째", "desc": "1", "year": 2025, "month": 12, "day": 31},
      {"id": 2, "name": "둘째", "desc": "2", "year": 2026, "month": 9, "day": 2}
    ]
    """#)
    let repository = makeScheduleRepository(client: client)

    let schedules = try await repository.getSchedule()

    #expect(schedules.map(\.id) == [1, 2, 3])
    #expect(schedules.map(\.description) == ["1", "2", "3"])
  }

  @Test("잘못된 날짜 응답을 invalidDate로 변환한다")
  func getScheduleMapsBadRequest() async {
    let client = ProfileScheduleClient(error: .response(.init(httpStatus: 400)))
    let repository = makeScheduleRepository(client: client)

    await #expect(throws: ScheduleError.invalidDate) {
      try await repository.getSchedule()
    }
  }

  @Test("일정의 기타 HTTP 오류를 loadFailed로 변환한다", arguments: [404, 500])
  func getScheduleMapsOtherResponse(status: Int) async {
    let client = ProfileScheduleClient(error: .response(.init(httpStatus: status)))
    let repository = makeScheduleRepository(client: client)

    await #expect(throws: ScheduleError.loadFailed) {
      try await repository.getSchedule()
    }
  }

  @Test("일정 전송 실패를 loadFailed로 변환한다")
  func getScheduleMapsTransportFailure() async {
    let client = ProfileScheduleClient(error: .transport(.timedOut))
    let repository = makeScheduleRepository(client: client)

    await #expect(throws: ScheduleError.loadFailed) {
      try await repository.getSchedule()
    }
  }

  @Test("일정 디코딩 실패를 loadFailed로 변환한다")
  func getScheduleMapsDecodingFailure() async {
    let client = ProfileScheduleClient(json: #"{"data":"invalid"}"#)
    let repository = makeScheduleRepository(client: client)

    await #expect(throws: ScheduleError.loadFailed) {
      try await repository.getSchedule()
    }
  }

  private func makeScheduleRepository(client: ProfileScheduleClient) -> ScheduleRepositoryImpl {
    withDependencies {
      $0.scheduleLocalDataSource = ScheduleLocalDataSourceStub()
    } operation: {
      makeRepository(client: client) { ScheduleRepositoryImpl() }
    }
  }

  private static let cachedSchedule = Schedule(
    id: 91,
    name: "캐시 일정",
    description: "저장된 일정",
    month: 9,
    day: 2,
    year: 2026
  )
}

private actor ProfileLocalDataSourceStub: ProfileLocalDataSourceProtocol {
  private var profile: ProfileEntity?

  init(profile: ProfileEntity? = nil) {
    self.profile = profile
  }

  func loadUser() async throws(ProfileError) -> ProfileEntity? { profile }
  func saveUser(_ profile: ProfileEntity) async throws(ProfileError) { self.profile = profile }
  func clear() async throws(ProfileError) { profile = nil }
}

private actor ScheduleLocalDataSourceStub: ScheduleLocalDataSourceProtocol {
  private var schedules: [Schedule]?

  init(schedules: [Schedule]? = nil) {
    self.schedules = schedules
  }

  func loadAll() async throws(ScheduleError) -> [Schedule]? { schedules }
  func saveAll(_ schedules: [Schedule]) async throws(ScheduleError) { self.schedules = schedules }
  func clear() async throws(ScheduleError) { schedules = nil }
}

private actor ProfileScheduleClient: DDDNetworkClient {
  private let result: Result<DDDHTTPResponse, DDDNetworkError>
  private(set) var lastEditProfileBody: CapturedEditProfileBody?

  init(json: String) {
    result = .success(.init(statusCode: 200, data: Data(json.utf8)))
  }

  init(error: DDDNetworkError) {
    result = .failure(error)
  }

  func send<R: DDDDataRequest, T: Decodable & Sendable>(
    _ request: R,
    as _: T.Type
  ) async throws(DDDNetworkError) -> T {
    if request.method == .put,
       let parameters = request.parameters,
       let data = try? JSONEncoder().encode(parameters) {
      lastEditProfileBody = try? JSONDecoder().decode(CapturedEditProfileBody.self, from: data)
    }

    let response = try result.get()
    do {
      return try JSONDecoder().decode(T.self, from: response.data)
    } catch {
      throw .decoding(.failed(error))
    }
  }

  func send<R: DDDDataRequest>(_ request: R) async throws(DDDNetworkError) -> R.Response {
    try await send(request, as: R.Response.self)
  }

  func sendResponse<R: DDDDataRequest>(_: R) async throws(DDDNetworkError) -> DDDHTTPResponse {
    try result.get()
  }

  func upload<R: DDDUploadRequest>(_: R) async throws(DDDNetworkError) -> R.Response {
    fatalError("이 테스트에서는 multipart upload를 사용하지 않습니다")
  }

  func upload(_: some DDDFileUploadRequest) async throws(DDDNetworkError) {
    fatalError("이 테스트에서는 file upload를 사용하지 않습니다")
  }
}

private struct CapturedEditProfileBody: Decodable, Sendable {
  let name: String
  let generationId: Int
  let jobRole: String
  let teamId: Int?
  let managerRoles: [String]?
  let invitationCode: String
}
