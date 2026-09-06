//
//  Project.swift
//  QRCodeDomain
//
//  Created by DDD on 9/4/26.
//

import DependencyPackagePlugin
import DependencyPlugin
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "QRCodeDomain",
  bundleId: .appBundleID(name: ".QRCodeDomain"),
  product: .framework,
  settings: .moduleSettings,
  dependencies: [
    .serviceAssembly,
    .domain(.attendance, .interface),
    .domain(.onBoarding, .interface),
    .SPM.dependencies
  ],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [
    .domain(.attendance, .interface),
    .SPM.dependencies,
    .SPM.composableArchitecture
  ]
)
