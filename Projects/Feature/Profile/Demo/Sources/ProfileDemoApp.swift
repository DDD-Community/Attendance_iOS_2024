//
//  ProfileDemoApp.swift
//  ProfileDemo
//
//  Created by DDD on 2026-09-02
//
//  앱 전체를 빌드하지 않고 Profile 화면만 확인하기 위한 단독 실행 앱.
//  의존성은 live 그대로라 네트워크가 없으면 에러·로딩 상태가 보인다.
//  화면 레이아웃과 컴포넌트 확인이 목적이다.
//

import ComposableArchitecture
import DDDDesignKit
import Profile
import SwiftUI

@main
struct ProfileDemoApp: App {
  init() {
    // 앱과 동일하게 런타임에 폰트를 등록한다.
    PretendardFontFamily.registerFonts()
  }

  var body: some Scene {
    WindowGroup {
      ProfileView(
        store: Store(initialState: ProfileFeature.State()) {
          ProfileFeature()
        }
      )
    }
  }
}
