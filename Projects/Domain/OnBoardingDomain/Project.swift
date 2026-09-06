//
//  Project.swift
//  OnBoardingDomain
//
//  Created by DDD on 9/4/26.
//

import DependencyPackagePlugin
import DependencyPlugin
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "OnBoardingDomain",
  bundleId: .appBundleID(name: ".OnBoardingDomain"),
  product: .framework,
  settings: .moduleSettings,
  dependencies: [
    .core(.logger),
    .serviceAssembly,
    .domain(.auth, .interface),
    .SPM.dependencies
  ],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [
    .domain(.auth, .interface),
    .domain(.profile, .interface),
    .SPM.dependencies,
    .SPM.composableArchitecture
  ]
)
