//
//  StorageFactoryTests.swift
//  DDDStorageTests
//
//  Created by DDD on 9/1/26.
//

import DDDStorageInterface
import SQLiteData
import Testing
@testable import DDDStorage

@Suite("StorageFactory")
struct StorageFactoryTests {
  private enum PreparationError: Error {
    case failed
  }

  @Test
  func secureStorage를_생성한다() {
    let storage: any SecureStorage = StorageFactory.secureStorage

    #expect(String(describing: type(of: storage)) == "KeychainStorage")
  }

  @Test("기본 데이터베이스 생성 실패 시 마이그레이션을 마친 메모리 데이터베이스를 사용한다")
  func databasePreparationFallsBackToMigratedMemoryDatabase() throws {
    var fallbackCount = 0
    var migrationCount = 0

    let database = StorageFactory.prepareDatabase(
      primary: { throw PreparationError.failed },
      fallback: {
        fallbackCount += 1
        return try DatabaseQueue()
      },
      migrate: { _ in migrationCount += 1 }
    )

    #expect(database != nil)
    #expect(fallbackCount == 1)
    #expect(migrationCount == 1)
  }

  @Test("기본 데이터베이스 마이그레이션 실패 시 해당 데이터베이스를 노출하지 않는다")
  func databasePreparationDoesNotExposeUnmigratedPrimaryDatabase() throws {
    var migrationCount = 0
    let primary = try DatabaseQueue()
    let fallback = try DatabaseQueue()

    let database = StorageFactory.prepareDatabase(
      primary: { primary },
      fallback: { fallback },
      migrate: { database in
        migrationCount += 1
        if migrationCount == 1 {
          throw PreparationError.failed
        }
        try AppDatabaseMigrator.migrate(database)
      }
    )

    #expect(database != nil)
    #expect(migrationCount == 2)
  }

  @Test("기본 저장소와 메모리 저장소가 모두 실패해도 강제 종료하지 않는다")
  func databasePreparationReturnsNilWhenEveryAttemptFails() {
    let database = StorageFactory.prepareDatabase(
      primary: { throw PreparationError.failed },
      fallback: { throw PreparationError.failed },
      migrate: { _ in }
    )

    #expect(database == nil)
  }
}

@Suite("SecureStorageKey")
struct SecureStorageKeyTests {
  @Test
  func 기존_토큰_키_문자열을_유지한다() {
    #expect(SecureStorageKey.accessToken.rawValue == "ACCESS_TOKEN")
    #expect(SecureStorageKey.refreshToken.rawValue == "REFRESH_TOKEN")
  }

  @Test
  func 전체_삭제_대상에는_모든_토큰_키가_한번씩_포함된다() {
    #expect(Set(SecureStorageKey.all) == [.accessToken, .refreshToken])
    #expect(SecureStorageKey.all.count == 2)
  }
}
