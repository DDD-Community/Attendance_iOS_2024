//
//  MemberViewRenderer.swift
//  MemberTests
//
//  SwiftUI 뷰의 body 를 실제로 평가시키기 위한 테스트 전용 헬퍼.
//

import SwiftUI
import UIKit

import ComposableArchitecture

@MainActor
enum MemberViewRenderer {
  /// SwiftUI 뷰의 body 를 실제로 평가해 렌더링 경로를 커버리지에 태운다.
  static func render(
    _ view: some View,
    size: CGSize = CGSize(width: 393, height: 852)
  ) {
    let controller = UIHostingController(rootView: view)
    controller.view.frame = CGRect(origin: .zero, size: size)
    controller.view.setNeedsLayout()
    controller.view.layoutIfNeeded()
  }
}
