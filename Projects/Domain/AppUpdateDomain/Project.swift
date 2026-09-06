//
//  Project.swift
//  AppUpdateDomain
//
//  Created by DDD on 9/4/26.
//

import DependencyPackagePlugin
import DependencyPlugin
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "AppUpdateDomain",
  bundleId: .appBundleID(name: ".AppUpdateDomain"),
  product: .framework,
  settings: .moduleSettings,
  dependencies: [
    .core(.logger),
    .SPM.dependencies
  ],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [
    .SPM.dependencies,
    .SPM.composableArchitecture
  ]
)
