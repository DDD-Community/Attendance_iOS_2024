//
//  Project.swift
//  OnBoarding
//
//  Created by DDD on 9/4/26.
//

import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "OnBoarding",
  bundleId: .appBundleID(name: ".OnBoarding"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .service(.accessibility),
    .ui(.sharedUI),
    .core(.logger),
    .domain(.auth, .interface),
    .domain(.onBoarding, .interface),
    .domain(.profile, .interface)
  ],
  sources: ["Sources/**"],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [
    .SPM.composableArchitecture
  ],
  hasDemo: true
)
