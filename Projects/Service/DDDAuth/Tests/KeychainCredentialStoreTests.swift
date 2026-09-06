//
//  KeychainCredentialStoreTests.swift
//  DDDAuthTests
//
//  Created by DDD on 9/1/26.
//

import Foundation
import Testing

@testable import DDDAuth
import DDDNetworkInterface
import DDDStorageInterface

struct KeychainCredentialStoreTests {
  @Test
  func secureStorage의_토큰쌍을_credential로_읽는다() throws {
    let storage = FakeSecureStorage(values: [
      .accessToken: "access",
      .refreshToken: "refresh"
    ])

    let credential = try #require(KeychainCredentialStore(storage: storage).load())

    #expect(credential.accessToken == "access")
    #expect(credential.refreshToken == "refresh")
  }

  @Test
  func 토큰_한쪽이_없으면_로그아웃_상태로_판단한다() {
    let storage = FakeSecureStorage(values: [.accessToken: "access"])

    #expect(KeychainCredentialStore(storage: storage).load() == nil)
  }

  /// UseCase 계층에 있던 토큰 저장 검증을 실제 책임 계층으로 옮긴 것이다.
  @Test
  func save는_토큰쌍을_각각의_보안키로_저장한다() {
    let storage = FakeSecureStorage(values: [:])
    let sut = KeychainCredentialStore(storage: storage)

    sut.save(DDDCredential(accessToken: "access", refreshToken: "refresh", expiresAt: nil))

    #expect(storage.values[.accessToken] == "access")
    #expect(storage.values[.refreshToken] == "refresh")
  }

  @Test
  func clear는_인증토큰을_모두_삭제한다() {
    let storage = FakeSecureStorage(values: [
      .accessToken: "access",
      .refreshToken: "refresh"
    ])
    let sut = KeychainCredentialStore(storage: storage)

    sut.clear()

    #expect(storage.values.isEmpty)
  }
}
