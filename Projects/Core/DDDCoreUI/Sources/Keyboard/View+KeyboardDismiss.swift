//
//  View+KeyboardDismiss.swift
//  DDDCoreUI
//
//  Adapted from SwiftUIX 0.2.3 Keyboard.dismiss() (MIT) and the Joongna UI pattern.
//  Copyright (c) 2024 Vatsal Manot.
//

import SwiftUI

@MainActor
public extension View {
  /// 현재 first responder에 resign 요청을 보내 표시 중인 키보드를 닫습니다.
  func dismissKeyboard() {
    resignFirstResponder()
  }

  /// 이 View의 빈 영역을 포함해 탭하면 키보드를 닫습니다.
  func dismissKeyboardOnTap() -> some View {
    modifier(KeyboardDismissOnTap())
  }
}

private struct KeyboardDismissOnTap: ViewModifier {
  func body(content: Content) -> some View {
    content
      .contentShape(Rectangle())
      .onTapGesture {
        resignFirstResponder()
      }
  }
}

@MainActor
private func resignFirstResponder() {
  UIApplication.shared.sendAction(
    #selector(UIResponder.resignFirstResponder),
    to: nil,
    from: nil,
    for: nil
  )
}
