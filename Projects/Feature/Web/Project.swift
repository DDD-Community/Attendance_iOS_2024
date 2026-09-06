//
//  Project.swift
//  Web
//
//  Created by DDD on 9/4/26.
//

import Foundation

import DependencyPackagePlugin
import DependencyPlugin
import ProjectTemplatePlugin

import ProjectDescription

let project = Project.makeModule(
  name: "Web",
  bundleId: .appBundleID(name: ".Web"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .service(.accessibility),
    .ui(.sharedUI)
  ],
  sources: ["Sources/**"],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [
    .SPM.composableArchitecture
  ],
  hasDemo: true
)
