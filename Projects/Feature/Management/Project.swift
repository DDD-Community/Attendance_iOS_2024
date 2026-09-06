//
//  Project.swift
//  Management
//
//  Created by DDD on 9/4/26.
//

import Foundation

import DependencyPackagePlugin
import DependencyPlugin
import ProjectTemplatePlugin

import ProjectDescription

let project = Project.makeModule(
  name: "Management",
  bundleId: .appBundleID(name: ".Management"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .service(.accessibility),
    .ui(.sharedUI),
    .feature(.sharedUI),
    .core(.logger),
    .domain(.auth, .interface),
    .domain(.attendance, .interface),
    .domain(.onBoarding, .interface),
    .domain(.profile, .interface),
    .domain(.qrCode, .interface),
    .domain(.schedule, .interface),
    .domain(.vote, .interface)
  ],
  sources: ["Sources/**"],
  hasTests: true,
  hasInterface: true,
  interfaceDependencies: [
    .SPM.composableArchitecture
  ],
  hasDemo: true
)
