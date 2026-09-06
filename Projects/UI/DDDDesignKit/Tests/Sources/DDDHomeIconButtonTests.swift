//
//  DDDHomeIconButtonTests.swift
//  DDDDesignKitTests
//

import SwiftUI
import Testing

@testable import DDDDesignKit

@MainActor
@Suite("DDDHomeIconButton")
struct DDDHomeIconButtonTests {
  @Test("테두리가 없는 홈 아이콘 버튼을 구성한다")
  func buildsWithoutBorder() {
    build(
      DDDHomeIconButton(
        image: .user,
        foregroundColor: .staticWhite,
        backgroundColor: .gray80,
        action: {}
      )
    )
  }

  @Test("테두리가 있는 홈 아이콘 버튼을 구성한다")
  func buildsWithBorder() {
    build(
      DDDHomeIconButton(
        image: .qrCode,
        foregroundColor: .staticWhite,
        backgroundColor: .blue70,
        borderColor: .blue30,
        borderWidth: 1,
        action: {}
      )
    )
  }

  private func build(_ view: some View) {
    _ = view
  }
}
