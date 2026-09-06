//
//  Project.swift
//  ServiceAssembly
//
//  Created by DDD on 9/1/26.
//

import DependencyPackagePlugin
import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "ServiceAssembly",
  bundleId: .appBundleID(name: ".ServiceAssembly"),
  product: .framework,
  settings: .moduleSettings,
  dependencies: [
    .core(.assembly),
    .service(.apiEndpoint),
    .service(.auth, .implementation),
    .SPM.dependencies
  ],
  sources: ["Sources/**"],
  hasTests: true
)
