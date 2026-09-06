//
//  ManagementViewRenderer.swift
//  ManagementTests
//
//  Created by DDD on 2026-09-03.
//
//  SwiftUI 뷰는 body 가 실제로 평가되어야 커버리지에 잡힌다.
//  UIHostingController 에 올려 레이아웃을 강제하면 body 와 하위 @ViewBuilder 분기가 모두 실행된다.
//

import SwiftUI
import UIKit

import ComposableArchitecture

@MainActor
enum ManagementViewRenderer {
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
