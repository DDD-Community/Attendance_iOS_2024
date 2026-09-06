//
//  WebReducerStateActionTests.swift
//  WebTests
//
//  WebFeature 의 State 초기화/동등성과 Action(WebDelegate 별칭) 처리 경로를 커버한다.
//  기존 WebReducerTests / WebTests 와 겹치지 않는 경계값·반복 시나리오만 다룬다.
//

import ComposableArchitecture
import Testing

@testable import Web

@MainActor
@Suite("WebFeature 상태와 액션")
struct WebReducerStateActionTests {
  // MARK: - State 초기화 (정상 / 경계값)

  @Test(
    "State 는 어떤 문자열이든 url 로 그대로 보관한다",
    arguments: [
      "https://dddstudy.kr",
      "https://dddstudy.kr/terms?version=2#anchor",
      "http://example.com",
      "about:blank",
      "",
      " ",
      "그냥 문자열"
    ]
  )
  func state_withVariousURLs_keepsRawValue(url: String) {
    // Given / When
    let state = WebFeature.State(url: url)

    // Then
    #expect(state.url == url)
  }

  @Test("빈 문자열로 초기화하면 url 은 빈 문자열이다")
  func state_withEmptyString_hasEmptyURL() {
    // Given / When
    let state = WebFeature.State(url: "")

    // Then
    #expect(state.url.isEmpty)
  }

  @Test("아주 긴 URL 도 손실 없이 보관한다")
  func state_withVeryLongURL_keepsFullValue() {
    // Given
    let longURL = "https://dddstudy.kr/?q=" + String(repeating: "a", count: 4096)

    // When
    let state = WebFeature.State(url: longURL)

    // Then
    #expect(state.url == longURL)
    #expect(state.url.count == longURL.count)
  }

  // MARK: - State 동등성

  @Test("같은 url 을 가진 State 는 서로 같다")
  func state_withSameURL_isEqual() {
    // Given
    let lhs = WebFeature.State(url: "https://dddstudy.kr")
    let rhs = WebFeature.State(url: "https://dddstudy.kr")

    // Then
    #expect(lhs == rhs)
  }

  @Test("다른 url 을 가진 State 는 서로 다르다")
  func state_withDifferentURL_isNotEqual() {
    // Given
    let lhs = WebFeature.State(url: "https://dddstudy.kr")
    let rhs = WebFeature.State(url: "https://dddstudy.kr/privacy")

    // Then
    #expect(lhs != rhs)
  }

  // MARK: - Action

  @Test("Action 은 WebDelegate 별칭이라 backToRoot 끼리 동등하다")
  func action_backToRoot_isEqualToItself() {
    // Given
    let lhs: WebFeature.Action = .backToRoot
    let rhs: WebFeature.Action = .backToRoot

    // Then
    #expect(lhs == rhs)
  }

  @Test("reduce 를 직접 호출해도 backToRoot 는 State 를 바꾸지 않는다")
  func reduce_backToRoot_keepsState() {
    // Given
    var state = WebFeature.State(url: "https://dddstudy.kr/privacy")

    // When
    _ = WebFeature().reduce(into: &state, action: .backToRoot)

    // Then
    #expect(state.url == "https://dddstudy.kr/privacy")
  }

  @Test("backToRoot 를 연속으로 보내도 State 는 변하지 않는다")
  func store_sendingBackToRootRepeatedly_keepsState() async {
    // Given
    let store = TestStore(initialState: WebFeature.State(url: "https://dddstudy.kr/terms")) {
      WebFeature()
    }

    // When
    await store.send(.backToRoot)
    await store.send(.backToRoot)
    await store.send(.backToRoot)

    // Then
    #expect(store.state.url == "https://dddstudy.kr/terms")
  }

  @Test("빈 url 상태에서 backToRoot 를 보내도 State 는 변하지 않는다")
  func store_sendingBackToRootWithEmptyURL_keepsState() async {
    // Given
    let store = TestStore(initialState: WebFeature.State(url: "")) {
      WebFeature()
    }

    // When
    await store.send(.backToRoot)

    // Then
    #expect(store.state.url.isEmpty)
  }

  @Test("일반 Store 로도 backToRoot 액션이 안전하게 처리된다")
  func liveStore_sendingBackToRoot_keepsState() {
    // Given
    let store = Store(initialState: WebFeature.State(url: "https://dddstudy.kr")) {
      WebFeature()
    }

    // When
    store.send(.backToRoot)

    // Then
    #expect(store.url == "https://dddstudy.kr")
  }

  @Test("WebFeature 는 인자 없이 생성할 수 있다")
  func init_defaultInitializer_buildsReducer() {
    // Given / When
    var state = WebFeature.State(url: "https://dddstudy.kr")

    // Then
    _ = WebFeature().reduce(into: &state, action: .backToRoot)
    #expect(state.url == "https://dddstudy.kr")
  }
}
