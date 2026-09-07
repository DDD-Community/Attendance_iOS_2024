//
//  AuthTestDoubles.swift
//  DDDAuthTests
//
//  Created by DDD on 9/1/26.
//

import Foundation

import DDDNetworkInterface
import DDDStorageInterface

final class InMemoryCredentialStore: CredentialStore, @unchecked Sendable {
  private(set) var credential: DDDCredential?

  init(credential: DDDCredential? = nil) {
    self.credential = credential
  }

  func load() -> DDDCredential? {
    return credential
  }

  func save(_ credential: DDDCredential) {
    self.credential = credential
  }

  func clear() {
    credential = nil
  }
}

final class SpyCredentialUpdater: CredentialUpdating, @unchecked Sendable {
  private(set) var updates: [DDDCredential?] = []

  func update(_ credential: DDDCredential?) {
    updates.append(credential)
  }
}

final class FakeSecureStorage: SecureStorage, @unchecked Sendable {
  var values: [SecureStorageKey: String]

  init(values: [SecureStorageKey: String] = [:]) {
    self.values = values
  }

  func save(_ value: String, for key: SecureStorageKey) throws(SecureStorageError) {
    values[key] = value
  }

  func load(_ key: SecureStorageKey) throws(SecureStorageError) -> String? {
    return values[key]
  }

  func remove(_ key: SecureStorageKey) throws(SecureStorageError) {
    values[key] = nil
  }

  func removeAll() throws(SecureStorageError) {
    values.removeAll()
  }
}

struct UnusedNetworkClient: DDDNetworkClient {
  func send<R: DDDDataRequest, T: Decodable & Sendable>(
    _: R,
    as _: T.Type
  ) async throws(DDDNetworkError) -> T {
    fatalError("이 테스트에서는 네트워크 요청을 호출하지 않습니다")
  }

  func send<R: DDDDataRequest>(_: R) async throws(DDDNetworkError) -> R.Response {
    fatalError("이 테스트에서는 네트워크 요청을 호출하지 않습니다")
  }

  func sendResponse<R: DDDDataRequest>(_: R) async throws(DDDNetworkError) -> DDDHTTPResponse {
    fatalError("이 테스트에서는 네트워크 요청을 호출하지 않습니다")
  }

  func upload<R: DDDUploadRequest>(_: R) async throws(DDDNetworkError) -> R.Response {
    fatalError("이 테스트에서는 업로드를 호출하지 않습니다")
  }

  func upload(_: some DDDFileUploadRequest) async throws(DDDNetworkError) {
    fatalError("이 테스트에서는 업로드를 호출하지 않습니다")
  }
}
