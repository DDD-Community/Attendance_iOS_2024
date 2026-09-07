//
//  DDDAuthTests.swift
//  DDDAuthTests
//
//  Created by DDD on 9/1/26.
//

import Testing

@testable import DDDAuth
import DDDNetworkInterface

struct DDDAuthTests {
  @Test
  func 로그인하면_토큰을_저장하고_인증세션을_갱신한다() async throws {
    let base = InMemoryCredentialStore()
    let store = GuardedCredentialStore(base: base)
    let updater = SpyCredentialUpdater()
    let sut = DDDAuth(
      authenticatedClient: UnusedNetworkClient(),
      store: store,
      credentials: updater
    )

    await sut.signIn(accessToken: "access", refreshToken: "refresh")

    let credential = try #require(base.credential)
    #expect(credential.accessToken == "access")
    #expect(credential.refreshToken == "refresh")
    #expect(updater.updates.last! == credential)
    #expect(await sut.isLoggedIn)
  }

  @Test
  func 로그아웃하면_저장토큰과_인증세션을_모두_비운다() async {
    let existing = DDDCredential(accessToken: "access", refreshToken: "refresh")
    let base = InMemoryCredentialStore(credential: existing)
    let store = GuardedCredentialStore(base: base)
    let updater = SpyCredentialUpdater()
    let sut = DDDAuth(
      authenticatedClient: UnusedNetworkClient(),
      store: store,
      credentials: updater
    )

    await sut.signOut()

    #expect(base.credential == nil)
    #expect(updater.updates.count == 1)
    #expect(updater.updates[0] == nil)
    #expect(await sut.isLoggedIn == false)
  }

  @Test
  func 로그아웃_이후_늦게_도착한_refresh_저장은_무시한다() {
    let base = InMemoryCredentialStore(
      credential: DDDCredential(accessToken: "old", refreshToken: "old-refresh")
    )
    let store = GuardedCredentialStore(base: base)

    store.clear()
    store.save(DDDCredential(accessToken: "late", refreshToken: "late-refresh"))

    #expect(base.credential == nil)
  }
}
