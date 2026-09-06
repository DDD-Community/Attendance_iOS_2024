//
//  Project.swift
//  FeatureAssembly
//
//  Created by DDD on 9/4/26.
//

import DependencyPlugin
import DependencyPackagePlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "FeatureAssembly",
  bundleId: .appBundleID(name: ".FeatureAssembly"),
  product: .staticFramework,
  settings: .moduleSettings,
  dependencies: [
    // 동적 하위 모듈의 DependencyKey.liveValue를 앱에 링크한다.
    .domainAssembly,
    .feature(.auth),
    .feature(.management),
    .feature(.member),
    .feature(.onBoarding),
    .feature(.profile),
    .feature(.web),
    .feature(.sharedUI),
    .service(.auth, .interface),
    .core(.logger),
    .ui(.animation),
    .SPM.dependencies
  ],
  sources: ["Sources/**"]
)
