//
//  DDDAccessibilityIDTests.swift
//  DDDAccessibilityTests
//

import DDDAccessibility
import SwiftUI
import Testing

@Suite("DDDAccessibility ID")
struct DDDAccessibilityIDTests {
  @MainActor
  @Test("SwiftUI view에 Maestro ID를 체이닝할 수 있다")
  func appliesIdentifier() {
    _ = Text("출석").dddAccessibilityID("management.attendance.root")
  }
}
