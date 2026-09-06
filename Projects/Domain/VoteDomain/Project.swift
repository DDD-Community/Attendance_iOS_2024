//
//  Project.swift
//  VoteDomain
//
//  Created by DDD on 9/4/26.
//

import DependencyPackagePlugin
import DependencyPlugin
import ProjectTemplatePlugin

import ProjectDescription

let project = Project.makeModule(
  name: "VoteDomain",
  bundleId: .appBundleID(name: ".VoteDomain"),
  product: .framework,
  settings: .moduleSettings,
  dependencies: [
    .serviceAssembly,
    .SPM.dependencies
  ],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [.SPM.dependencies, .SPM.composableArchitecture]
)
