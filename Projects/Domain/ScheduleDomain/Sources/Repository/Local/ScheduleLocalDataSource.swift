//
//  ScheduleLocalDataSource.swift
//  ScheduleDomain
//
//  Created by DDD on 5/12/26.
//

import Foundation
import DDDStorageInterface
import Dependencies
import SQLiteData

public protocol ScheduleLocalDataSourceProtocol: Actor {
  func loadAll() async throws(ScheduleError) -> [Schedule]?
  func saveAll(_ schedules: [Schedule]) async throws(ScheduleError)
  func clear() async throws(ScheduleError)
}

public actor ScheduleLocalDataSource: ScheduleLocalDataSourceProtocol {
  private let database: any DatabaseWriter

  public init(database: any DatabaseWriter) {
    self.database = database
  }

  public func loadAll() async throws(ScheduleError) -> [Schedule]? {
    do {
      let cached = try await database.read { db in
        try ScheduleCacheRecord
          .order { ($0.year, $0.month, $0.day) }
          .fetchAll(db)
      }
      guard !cached.isEmpty else { return nil }

      if cached.contains(where: { $0.isExpired }) {
        try await clear()
        return nil
      }
      return cached.map { $0.toDomain() }
    } catch {
      throw .cacheFailed
    }
  }

  public func saveAll(_ schedules: [Schedule]) async throws(ScheduleError) {
    do {
      let now = Date()
      let records = schedules.map { $0.toCacheRecord(cachedAt: now) }
      try await database.write { db in
        try ScheduleCacheRecord.delete().execute(db)
        try ScheduleCacheRecord.insert { records }.execute(db)
      }
    } catch {
      throw .cacheFailed
    }
  }

  public func clear() async throws(ScheduleError) {
    do {
      try await database.write { db in
        try ScheduleCacheRecord.delete().execute(db)
      }
    } catch {
      throw .cacheFailed
    }
  }
}

/// ScheduleLocalDataSource의 DependencyKey 구조체
public enum ScheduleLocalDataSourceDependency: DependencyKey {
  public static var liveValue: ScheduleLocalDataSourceProtocol {
    @Dependency(\.appDatabase) var database
    guard let database else {
      return InMemoryScheduleLocalDataSource()
    }
    return ScheduleLocalDataSource(database: database)
  }

  public static var testValue: ScheduleLocalDataSourceProtocol = InMemoryScheduleLocalDataSource()

  public static var previewValue: ScheduleLocalDataSourceProtocol = testValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var scheduleLocalDataSource: ScheduleLocalDataSourceProtocol {
    get { self[ScheduleLocalDataSourceDependency.self] }
    set { self[ScheduleLocalDataSourceDependency.self] = newValue }
  }
}

private actor InMemoryScheduleLocalDataSource: ScheduleLocalDataSourceProtocol {
  private var schedules: [Schedule]?

  func loadAll() async throws(ScheduleError) -> [Schedule]? { schedules }
  func saveAll(_ schedules: [Schedule]) async throws(ScheduleError) {
    self.schedules = schedules.isEmpty ? nil : schedules
  }
  func clear() async throws(ScheduleError) { schedules = nil }
}
