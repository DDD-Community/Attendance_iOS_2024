//
//  Project.swift
//  DDDAccessibility
//

import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "DDDAccessibility",
  bundleId: .appBundleID(name: ".DDDAccessibility"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [],
  sources: ["Sources/**"],
  hasTests: true
)
