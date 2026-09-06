//
//  DDDOutlinedButton.swift
//  DDDDesignKit
//

import SwiftUI

/// 투명한 배경과 외곽선을 사용하는 캡슐형 버튼입니다.
public struct DDDOutlinedButton: View {
  private let title: String
  private let font: CustomSizeFont
  private let foregroundColor: Color
  private let borderColor: Color
  private let height: CGFloat
  private let lineWidth: CGFloat
  private let action: () -> Void

  public init(
    title: String,
    font: CustomSizeFont = .body1NormalMedium,
    foregroundColor: Color = .staticWhite,
    borderColor: Color = .borderInactive,
    height: CGFloat = 58,
    lineWidth: CGFloat = 1,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.font = font
    self.foregroundColor = foregroundColor
    self.borderColor = borderColor
    self.height = height
    self.lineWidth = lineWidth
    self.action = action
  }

  public var body: some View {
    Capsule()
      .strokeBorder(borderColor, lineWidth: lineWidth)
      .frame(height: height)
      .overlay {
        Text(title)
          .dddFont(font)
          .foregroundStyle(foregroundColor)
      }
      .contentShape(Capsule())
      .onTapGesture {
        action()
      }
  }
}
