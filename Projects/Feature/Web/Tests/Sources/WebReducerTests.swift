//
//  WebReducerTests.swift
//  WebTests
//
//  Created by DDD on 2026-09-02.
//

import ComposableArchitecture
import Testing

@testable import Web

@MainActor
@Suite("WebFeature")
struct WebReducerTests {
  @Test("초기화 때 전달한 URL을 State에 보관한다")
  func initStoresURL() {
    let state = WebFeature.State(url: "https://dddstudy.kr/privacy")

    #expect(state.url == "https://dddstudy.kr/privacy")
  }

  @Test("backToRoot 액션은 웹 상태를 변경하지 않는다")
  func backToRootDoesNotMutateState() async {
    let store = TestStore(initialState: WebFeature.State(url: "https://dddstudy.kr")) {
      WebFeature()
    }

    await store.send(.backToRoot)
  }
}
