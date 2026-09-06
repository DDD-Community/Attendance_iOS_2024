//
//  ProfileLocalDataSource.swift
//  ProfileDomain
//
//  Created by DDD on 5/12/26.
//

import Foundation
import ProfileDomainInterface
import DDDStorageInterface
import Dependencies
import SQLiteData

public protocol ProfileLocalDataSourceProtocol: Actor {
  func loadUser() async throws(ProfileError) -> ProfileEntity?
  func saveUser(_ profile: ProfileEntity) async throws(ProfileError)
  func clear() async throws(ProfileError)
}

public actor ProfileLocalDataSource: ProfileLocalDataSourceProtocol {
  private let database: any DatabaseWriter

  public init(database: any DatabaseWriter) {
    self.database = database
  }

  public func loadUser() async throws(ProfileError) -> ProfileEntity? {
    do {
      guard let cache = try await database.read({ db in
        try ProfileCacheRecord.find(ProfileCacheKey.user).fetchOne(db)
      }) else {
        return nil
      }
      if cache.isExpired {
        try await clear()
        return nil
      }
      return cache.toDomain()
    } catch {
      throw .cacheFailed
    }
  }

  public func saveUser(_ profile: ProfileEntity) async throws(ProfileError) {
    do {
      let record = try profile.toCacheRecord(cacheKey: ProfileCacheKey.user)
      try await database.write { db in
        try ProfileCacheRecord.delete().execute(db)
        try ProfileCacheRecord.insert { record }.execute(db)
      }
    } catch {
      throw .cacheFailed
    }
  }

  public func clear() async throws(ProfileError) {
    do {
      try await database.write { db in
        try ProfileCacheRecord.delete().execute(db)
      }
    } catch {
      throw .cacheFailed
    }
  }
}

/// ProfileLocalDataSource의 DependencyKey 구조체
public enum ProfileLocalDataSourceDependency: DependencyKey {
  public static var liveValue: ProfileLocalDataSourceProtocol {
    @Dependency(\.appDatabase) var database
    guard let database else {
      return InMemoryProfileLocalDataSource()
    }
    return ProfileLocalDataSource(database: database)
  }

  public static var testValue: ProfileLocalDataSourceProtocol = InMemoryProfileLocalDataSource()

  public static var previewValue: ProfileLocalDataSourceProtocol = testValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var profileLocalDataSource: ProfileLocalDataSourceProtocol {
    get { self[ProfileLocalDataSourceDependency.self] }
    set { self[ProfileLocalDataSourceDependency.self] = newValue }
  }
}

private actor InMemoryProfileLocalDataSource: ProfileLocalDataSourceProtocol {
  private var profile: ProfileEntity?

  func loadUser() async throws(ProfileError) -> ProfileEntity? { profile }
  func saveUser(_ profile: ProfileEntity) async throws(ProfileError) { self.profile = profile }
  func clear() async throws(ProfileError) { profile = nil }
}
