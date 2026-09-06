//
//  Project.swift
//  DDDAuth
//
//  Created by DDD on 9/1/26.
//

import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "DDDAuth",
  bundleId: .appBundleID(name: ".DDDAuth"),
  product: .framework,
  settings: .moduleSettings,
  dependencies: [
    .core(.logger),
    .core(.network, .implementation),
    .core(.storage, .interface),
    .service(.apiEndpoint)
  ],
  sources: ["Sources/**"],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [
    .core(.network, .interface),
    .SPM.dependencies
  ]
)
