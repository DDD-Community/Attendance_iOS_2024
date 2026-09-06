//
//  Project.swift
//  DDDThirdParty
//
//  Created by DDD on 9/4/26.
//

import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "DDDThirdParty",
  bundleId: .appBundleID(name: ".DDDThirdParty"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .SPM.composableArchitecture,
    .SPM.concurrencyExtras,
    .SPM.tcaFlow,
    .SPM.sdwebImage,
    .SPM.googleSignIn,
    .SPM.firebaseCrashlytics,
  ],
  sources: ["Sources/**"]
)
