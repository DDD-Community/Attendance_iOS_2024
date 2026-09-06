//
//  Project.swift
//  DomainAssembly
//
//  Created by DDD on 9/1/26.
//

import DependencyPlugin
import DependencyPackagePlugin
import Foundation
import ProjectDescription
import ProjectTemplatePlugin

let project = Project.makeModule(
  name: "DomainAssembly",
  bundleId: .appBundleID(name: ".DomainAssembly"),
  product: .framework,
  settings: .moduleSettings,
  // 컨텍스트별 Repository와 UseCase 구현을 한곳에서 조립하는 앱 진입 경계.
  dependencies: [
    .core(.logger),
    .core(.storage, .interface),
    .serviceAssembly,
    .domain(.appUpdate),
    .domain(.auth),
    .domain(.attendance),
    .domain(.myPage),
    .domain(.onBoarding),
    .domain(.profile),
    .domain(.qrCode),
    .domain(.schedule),
    .domain(.vote),
    .SPM.dependencies
  ],
  testDependencies: [
    .core(.network, .interface),
    .core(.storage),
    .service(.auth, .interface),
    .service(.apiEndpoint),
    .domain(.appUpdate),
    .domain(.attendance),
    .domain(.auth),
    .domain(.myPage),
    .domain(.onBoarding),
    .domain(.profile),
    .domain(.qrCode),
    .domain(.schedule),
    .domain(.vote),
    .SPM.composableArchitecture,
    .SPM.sqliteData
  ],
  sources: ["Sources/**"],
  hasTests: true
)
