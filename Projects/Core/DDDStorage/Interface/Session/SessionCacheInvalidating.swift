//
//  SessionCacheInvalidating.swift
//  DDDStorageInterface
//
//  Created by DDD on 9/4/26.
//

import Dependencies

public protocol SessionCacheInvalidating: Sendable {
  func invalidate() async
}

public struct NoopSessionCacheInvalidator: SessionCacheInvalidating {
  public init() {}

  public func invalidate() async {}
}

public enum SessionCacheInvalidatorDependency: TestDependencyKey {
  public static let testValue: any SessionCacheInvalidating = NoopSessionCacheInvalidator()
  public static let previewValue: any SessionCacheInvalidating = NoopSessionCacheInvalidator()
}

public extension DependencyValues {
  var sessionCacheInvalidator: any SessionCacheInvalidating {
    get { self[SessionCacheInvalidatorDependency.self] }
    set { self[SessionCacheInvalidatorDependency.self] = newValue }
  }
}
