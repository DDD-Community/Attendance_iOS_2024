//
//  OnBoardingCoordinatorView.swift
//  OnBoarding
//
//  Created by DDD on 1/6/26.
//

import OnBoarding
import DDDCoreUI
import SwiftUI

import ComposableArchitecture
import TCAFlow

public struct OnBoardingCoordinatorView: View {
  @Bindable var store: StoreOf<OnBoardingCoordinator>

  public init(
    store: StoreOf<OnBoardingCoordinator>
  ) {
    self.store = store
  }

  public var body: some View {
    TCAFlowRouter(store.scope(state: \.routes, action: \.router)) { screen in
      switch screen.case {
        case .InviteCode(let InviteCodeStore):
          InviteCodeView(store: InviteCodeStore)
          .dddNavigationBarBackButtonHidden()

        case .onBoardingName(let onBoardingNameStore):
           OnBoardingNameView(store: onBoardingNameStore)
          .dddNavigationBarBackButtonHidden()

        case .selectPart(let selectPartStore):
          SelectPartView(store: selectPartStore)
          .dddNavigationBarBackButtonHidden()

        case .selectManaging(let selectManagingStore):
          SelectManagingView(store: selectManagingStore)
          .dddNavigationBarBackButtonHidden()

        case .selectTeam(let signUpSelectTeamStore):
          SelectTeamView(store: signUpSelectTeamStore)
          .dddNavigationBarBackButtonHidden()
      }
    }
  }
}
