//
//  Project.swift
//  DDDAuth
//
//  Created by DDD on 9/1/26.
//

import Foundation

import DependencyPackagePlugin
import DependencyPlugin
import ProjectTemplatePlugin

import ProjectDescription

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
