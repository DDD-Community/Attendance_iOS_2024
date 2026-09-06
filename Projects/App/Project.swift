//
//  Project.swift
//  Manifests
//
//  Created by DDD on 6/7/24.
//

import DependencyPackagePlugin
import DependencyPlugin
import ProjectTemplatePlugin

import ProjectDescription

let project = Project.makeAppModule(
  name: Project.Environment.appName,
  bundleId: .mainBundleID(),
  product: .app,
  settings: .appMainSetting,
  scripts: [],
  // App은 FeatureAssembly의 composition root 하나만 호출한다.
  dependencies: [
    .featureAssembly,
    .service(.config),
    .SPM.composableArchitecture,
    .SPM.issueReporting,
    .SPM.tcaFlow,
  ],
  sources: ["Sources/**"],
  resources: ["Resources/**"],
  infoPlist: .appInfoPlist,
  entitlements: .file(path: "../../Entitlements/DDDAttendance.entitlements"),
  hasTests: true
)
