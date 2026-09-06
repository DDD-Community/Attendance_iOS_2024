//
//  WebViewBodyRenderTests.swift
//  WebTests
//
//  WebView 의 body(ZStack / VStack / CustomNavigationBackBar / WebRepresentableView)를
//  실제로 평가시켜 화면 구성 경로를 커버한다.
//

import ComposableArchitecture
import SwiftUI
import Testing
import UIKit

@testable import Web

@MainActor
@Suite("WebView body 렌더링")
struct WebViewBodyRenderTests {
  private func makeStore(url: String) -> StoreOf<WebFeature> {
    Store(initialState: WebFeature.State(url: url)) {
      WebFeature()
    }
  }

  @Test("정상 URL 스토어로 WebView 를 렌더링하면 body 가 평가된다")
  func body_withValidURL_rendersWithoutCrash() {
    // Given
    let store = makeStore(url: "https://dddstudy.kr/privacy")

    // When / Then
    WebViewRenderer.render(WebView(store: store))
  }

  @Test("빈 URL 스토어로도 WebView body 가 안전하게 평가된다")
  func body_withEmptyURL_rendersWithoutCrash() {
    // Given
    let store = makeStore(url: "")

    // When / Then
    WebViewRenderer.render(WebView(store: store))
  }

  @Test("잘못된 URL 스토어로도 WebView body 가 안전하게 평가된다")
  func body_withMalformedURL_rendersWithoutCrash() {
    // Given
    let store = makeStore(url: "h ttp://[not a url]")

    // When / Then
    WebViewRenderer.render(WebView(store: store))
  }

  @Test(
    "여러 URL 상태로 반복 렌더링해도 WebView body 평가가 안전하다",
    arguments: [
      "https://dddstudy.kr",
      "https://dddstudy.kr/terms",
      "about:blank",
      "",
      "그냥 문자열"
    ]
  )
  func body_withVariousURLs_rendersRepeatedlyWithoutCrash(url: String) {
    // Given
    let store = makeStore(url: url)

    // When / Then
    WebViewRenderer.render(WebView(store: store))
  }

  @Test("작은 화면 크기에서도 WebView body 가 레이아웃된다")
  func body_onCompactSize_laysOutWithoutCrash() {
    // Given
    let store = makeStore(url: "https://dddstudy.kr")

    // When / Then
    WebViewRenderer.render(
      WebView(store: store),
      size: CGSize(width: 320, height: 480)
    )
  }

  @Test("큰 화면 크기에서도 WebView body 가 레이아웃된다")
  func body_onLargeSize_laysOutWithoutCrash() {
    // Given
    let store = makeStore(url: "https://dddstudy.kr")

    // When / Then
    WebViewRenderer.render(
      WebView(store: store),
      size: CGSize(width: 1024, height: 1366)
    )
  }

  @Test("스토어를 교체해 다시 렌더링해도 WebView 는 안전하게 갱신된다")
  func body_whenStoreReplaced_updatesWithoutCrash() {
    // Given
    let first = WebView(store: makeStore(url: "https://dddstudy.kr"))
    let next = WebView(store: makeStore(url: "https://dddstudy.kr/privacy"))

    // When / Then
    WebViewRenderer.renderThenUpdate(first, then: next)
  }

  @Test("렌더링 이후에도 스토어의 url 상태는 그대로 유지된다")
  func body_afterRender_keepsStoreState() {
    // Given
    let store = makeStore(url: "https://dddstudy.kr/terms")

    // When
    WebViewRenderer.render(WebView(store: store))

    // Then
    #expect(store.url == "https://dddstudy.kr/terms")
  }
}
