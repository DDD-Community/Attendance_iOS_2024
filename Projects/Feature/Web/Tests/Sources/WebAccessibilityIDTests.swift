//
//  WebAccessibilityIDTests.swift
//  WebTests
//

import Testing

@testable import Web

@Suite("Web accessibility ID")
struct WebAccessibilityIDTests {
  @Test("웹뷰 화면의 Maestro ID 계약")
  func identifiers() {
    #expect(WebAccessibilityID.root == "web.root")
    #expect(WebAccessibilityID.backButton == "web.backbutton")
  }
}
