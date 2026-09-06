//
//  Project.swift
//  ProfileDomain
//
//  Created by DDD on 9/4/26.
//

import DependencyPackagePlugin
import DependencyPlugin
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "ProfileDomain",
  bundleId: .appBundleID(name: ".ProfileDomain"),
  product: .framework,
  settings: .moduleSettings,
  dependencies: [
    .core(.storage, .interface),
    .serviceAssembly,
    .domain(.auth, .interface),
    .domain(.onBoarding, .interface),
    .SPM.dependencies,
    .SPM.composableArchitecture,
    .SPM.sqliteData
  ],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [.SPM.dependencies, .SPM.composableArchitecture]
)
