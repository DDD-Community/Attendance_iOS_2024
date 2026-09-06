//
//  DDDDivider.swift
//  DDDDesignKit
//
//  Copyright © 2026 DDD. All rights reserved.
//

import SwiftUI

/// 색상과 두께를 명시적으로 유지하는 구분선입니다.
public struct DDDDivider: View {
  public enum Orientation: Equatable {
    case horizontal
    case vertical(height: CGFloat)
  }

  let color: Color
  let thickness: CGFloat
  let orientation: Orientation

  public init(
    color: Color = .borderNormal,
    thickness: CGFloat = DDDSize.dividerThickness,
    orientation: Orientation = .horizontal
  ) {
    self.color = color
    self.thickness = thickness
    self.orientation = orientation
  }

  public var body: some View {
    Group {
      switch orientation {
      case .horizontal:
        color
          .frame(maxWidth: .infinity)
          .frame(height: thickness)

      case let .vertical(height):
        color
          .frame(width: thickness, height: height)
      }
    }
    .accessibilityHidden(true)
  }
}
