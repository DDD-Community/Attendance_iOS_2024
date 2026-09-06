//
//  SQLiteSharedValueStorageTests.swift
//  DDDStorageTests
//
//  Created by DDD on 9/4/26.
//

import Foundation
import Testing

@testable import DDDStorage

import SQLiteData

@Suite("SQLiteSharedValueStorage")
struct SQLiteSharedValueStorageTests {
  @Test
  func 저장_조회_덮어쓰기_삭제를_지원한다() throws {
    let database = try DatabaseQueue()
    try AppDatabaseMigrator.migrate(database)
    let storage = SQLiteSharedValueStorage(database: database)

    try storage.save(Data("first".utf8), forKey: "session")
    #expect(try storage.load(forKey: "session") == Data("first".utf8))

    try storage.save(Data("second".utf8), forKey: "session")
    #expect(try storage.load(forKey: "session") == Data("second".utf8))

    try storage.remove(forKey: "session")
    #expect(try storage.load(forKey: "session") == nil)
  }

  @Test
  func 마이그레이션은_여러번_실행해도_안전하다() throws {
    let database = try DatabaseQueue()

    try AppDatabaseMigrator.migrate(database)
    try AppDatabaseMigrator.migrate(database)

    let storage = SQLiteSharedValueStorage(database: database)
    try storage.save(Data("value".utf8), forKey: "key")
    #expect(try storage.load(forKey: "key") == Data("value".utf8))
  }
}
