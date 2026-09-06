//
//  AuthViewRenderer.swift
//  AuthTests
//
//  Created by DDD on 2026-09-03
//

import ComposableArchitecture
import Foundation
import SwiftUI
import UIKit

@testable import Auth

/// SwiftUI 뷰의 body 를 실제로 평가해 렌더링 경로를 커버리지에 태우는 헬퍼.
@MainActor
enum AuthViewRenderer {
  /// 기본 렌더링 사이즈 (iPhone 15 논리 해상도).
  static let defaultSize = CGSize(width: 393, height: 852)

  /// 뷰를 UIHostingController 에 올려 레이아웃까지 강제로 수행한다.
  static func render(
    _ view: some View,
    size: CGSize = AuthViewRenderer.defaultSize
  ) {
    let controller = UIHostingController(rootView: view)
    controller.view.frame = CGRect(origin: .zero, size: size)
    controller.view.setNeedsLayout()
    controller.view.layoutIfNeeded()
  }

  /// 테스트끼리 @Shared(appStorage/inMemory) 저장소가 섞이지 않도록 격리한 Store 를 만든다.
  ///
  /// `initialState` 는 autoclosure 라서 Store 내부의 의존성 컨텍스트에서 평가된다.
  /// 따라서 State 를 미리 만들지 않고 클로저 안에서 조립해야 격리가 유지된다.
  static func makeStore(
    configureState: (inout LoginFeature.State) -> Void = { _ in }
  ) -> StoreOf<LoginFeature> {
    let appStorage = UserDefaults.inMemory
    let inMemoryStorage = InMemoryStorage()

    return Store(
      initialState: {
        var state = LoginFeature.State()
        configureState(&state)
        return state
      }()
    ) {
      LoginFeature()
    } withDependencies: {
      $0.defaultAppStorage = appStorage
      $0.defaultInMemoryStorage = inMemoryStorage
    }
  }
}
