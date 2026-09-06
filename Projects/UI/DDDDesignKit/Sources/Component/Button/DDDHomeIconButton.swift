//
//  DDDHomeIconButton.swift
//  DDDDesignKit
//

import SwiftUI

/// 홈 화면 내비게이션에서 사용하는 원형 아이콘 버튼.
public struct DDDHomeIconButton: View {
  private let image: ImageAsset
  private let foregroundColor: Color
  private let backgroundColor: Color
  private let borderColor: Color?
  private let borderWidth: CGFloat
  private let action: () -> Void

  public init(
    image: ImageAsset,
    foregroundColor: Color,
    backgroundColor: Color,
    borderColor: Color? = nil,
    borderWidth: CGFloat = 1,
    action: @escaping () -> Void
  ) {
    self.image = image
    self.foregroundColor = foregroundColor
    self.backgroundColor = backgroundColor
    self.borderColor = borderColor
    self.borderWidth = borderWidth
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      Image(asset: image)
        .renderingMode(.template)
        .resizable()
        .scaledToFit()
        .frame(width: 20, height: 20)
        .foregroundStyle(foregroundColor)
    }
    .buttonStyle(.plain)
    .frame(width: 36, height: 36)
    .background(backgroundColor)
    .clipShape(Circle())
    .overlay {
      if let borderColor {
        Circle()
          .stroke(borderColor, lineWidth: borderWidth)
      }
    }
  }
}
