//
//  WebView.swift
//  Profile
//
//  Created by DDD on 1/4/26.
//

import ComposableArchitecture
import DDDAccessibility
import DDDCoreUI
import DDDDesignKit
import SwiftUI

public struct WebView: View {
  @Bindable var store: StoreOf<WebFeature>

  public init(
    store: StoreOf<WebFeature>
  ) {
    self.store = store
  }

  public var body: some View {
    ZStack {
      Color.basicBlack
        .edgesIgnoringSafeArea(.all)

      VStack {
        Spacer()
          .frame(height: 12)

        CustomNavigationBackBar {
          store.send(.backToRoot)
        }
        .dddAccessibilityID(WebAccessibilityID.backButton)

        Spacer()
          .frame(height: 20)

        WebRepresentableView(urlToLoad: store.url)
          .edgesIgnoringSafeArea(.bottom)
      }
      .dddNavigationBarBackButtonHidden()
    }
    .accessibilityElement(children: .contain)
    .dddAccessibilityID(WebAccessibilityID.root)
  }
}
