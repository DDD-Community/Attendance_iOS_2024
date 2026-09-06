//
//  Project.swift
//  DDDConfig
//

import Foundation

import DependencyPackagePlugin
import DependencyPlugin
import ProjectTemplatePlugin

import ProjectDescription

let project = Project.makeModule(
  name: "DDDConfig",
  bundleId: .appBundleID(name: ".DDDConfig"),
  product: .framework,
  settings: .moduleSettings,
  // 외부 SDK 부팅은 이 모듈만 안다. App 외의 모듈은 여기에 의존하지 않는다.
  dependencies: [
    .SPM.firebaseCore,
    .SPM.firebaseCrashlytics,
  ],
  sources: ["Sources/**"]
)
