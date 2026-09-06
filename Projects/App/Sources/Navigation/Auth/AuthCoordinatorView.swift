//
//  AuthCoordinatorView.swift
//  Presentation
//
//  Created by DDD on 11/2/24.
//

import Auth
import DDDCoreUI
import SwiftUI

import OnBoarding
import Web

import ComposableArchitecture
import TCAFlow


public struct AuthCoordinatorView: View {
  @Bindable private var store: StoreOf<AuthCoordinator>
  
  public init(
    store: StoreOf<AuthCoordinator>
  ) {
    self.store = store
  }
  
  public var body: some View {
    TCAFlowRouter(store.scope(state: \.routes, action: \.router)) { screen in
      switch screen.case {
      case .login(let loginStore):
        LoginView(store: loginStore)
          .dddNavigationBarBackButtonHidden()

        case .onboarding(let onBoardingStore):
          OnBoardingCoordinatorView(store: onBoardingStore)
            .dddNavigationBarBackButtonHidden()


        case .web(let webStore):
          WebView(store: webStore)
            .dddNavigationBarBackButtonHidden()
      }
    }
  }
}
