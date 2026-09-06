//
//  Project.swift
//  ScheduleDomain
//
//  Created by DDD on 9/4/26.
//

import DependencyPackagePlugin
import DependencyPlugin
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "ScheduleDomain",
  bundleId: .appBundleID(name: ".ScheduleDomain"),
  product: .framework,
  settings: .moduleSettings,
  dependencies: [
    .core(.storage, .interface),
    .serviceAssembly,
    .SPM.dependencies,
    .SPM.sqliteData
  ],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [
    .core(.coreUtility),
    .SPM.dependencies,
    .SPM.composableArchitecture
  ]
)
