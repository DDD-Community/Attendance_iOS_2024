//
//  Project.swift
//  DDDAccessibility
//

import Foundation

import DependencyPlugin
import ProjectTemplatePlugin

import ProjectDescription

let project = Project.makeModule(
  name: "DDDAccessibility",
  bundleId: .appBundleID(name: ".DDDAccessibility"),
  product: .framework,
  settings: .moduleSettings,
  dependencies: [],
  sources: ["Sources/**"],
  hasTests: true
)
