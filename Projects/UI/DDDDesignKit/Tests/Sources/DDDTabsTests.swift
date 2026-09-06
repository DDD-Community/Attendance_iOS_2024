//
//  DDDTabsTests.swift
//  DDDDesignKitTests
//

import SwiftUI
import Testing

@testable import DDDDesignKit

@MainActor
@Suite("DDDTabs")
struct DDDTabsTests {
  private struct Tab: Identifiable {
    let id: Int
    let title: String
  }

  @Test("선택 상태와 접근성 ID를 포함한 탭을 구성한다")
  func constructsSelectedTabs() {
    let tabs = [
      Tab(id: 1, title: "iOS 1팀"),
      Tab(id: 2, title: "Web 1팀"),
    ]

    build(
      DDDTabs(
        items: tabs,
        selectedID: 1,
        title: \.title,
        onSelect: { _ in }
      )
      .accessibilityIdentifier { "team.\($0.id)" }
    )
  }

  @Test("선택값과 접근성 ID가 없어도 탭을 구성한다")
  func constructsUnselectedTabs() {
    build(
      DDDTabs(
        items: [Tab(id: 1, title: "iOS 1팀")],
        selectedID: nil,
        title: \.title,
        onSelect: { _ in }
      )
    )
  }

  private func build(_ view: some View) {
    _ = view
  }
}
