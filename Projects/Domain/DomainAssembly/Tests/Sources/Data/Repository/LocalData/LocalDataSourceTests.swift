//
//  LocalDataSourceTests.swift
//  DomainAssemblyTests
//
//  Created by DDD on 9/4/26.
//

import Foundation
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

import SQLiteData

@Suite("Repository local cache", .serialized)
struct LocalDataSourceTests {
  @Test("프로필 캐시는 초기 조회, 저장, 교체, 삭제를 지원한다")
  func profileCacheLifecycle() async throws {
    let database = try makeDatabase()
    let source = ProfileLocalDataSource(database: database)

    #expect(try await source.loadUser() == nil)

    let original = makeProfile(userID: 1, name: "첫 번째 사용자")
    try await source.saveUser(original)
    #expect(try await source.loadUser() == original)

    let replacement = makeProfile(
      userID: 2,
      name: "교체된 사용자",
      team: nil,
      managerRoles: nil
    )
    try await source.saveUser(replacement)
    #expect(try await source.loadUser() == replacement)
    #expect(try profileCacheCount(in: database) == 1)

    try await source.clear()
    #expect(try await source.loadUser() == nil)
    #expect(try profileCacheCount(in: database) == 0)
  }

  @Test("만료된 프로필 캐시는 조회 시 제거한다")
  func expiredProfileCacheIsRemoved() async throws {
    let database = try makeDatabase()
    let source = ProfileLocalDataSource(database: database)
    try await source.saveUser(
      makeProfile(userID: 10, name: "만료된 사용자")
    )
    try await database.write { db in
      try ProfileCacheRecord
        .update { $0.cachedAt = #bind(yesterday) }
        .execute(db)
    }

    #expect(try await source.loadUser() == nil)
    #expect(try profileCacheCount(in: database) == 0)
  }

  @Test("프로필 캐시 변환은 잘못된 enum 값을 기본값으로 복구한다")
  func profileCacheConversionFallbacks() {
    let cache = ProfileCacheRecord(
      cacheKey: ProfileCacheKey.user,
      cachedAt: .now,
      userID: 20,
      name: "복구 사용자",
      generation: "12기",
      teamRawValue: "존재하지 않는 팀",
      jobRoleRawValue: "존재하지 않는 파트",
      roleRawValue: "존재하지 않는 역할",
      managerRolesData: try? JSONEncoder().encode([
        StaffManaging.photo.rawValue, "존재하지 않는 운영진 역할"
      ])
    )

    let profile = cache.toDomain()

    #expect(profile.team == nil)
    #expect(profile.jobRole == .all)
    #expect(profile.role == .member)
    #expect(profile.manger == [.photo])
    #expect(cache.isExpired == false)
  }

  @Test("일정 캐시는 날짜순 조회, 교체, 삭제를 지원한다")
  func scheduleCacheLifecycle() async throws {
    let database = try makeDatabase()
    let source = ScheduleLocalDataSource(database: database)

    #expect(try await source.loadAll() == nil)

    let unordered = [
      makeSchedule(id: 3, month: 5, day: 2, year: 2027),
      makeSchedule(id: 1, month: 12, day: 31, year: 2026),
      makeSchedule(id: 2, month: 1, day: 1, year: 2027)
    ]
    try await source.saveAll(unordered)

    let loaded = try #require(try await source.loadAll())
    #expect(loaded.map(\.id) == [1, 2, 3])

    let replacement = makeSchedule(id: 4, month: 9, day: 1, year: 2028)
    try await source.saveAll([replacement])
    #expect(try await source.loadAll() == [replacement])
    #expect(try scheduleCacheCount(in: database) == 1)

    try await source.clear()
    #expect(try await source.loadAll() == nil)
    #expect(try scheduleCacheCount(in: database) == 0)
  }

  @Test("빈 일정 저장은 기존 캐시를 제거한다")
  func savingEmptySchedulesClearsCache() async throws {
    let database = try makeDatabase()
    let source = ScheduleLocalDataSource(database: database)

    try await source.saveAll([makeSchedule()])
    try await source.saveAll([])

    #expect(try await source.loadAll() == nil)
    #expect(try scheduleCacheCount(in: database) == 0)
  }

  @Test("하나라도 만료된 일정이 있으면 전체 캐시를 제거한다")
  func expiredScheduleInvalidatesWholeCache() async throws {
    let database = try makeDatabase()
    let source = ScheduleLocalDataSource(database: database)
    try await source.saveAll([makeSchedule(id: 1), makeSchedule(id: 2)])
    try await database.write { db in
      try ScheduleCacheRecord.find(2)
        .update { $0.cachedAt = #bind(yesterday) }
        .execute(db)
    }

    #expect(try await source.loadAll() == nil)
    #expect(try scheduleCacheCount(in: database) == 0)
  }

  @Test("일정 캐시 모델은 모든 값을 도메인 모델로 보존한다")
  func scheduleCacheConversion() {
    let schedule = makeSchedule(
      id: 42,
      name: "정기 모임",
      description: "오프라인 세션",
      month: 10,
      day: 17,
      year: 2027
    )
    let cache = schedule.toCacheRecord()

    #expect(cache.toDomain() == schedule)
    #expect(cache.isExpired == false)
  }

}

private extension LocalDataSourceTests {
  var yesterday: Date {
    Calendar.current.date(byAdding: .day, value: -1, to: .now)!
  }

  func makeDatabase() throws -> DatabaseQueue {
    let database = try DatabaseQueue()
    try AppDatabaseMigrator.migrate(database)
    return database
  }

  func profileCacheCount(in database: any DatabaseReader) throws -> Int {
    try database.read { db in
      try ProfileCacheRecord.count().fetchOne(db) ?? 0
    }
  }

  func scheduleCacheCount(in database: any DatabaseReader) throws -> Int {
    try database.read { db in
      try ScheduleCacheRecord.count().fetchOne(db) ?? 0
    }
  }

  func makeProfile(
    userID: Int = 1,
    name: String = "테스트 사용자",
    team: SelectTeams? = .ios1,
    managerRoles: [StaffManaging]? = [.teamManaging, .attendanceCheck]
  ) -> ProfileEntity {
    ProfileEntity(
      userID: userID,
      name: name,
      generation: "12기",
      team: team,
      jobRole: .ios,
      role: .manager,
      manger: managerRoles
    )
  }

  func makeSchedule(
    id: Int = 1,
    name: String = "테스트 일정",
    description: String = "테스트 설명",
    month: Int = 8,
    day: Int = 20,
    year: Int = 2027
  ) -> Schedule {
    Schedule(
      id: id,
      name: name,
      description: description,
      month: month,
      day: day,
      year: year
    )
  }
}
