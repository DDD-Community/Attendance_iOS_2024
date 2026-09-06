//
//  Project.swift
//  DDDSharedUI
//
//  Created by DDD on 9/4/26.
//

import Foundation

import DependencyPackagePlugin
import DependencyPlugin
import ProjectTemplatePlugin

import ProjectDescription

let project = Project.makeModule(
  name: "DDDSharedUI",
  bundleId: .appBundleID(name: ".DDDSharedUI"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .ui(.animation),
    .ui(.designKit),
    .core(.coreUI),
    .core(.coreUtility),
    .SPM.composableArchitecture,
  ],
  sources: ["Sources/**"],
  hasTests: true
)
