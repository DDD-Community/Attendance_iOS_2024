//
//  DDDDividerTests.swift
//  DDDDesignKitTests
//
//  Copyright © 2026 DDD. All rights reserved.
//

import SwiftUI
import Testing
@testable import DDDDesignKit

@MainActor
@Suite("DDDDivider")
struct DDDDividerTests {
  @Test("기본 구분선은 1pt 가로선이다")
  func defaultConfiguration() {
    let divider = DDDDivider()

    #expect(divider.color == .borderNormal)
    #expect(divider.thickness == DDDSize.dividerThickness)
    #expect(divider.orientation == .horizontal)
    _ = divider.body
  }

  @Test("가로선은 호출부의 색과 두께를 유지한다")
  func horizontalConfiguration() {
    let divider = DDDDivider(color: .gray80, thickness: 2)

    #expect(divider.color == .gray80)
    #expect(divider.thickness == 2)
    #expect(divider.orientation == .horizontal)
    _ = divider.body
  }

  @Test("세로선은 제한된 높이와 두께를 사용한다")
  func constrainedVerticalConfiguration() {
    let divider = DDDDivider(
      color: .borderDisabled,
      orientation: .vertical(height: 48)
    )

    #expect(divider.color == .borderDisabled)
    #expect(divider.thickness == DDDSize.dividerThickness)
    #expect(divider.orientation == .vertical(height: 48))
    _ = divider.body
  }
}
