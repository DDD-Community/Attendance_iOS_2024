//
//  ProfileCoordinatorView.swift
//  Profile
//
//  Created by DDD on 1/4/26.
//

import SwiftUI

import DDDCoreUI
import OnBoarding
import Profile
import Web

import ComposableArchitecture
import TCAFlow

public struct ProfileCoordinatorView: View {
  @Bindable var store: StoreOf<ProfileCoordinator>

  public init(
    store: StoreOf<ProfileCoordinator>
  ) {
    self.store = store
  }

  public var body: some View {
    TCAFlowRouter(store.scope(\.routes, action: \.router)) { screens in
      switch screens.case {
        case .profile(let profileStore):
          ProfileView(store: profileStore)
          .navigationBarBackButtonHidden()

        case .web(let webStore):
          WebView(store: webStore)
          .navigationBarBackButtonHidden()

        case .onBoarding(let onBoardingStore):
          OnBoardingCoordinatorView(store: onBoardingStore)
          .navigationBarBackButtonHidden()
      }
    }
  }

}
