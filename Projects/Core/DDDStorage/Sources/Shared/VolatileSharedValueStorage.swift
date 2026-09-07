//
//  VolatileSharedValueStorage.swift
//  DDDStorage
//
//  Created by DDD on 9/4/26.
//

import Foundation

import DDDStorageInterface

/// SQLite 초기화에 실패한 실행에서 앱 동작을 유지하기 위한 비영속 fallback입니다.
final class VolatileSharedValueStorage: SharedValueStorage, @unchecked Sendable {
  let identifier = SharedValueStorageIdentifier()
  private let lock = NSLock()
  private var values: [String: Data] = [:]

  func load(forKey key: String) throws -> Data? {
    return lock.withLock { values[key] }
  }

  func save(_ data: Data, forKey key: String) throws {
    lock.withLock {
      values[key] = data
    }
  }

  func remove(forKey key: String) throws {
    lock.withLock {
      values[key] = nil
    }
  }
}
