//
//  Project.swift
//  DDDNetwork
//
//  Created by DDD on 9/4/26.
//

import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "DDDNetwork",
  bundleId: .appBundleID(name: ".DDDNetwork"),
  product: .framework,
  settings: .moduleSettings,
  dependencies: [
    .core(.logger),
    .SPM.alamofire
  ],
  sources: ["Sources/**"],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [
    .SPM.alamofire,
    .SPM.dependencies
  ]
)
