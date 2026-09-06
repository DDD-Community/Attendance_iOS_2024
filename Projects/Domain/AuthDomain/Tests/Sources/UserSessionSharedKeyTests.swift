//
//  UserSessionSharedKeyTests.swift
//  AuthDomainTests
//
//  Created by DDD on 9/4/26.
//

import Foundation
import Testing

import AuthDomainInterface
import DDDStorageInterface

import ComposableArchitecture

@Suite("UserSession Shared SQLite persistence", .serialized)
struct UserSessionSharedKeyTests {
  @Test
  func 기수_변경_세션은_SQLite에_즉시_갱신된다() throws {
    let storage = TestSharedValueStorage()

    withDependencies {
      $0.context = .live
      $0.sharedValueStorage = storage
    } operation: {
      @Shared(.userSession) var userSession
      $userSession.withLock {
        $0.generationId = 14
        $0.generation = "14기"
        $0.userRole = .manager
        $0.managing = [.teamManaging]
        $0.selectTeam = .ios2
        $0.selectTeamId = 10
        $0.inviteCode = "MANAGER-14"
      }
    }

    let data = try #require(storage.data(forKey: "UserSession"))
    let reloadedStorage = TestSharedValueStorage(values: ["UserSession": data])

    withDependencies {
      $0.context = .live
      $0.sharedValueStorage = reloadedStorage
    } operation: {
      @Shared(.userSession) var userSession
      #expect(userSession.generationId == 14)
      #expect(userSession.generation == "14기")
      #expect(userSession.userRole == .manager)
      #expect(userSession.managing == [.teamManaging])
      #expect(userSession.selectTeam == .ios2)
      #expect(userSession.selectTeamId == 10)
      #expect(userSession.inviteCode == "MANAGER-14")
    }
  }

  @Test
  func 세션_메타데이터는_저장하고_민감한_토큰은_제외한다() async throws {
    let storage = TestSharedValueStorage()

    try await withDependencies {
      $0.context = .live
      $0.sharedValueStorage = storage
    } operation: {
      @Shared(.userSession) var userSession
      $userSession.withLock {
        $0 = UserSession(
          userID: 42,
          name: "테스트 사용자",
          selectPart: .ios,
          userRole: .manager,
          managing: [.attendanceCheck],
          provider: .google,
          selectTeam: .ios1,
          selectTeamId: 7,
          token: "google-secret",
          generationId: 13,
          accessToken: "access-secret",
          oauthRefreshToken: "refresh-secret",
          inviteCode: "INVITE",
          generation: "13기"
        )
      }
      try await $userSession.save()
    }

    let data = try #require(storage.data(forKey: "UserSession"))
    let encoded = String(decoding: data, as: UTF8.self)
    #expect(!encoded.contains("google-secret"))
    #expect(!encoded.contains("access-secret"))
    #expect(!encoded.contains("refresh-secret"))

    let reloadedStorage = TestSharedValueStorage(values: ["UserSession": data])
    withDependencies {
      $0.context = .live
      $0.sharedValueStorage = reloadedStorage
    } operation: {
      @Shared(.userSession) var userSession
      #expect(userSession.userID == 42)
      #expect(userSession.name == "테스트 사용자")
      #expect(userSession.userRole == .manager)
      #expect(userSession.managing == [.attendanceCheck])
      #expect(userSession.selectTeam == .ios1)
      #expect(userSession.token.isEmpty)
      #expect(userSession.accessToken.isEmpty)
      #expect(userSession.oauthRefreshToken == nil)
    }
  }

  @Test
  func 기존_UserDefaults의_staffRole을_SQLite로_이전한다() {
    let suiteName = "UserSessionSharedKeyTests.\(UUID().uuidString)"
    let legacyStore = UserDefaults(suiteName: suiteName)!
    defer { legacyStore.removePersistentDomain(forName: suiteName) }
    legacyStore.set(Staff.manager.rawValue, forKey: "staffRole")
    let storage = TestSharedValueStorage()

    withDependencies {
      $0.context = .live
      $0.defaultAppStorage = legacyStore
      $0.sharedValueStorage = storage
    } operation: {
      @Shared(.staffRole) var staffRole
      #expect(staffRole == .manager)
    }

    #expect(storage.data(forKey: "staffRole") != nil)
  }
}

private final class TestSharedValueStorage: SharedValueStorage, @unchecked Sendable {
  let identifier = SharedValueStorageIdentifier()
  private let lock = NSLock()
  private var values: [String: Data]

  init(values: [String: Data] = [:]) {
    self.values = values
  }

  func load(forKey key: String) throws -> Data? {
    return data(forKey: key)
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

  func data(forKey key: String) -> Data? {
    return lock.withLock { values[key] }
  }
}
