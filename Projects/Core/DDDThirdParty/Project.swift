//
//  Project.swift
//  DDDThirdParty
//
//  Created by DDD on 9/4/26.
//

import Foundation

import DependencyPackagePlugin
import DependencyPlugin
import ProjectTemplatePlugin

import ProjectDescription

let project = Project.makeModule(
  name: "DDDThirdParty",
  bundleId: .appBundleID(name: ".DDDThirdParty"),
  product: .framework,
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
