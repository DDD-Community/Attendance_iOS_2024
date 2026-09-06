//
//  View+DDDAccessibilityID.swift
//  DDDAccessibility
//

import SwiftUI

public extension View {
  /// SwiftUI 뷰를 Maestro의 `id:` selector로 찾을 수 있게 한다.
  func dddAccessibilityID(_ id: String) -> some View {
    accessibilityIdentifier(id)
  }
}
