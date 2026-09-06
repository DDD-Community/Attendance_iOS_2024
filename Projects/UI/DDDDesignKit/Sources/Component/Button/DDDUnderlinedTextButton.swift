//
//  DDDUnderlinedTextButton.swift
//  DDDDesignKit
//

import SwiftUI

/// 별도 배경 없이 밑줄 친 텍스트만 표시하는 버튼입니다.
public struct DDDUnderlinedTextButton: View {
  private let title: String
  private let font: CustomSizeFont
  private let foregroundColor: Color
  private let underlineColor: Color
  private let action: () -> Void

  public init(
    title: String,
    font: CustomSizeFont,
    foregroundColor: Color,
    underlineColor: Color,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.font = font
    self.foregroundColor = foregroundColor
    self.underlineColor = underlineColor
    self.action = action
  }

  public var body: some View {
    Text(title)
      .dddFont(font)
      .foregroundStyle(foregroundColor)
      .underline(true, color: underlineColor)
      .onTapGesture {
        action()
      }
  }
}
