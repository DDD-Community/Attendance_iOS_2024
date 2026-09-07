//
//  Project.swift
//  APIEndpoint
//
//  Created by DDD on 9/4/26.
//

import Foundation

import DependencyPackagePlugin
import DependencyPlugin
import ProjectTemplatePlugin

import ProjectDescription

let project = Project.makeModule(
  name: "APIEndpoint",
  bundleId: .appBundleID(name: ".APIEndpoint"),
  product: .framework,
  settings: .moduleSettings,
  dependencies: [
    .core(.network, .interface),
    .service(.api),
    .domain(.vote, .interface),
    .SPM.alamofire
  ],
  sources: ["Sources/**"],
  hasTests: true
)
