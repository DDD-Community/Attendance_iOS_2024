//
//  AttendanceApp.swift
//  DDDAttendance
//
//  Created by DDD on 10/29/24.
//

import SwiftUI

import ComposableArchitecture
import FeatureAssembly

@main
struct AttendanceApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  init() {
    #if DEBUG
    IssueReportingConfiguration.configure()
    #endif
  }

  var body: some Scene {
    WindowGroup {
      let store = Store(initialState: AppReducer.State()) {
        AppReducer()
          ._printChanges()
          ._printChanges(.actionLabels)
      }

      AppView(store: store)
    }
  }
}
