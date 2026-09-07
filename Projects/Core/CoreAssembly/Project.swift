//
//  Project.swift
//  CoreAssembly
//
//  Created by DDD on 9/1/26.
//

import Foundation

import DependencyPlugin
import ProjectTemplatePlugin

import ProjectDescription

let project = Project.makeModule(
  name: "CoreAssembly",
  bundleId: .appBundleID(name: ".CoreAssembly"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .core(.logger),
    .core(.coreUI),
    .core(.coreUtility),
    .core(.network, .implementation),
    .core(.storage, .implementation)
  ],
  sources: ["Sources/**"],
  hasTests: true
)
