//
//  DDDProfileButtonsTests.swift
//  DDDDesignKitTests
//

import SwiftUI
import Testing

@testable import DDDDesignKit

@MainActor
@Suite("프로필 공통 버튼")
struct DDDProfileButtonsTests {
  @Test("외곽선 버튼의 기본값과 사용자 설정을 구성한다")
  func outlinedButtonConfigurationsBuild() {
    build(
      DDDOutlinedButton(title: "앱 피드백 남기기", action: {})
    )
    build(
      DDDOutlinedButton(
        title: "외곽선 버튼",
        font: .body2NormalMedium,
        foregroundColor: .mediumGray,
        borderColor: .statusFocus,
        height: 48,
        lineWidth: 2,
        action: {}
      )
    )
  }

  @Test("밑줄 텍스트 버튼의 프로필 화면 스타일을 구성한다")
  func underlinedTextButtonConfigurationsBuild() {
    build(
      DDDUnderlinedTextButton(
        title: "탈퇴하기",
        font: .body2NormalMedium,
        foregroundColor: .mediumGray,
        underlineColor: .mediumGray,
        action: {}
      )
    )
    build(
      DDDUnderlinedTextButton(
        title: "로그아웃",
        font: .body2NormalMedium,
        foregroundColor: .staticWhite,
        underlineColor: .staticWhite,
        action: {}
      )
    )
    build(
      DDDUnderlinedTextButton(
        title: "개인정보처리방침 보기",
        font: .body3NormalRegular,
        foregroundColor: .mediumGray,
        underlineColor: .mediumGray,
        action: {}
      )
    )
  }

  private func build(_ view: some View) {
    _ = view
  }
}
