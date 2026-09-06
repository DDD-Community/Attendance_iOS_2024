//
//  Project.swift
//  FeatureSharedUI
//
//  Created by DDD on 9/1/26.
//

import DependencyPlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "FeatureSharedUI",
  bundleId: .appBundleID(name: ".FeatureSharedUI"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    .service(.accessibility),
    .ui(.sharedUI),
    .domain(.attendance, .interface),
    .domain(.onBoarding, .interface)
  ],
  sources: ["Sources/**"]
)
