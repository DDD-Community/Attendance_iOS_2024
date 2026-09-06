//
//  Project.swift
//  MyPageDomain
//
//  Created by DDD on 9/4/26.
//

import DependencyPackagePlugin
import DependencyPlugin
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "MyPageDomain",
  bundleId: .appBundleID(name: ".MyPageDomain"),
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
