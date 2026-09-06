//
//  Project.swift
//  DDDStorage
//
//  Created by DDD on 9/1/26.
//

import Foundation

import DependencyPackagePlugin
import DependencyPlugin
import ProjectTemplatePlugin

import ProjectDescription

let project = Project.makeModule(
  name: "DDDStorage",
  bundleId: .appBundleID(name: ".DDDStorage"),
  product: .framework,
  settings: .moduleSettings,
  dependencies: [.SPM.sqliteData],
  sources: ["Sources/**"],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [
    .SPM.dependencies,
    .SPM.sharing,
    .SPM.sqliteData
  ]
)
