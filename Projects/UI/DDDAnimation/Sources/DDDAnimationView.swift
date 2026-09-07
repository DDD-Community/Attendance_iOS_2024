//
//  DDDAnimationView.swift
//  DDDAnimation
//
//  Created by DDD on 9/1/26.
//

import SwiftUI

import SDWebImageSwiftUI

/// 애니메이션 재생 뷰. 에셋은 이 모듈 번들에서 찾으므로 호출부가 번들 위치를 알 필요가 없다.
/// 크기는 호출부가 `.frame(...)` 으로 정한다.
public struct DDDAnimationView: View {
  private let asset: DDDAnimationAsset
  private let isAnimating: Binding<Bool>

  public init(_ asset: DDDAnimationAsset, isAnimating: Binding<Bool> = .constant(true)) {
    self.asset = asset
    self.isAnimating = isAnimating
  }

  public var body: some View {
    AnimatedImage(name: asset.rawValue, bundle: .module, isAnimating: isAnimating)
      .resizable()
      .scaledToFit()
  }
}
