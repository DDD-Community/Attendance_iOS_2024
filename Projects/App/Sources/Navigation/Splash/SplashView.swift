//
//  SplashView.swift
//  DDDAttendance
//
//  Created by DDD on 10/29/24.
//

import DDDSharedUI
import FeatureAssembly
import SwiftUI

@ViewAction(for: SplashFeature.self)
public struct SplashView: View {
  @Bindable public var store: StoreOf<SplashFeature>
  @State private var isAnimating = false // GIF 애니메이션 상태 관리

  public init(
    store: StoreOf<SplashFeature>
  ) {
    self.store = store
  }
  
  public var body: some View {
    ZStack {
      Color.backGroundPrimary
        .edgesIgnoringSafeArea(.all)
      
      VStack {
        Spacer()
        
        DDDAnimationView(.loading, isAnimating: $isAnimating)
          .frame(width: 200, height: 200)
        
        Spacer()
      }
    }
    .onAppear {
      isAnimating = true // 화면 표시시 애니메이션 시작
      send(.onAppear)
    }
    .onDisappear {
      isAnimating = false // 화면 종료시 애니메이션 중지 (메모리 절약)
    }
    .dddAlert($store.scope(\.customAlert, action: \.scope.customAlert))
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier("splash_root")
  }
}
