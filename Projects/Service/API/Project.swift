//
//  Project.swift
//  API
//
//  Created by DDD on 9/4/26.
//

import Foundation

import DependencyPackagePlugin
import DependencyPlugin
import ProjectTemplatePlugin

import ProjectDescription

let project = Project.makeModule(
  name: "API",
  bundleId: .appBundleID(name: ".API"),
  product: .framework,
  settings: .moduleSettings,
  dependencies: [],
  sources: ["Sources/**"],
  hasTests: true
)
