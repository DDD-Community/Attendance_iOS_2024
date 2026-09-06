//
//  ProfileViewRenderer.swift
//  ProfileTests
//
//  Created by DDD on 2026-09-03
//  Copyright © 2026 DDD , Ltd. All rights reserved.
//
//  SwiftUI 뷰는 body 를 평가해야 커버리지에 잡힌다.
//  UIWindow 에 붙여 레이아웃까지 강제해 실제 렌더링 경로를 태운다.
//

import ComposableArchitecture
import ProfileDomainInterface
import SwiftUI
import UIKit

@testable import Profile

@MainActor
enum ProfileViewRenderer {
  /// SwiftUI 뷰의 body 를 실제로 평가해 렌더링 경로를 커버리지에 태운다.
  static func render(
    _ view: some View,
    size: CGSize = CGSize(width: 393, height: 852)
  ) {
    let controller = UIHostingController(rootView: view)
    let window = UIWindow(frame: CGRect(origin: .zero, size: size))
    window.rootViewController = controller
    window.isHidden = false

    controller.view.frame = CGRect(origin: .zero, size: size)
    controller.view.setNeedsLayout()
    controller.view.layoutIfNeeded()
    window.layoutIfNeeded()
  }

  /// onAppear 에서 fetchUser 이펙트가 돌아도 네트워크를 타지 않도록
  /// 스텁 의존성을 심은 ProfileFeature 스토어를 만든다.
  static func makeStore(
    state: ProfileFeature.State,
    profileUseCase: StubProfileUseCase = StubProfileUseCase(),
    authRepository: StubAuthRepository = StubAuthRepository()
  ) -> StoreOf<ProfileFeature> {
    Store(initialState: state) {
      ProfileFeature()
    } withDependencies: {
      $0.profileUseCase = profileUseCase
      $0.authUseCase = authRepository
      $0.continuousClock = ImmediateClock()
    }
  }

  /// 프로필이 이미 채워진 상태의 스토어. 로딩/스켈레톤 분기를 건너뛴다.
  static func makeStore(
    profile: ProfileEntity?,
    isLoading: Bool = false
  ) -> StoreOf<ProfileFeature> {
    var state = ProfileFeature.State()
    state.profile = profile
    state.viewState = isLoading ? .loading : .loaded
    return makeStore(state: state)
  }
}
