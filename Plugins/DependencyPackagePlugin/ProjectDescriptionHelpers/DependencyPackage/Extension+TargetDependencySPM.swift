//
//  Extension+TargetDependencySPM.swift
//  DependencyPackagePlugin
//
//  Created by DDD on 4/19/24.
//

import ProjectDescription

public extension TargetDependency.SPM {
  static let alamofire = TargetDependency.external(name: "Alamofire", condition: .none)

  static let composableArchitecture = TargetDependency.external(name: "ComposableArchitecture", condition: .none)
  static let dependencies = TargetDependency.external(name: "Dependencies", condition: .none)
  static let sharing = TargetDependency.external(name: "Sharing", condition: .none)
  static let sqliteData = TargetDependency.external(name: "SQLiteData", condition: .none)
  static let tcaFlow = TargetDependency.external(name: "TCAFlow", condition: .none)
  static let concurrencyExtras = TargetDependency.external(name: "ConcurrencyExtras", condition: .none)
  static let sdwebImage = TargetDependency.external(name: "SDWebImageSwiftUI", condition: .none)

  static let googleSignIn = TargetDependency.external(name: "GoogleSignIn", condition: .none)
  static let firebaseCrashlytics = TargetDependency.external(name: "FirebaseCrashlytics", condition: .none)
}
