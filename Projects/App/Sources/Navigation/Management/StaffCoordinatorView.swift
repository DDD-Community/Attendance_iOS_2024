//
//  StaffCoordinatorView.swift
//  Presentation
//
//  Created by DDD on 11/4/24.
//

import Management
import DDDCoreUI
import SwiftUI

import ComposableArchitecture
import TCAFlow
import Profile

public struct StaffCoordinatorView: View {
  @Bindable private var store: StoreOf<StaffCoordinator>

  public init(
    store: StoreOf<StaffCoordinator>
  ) {
    self.store = store
  }
  
  public var body: some View {
    TCAFlowRouter(store.scope(state: \.routes, action: \.router)) { screens in
      switch screens.case {
      case .coreMember(let coreMember):
        StaffView(store: coreMember)
          .dddNavigationBarBackButtonHidden()

      case .profile(let profileStore):
       ProfileCoordinatorView(store: profileStore)
        .dddNavigationBarBackButtonHidden()
      }
    }
  }
}
