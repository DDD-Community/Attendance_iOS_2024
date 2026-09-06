//
//  ProfileCoordinatorView.swift
//  Profile
//
//  Created by DDD on 1/4/26.
//

import Profile
import DDDCoreUI
import SwiftUI

import ComposableArchitecture
import TCAFlow
import OnBoarding
import Web

public struct ProfileCoordinatorView: View {
  @Bindable var store: StoreOf<ProfileCoordinator>

  public init(
    store: StoreOf<ProfileCoordinator>
  ) {
    self.store = store
  }

  public var body: some View {
    TCAFlowRouter(store.scope(state: \.routes, action: \.router)) { screens in
      switch screens.case {
        case .profile(let profileStore):
          ProfileView(store: profileStore)
          .dddNavigationBarBackButtonHidden()

        case .web(let webStore):
          WebView(store: webStore)
            .dddNavigationBarBackButtonHidden()

        case .onBoarding(let onBoardingStore):
          OnBoardingCoordinatorView(store: onBoardingStore)
            .dddNavigationBarBackButtonHidden()
      }
    }
  }

}
