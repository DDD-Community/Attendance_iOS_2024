//
//  Project.swift
//  AttendanceDomain
//
//  Created by DDD on 9/4/26.
//

import DependencyPackagePlugin
import DependencyPlugin
import ProjectTemplatePlugin

import ProjectDescription

let project = Project.makeModule(
  name: "AttendanceDomain",
  bundleId: .appBundleID(name: ".AttendanceDomain"),
  product: .framework,
  settings: .moduleSettings,
  dependencies: [
    .serviceAssembly,
    .domain(.onBoarding, .interface),
    .SPM.dependencies
  ],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [
    .domain(.onBoarding, .interface),
    .domain(.profile, .interface),
    .SPM.dependencies,
    .SPM.composableArchitecture
  ]
)
