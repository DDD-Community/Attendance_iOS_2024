//
//  SharedValueStorage.swift
//  DDDStorageInterface
//
//  Created by DDD on 9/4/26.
//

import Dependencies
import Foundation

public struct SharedValueStorageIdentifier: Hashable, Sendable {
  private let rawValue: UUID

  public init() {
    self.rawValue = UUID()
  }
}

/// `@Shared` 값의 직렬화 결과를 보관하는 저장소 경계입니다.
///
/// 도메인은 SQLite 구현을 알지 않고 이 계약만 사용합니다.
public protocol SharedValueStorage: Sendable {
  var identifier: SharedValueStorageIdentifier { get }

  func load(forKey key: String) throws -> Data?
  func save(_ data: Data, forKey key: String) throws
  func remove(forKey key: String) throws
}

public enum SharedValueStorageDependency: TestDependencyKey {
  public static let testValue: any SharedValueStorage = UnimplementedSharedValueStorage()
}

public extension DependencyValues {
  var sharedValueStorage: any SharedValueStorage {
    get { self[SharedValueStorageDependency.self] }
    set { self[SharedValueStorageDependency.self] = newValue }
  }
}

private struct UnimplementedSharedValueStorage: SharedValueStorage {
  let identifier = SharedValueStorageIdentifier()

  func load(forKey key: String) throws -> Data? {
    throw SharedValueStorageUnavailableError(key: key)
  }

  func save(_ data: Data, forKey key: String) throws {
    throw SharedValueStorageUnavailableError(key: key)
  }

  func remove(forKey key: String) throws {
    throw SharedValueStorageUnavailableError(key: key)
  }
}

private struct SharedValueStorageUnavailableError: Error {
  let key: String
}
