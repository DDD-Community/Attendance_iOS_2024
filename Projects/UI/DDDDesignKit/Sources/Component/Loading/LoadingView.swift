//
//  LoadingView.swift
//  DDDDesignKit
//
//  Created by DDD on 5/9/25.
//

import SwiftUI

import DDDAnimation
import DDDCoreUI

public struct LoadingView: View {
  @State private var isVisible = false

  public init() {}

  public var body: some View {
    DDDLazyView {
      ZStack {
        Color.basicBlack
          .edgesIgnoringSafeArea(.all)

        VStack {
          loadingView()
        }
      }
      .onAppear {
        isVisible = true
      }
      .onDisappear {
        isVisible = false
      }
    }
  }
}

extension LoadingView {
  @ViewBuilder
  fileprivate func loadingView() -> some View {
    VStack {
      Spacer()
      
      DDDAnimationView(.loading, isAnimating: .constant(isVisible))
        .frame(width: 200, height: 200)
      
      Spacer()
    }
  }
}
