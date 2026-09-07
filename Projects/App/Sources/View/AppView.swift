//
//  AppView.swift
//  DDDAttendance
//
//  Created by DDD on 10/29/24.
//

import SwiftUI

import DDDDesignKit
import FeatureAssembly

import ComposableArchitecture

struct AppView: View {
  @Bindable var store: StoreOf<AppReducer>

  var body: some View {
    ZStack(alignment: .topLeading) {
      Color.backGroundPrimary
        .edgesIgnoringSafeArea(.all)

      SwitchStore(store) { state in
        switch state {
        case .splash:
          if let store = store.scope(\.splash, action: \.scope.splash) {
            SplashView(store: store)
              .transition(.opacity.combined(with: .scale(scale: 0.98)))
          }

        case .auth:
          if let store = store.scope(\.auth, action: \.scope.auth) {
            AuthCoordinatorView(store: store)
              .transition(.asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
              ))
          }

        case .staff:
          if let store = store.scope(\.staff, action: \.scope.staff) {
            StaffCoordinatorView(store: store)
              .transition(.asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
              ))
          }

        case .member:
          if let store = store.scope(\.member, action: \.scope.member) {
            MemberCoordinatorView(store: store)
              .transition(.asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
              ))
          }
        }
      }
    }
    .animation(
      .spring(response: 0.52, dampingFraction: 0.94, blendDuration: 0.14),
      value: store.state.animationID
    )
    .onAppear {
      store.send(.async(.startNotificationListener))
    }
  }
}


#Preview {
  AppView(
    store: Store(
      initialState: AppReducer.State(),
      reducer: {
        AppReducer()
      })
  )
}

#Preview {
  AuthCoordinatorView(
    store: Store(
      initialState: AuthCoordinator.State(),
      reducer: {
        AuthCoordinator()
      })
  )
}


#Preview {
  StaffCoordinatorView(
    store: Store(
      initialState: StaffCoordinator.State(),
      reducer: {
        StaffCoordinator()
      })
  )
}

#Preview {
  ProfileCoordinatorView(
    store: Store(
      initialState: ProfileCoordinator.State(),
      reducer: {
        ProfileCoordinator()
      })
  )
}
