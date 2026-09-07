//
//  KeychainStorageTests.swift
//  DDDStorageTests
//
//  Created by DDD on 9/2/26.
//

import Foundation
import Security
import Testing

@testable import DDDStorage

@Suite("KeychainStorage", .serialized)
struct KeychainStorageTests {
  @Test
  func 기존_앱의_Keychain_service_식별자를_유지한다() {
    #expect(KeychainStorage.defaultService == "io.dddstudy.attendance")
  }

  @Test
  func 저장한_값을_같은_키로_조회한다() throws {
    let storage = makeStorage()
    defer { try? storage.removeAll() }

    try storage.save("access-token", for: .accessToken)

    #expect(try storage.load(.accessToken) == "access-token")
  }

  @Test
  func 같은_키에_다시_저장하면_기존_값을_덮어쓴다() throws {
    let storage = makeStorage()
    defer { try? storage.removeAll() }

    try storage.save("old-token", for: .accessToken)
    try storage.save("new-token", for: .accessToken)

    #expect(try storage.load(.accessToken) == "new-token")
  }

  @Test
  func 서로_다른_키의_값을_독립적으로_보관한다() throws {
    let storage = makeStorage()
    defer { try? storage.removeAll() }

    try storage.save("access-token", for: .accessToken)
    try storage.save("refresh-token", for: .refreshToken)

    #expect(try storage.load(.accessToken) == "access-token")
    #expect(try storage.load(.refreshToken) == "refresh-token")
  }

  @Test
  func 빈_문자열도_손실없이_저장한다() throws {
    let storage = makeStorage()
    defer { try? storage.removeAll() }

    try storage.save("", for: .accessToken)

    #expect(try storage.load(.accessToken) == "")
  }

  @Test
  func 단건_삭제는_다른_키에_영향을_주지_않는다() throws {
    let storage = makeStorage()
    defer { try? storage.removeAll() }

    try storage.save("access-token", for: .accessToken)
    try storage.save("refresh-token", for: .refreshToken)
    try storage.remove(.accessToken)

    #expect(try storage.load(.accessToken) == nil)
    #expect(try storage.load(.refreshToken) == "refresh-token")
  }

  @Test
  func 존재하지_않는_키를_삭제해도_성공한다() throws {
    let storage = makeStorage()

    try storage.remove(.accessToken)

    #expect(try storage.load(.accessToken) == nil)
  }

  @Test
  func 전체_삭제는_등록된_모든_토큰을_제거한다() throws {
    let storage = makeStorage()

    try storage.save("access-token", for: .accessToken)
    try storage.save("refresh-token", for: .refreshToken)
    try storage.removeAll()

    #expect(try storage.load(.accessToken) == nil)
    #expect(try storage.load(.refreshToken) == nil)
  }
}

private extension KeychainStorageTests {
  func makeStorage() -> KeychainStorage {
    return KeychainStorage(
      service: "io.DDD.Attendance.tests.\(UUID().uuidString)",
      client: InMemoryKeychainClient()
    )
  }
}

private final class InMemoryKeychainClient: KeychainClient, @unchecked Sendable {
  private var values: [String: Data] = [:]

  func update(_ data: Data, service: String, account: String) -> OSStatus {
    let key = storageKey(service: service, account: account)
    guard values[key] != nil else { return errSecItemNotFound }
    values[key] = data
    return errSecSuccess
  }

  func add(_ data: Data, service: String, account: String) -> OSStatus {
    let key = storageKey(service: service, account: account)
    guard values[key] == nil else { return errSecDuplicateItem }
    values[key] = data
    return errSecSuccess
  }

  func load(service: String, account: String) -> KeychainLoadResult {
    guard let data = values[storageKey(service: service, account: account)] else {
      return KeychainLoadResult(status: errSecItemNotFound, data: nil)
    }
    return KeychainLoadResult(status: errSecSuccess, data: data)
  }

  func delete(service: String, account: String) -> OSStatus {
    let removed = values.removeValue(forKey: storageKey(service: service, account: account))
    return removed == nil ? errSecItemNotFound : errSecSuccess
  }

  private func storageKey(service: String, account: String) -> String {
    return "\(service):\(account)"
  }
}
