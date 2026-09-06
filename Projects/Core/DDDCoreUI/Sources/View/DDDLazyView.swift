//
//  DDDLazyView.swift
//  DDDCoreUI
//
//  The behavior is adapted from SwiftUIX 0.2.3 LazyView (MIT).
//  Copyright (c) 2024 Vatsal Manot.
//

import SwiftUI

/// 콘텐츠 생성을 SwiftUI가 `body`를 평가하는 시점까지 미룹니다.
public struct DDDLazyView<Content: View>: View {
  private let content: () -> Content

  @inline(never)
  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  @inline(never)
  public var body: some View {
    content()
  }
}
