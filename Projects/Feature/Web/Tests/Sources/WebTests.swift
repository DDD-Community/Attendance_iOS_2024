//
//  WebTests.swift
//  WebTests
//
//  Created by DDD on 9/1/26.
//

import ComposableArchitecture
import Testing

@testable import Web

@MainActor
@Suite("Web")
struct WebTests {
  @Test("State 는 주입한 url 을 그대로 보관한다")
  func stateKeepsInjectedURL() {
    let state = WebFeature.State(url: "https://example.com")
    #expect(state.url == "https://example.com")
  }

  @Test("backToRoot 액션은 웹 URL 상태를 변경하지 않는다")
  func backToRootDoesNotMutateURL() async {
    let store = TestStore(initialState: WebFeature.State(url: "https://example.com/privacy")) {
      WebFeature()
    }

    await store.send(.backToRoot)
  }
}
