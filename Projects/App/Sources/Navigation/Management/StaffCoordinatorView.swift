//
//  StaffCoordinatorView.swift
//  Presentation
//
//  Created by DDD on 11/4/24.
//

import SwiftUI

import DDDCoreUI
import Management
import Profile

import ComposableArchitecture
import TCAFlow

public struct StaffCoordinatorView: View {
  @Bindable private var store: StoreOf<StaffCoordinator>

  public init(
    store: StoreOf<StaffCoordinator>
  ) {
    self.store = store
  }
  
  public var body: some View {
    TCAFlowRouter(store.scope(\.routes, action: \.router)) { screens in
      switch screens.case {
      case .coreMember(let coreMember):
        StaffView(store: coreMember)
          .navigationBarBackButtonHidden()

      case .profile(let profileStore):
       ProfileCoordinatorView(store: profileStore)
          .swipeBackButtonHidden()
      }
    }
  }
}
