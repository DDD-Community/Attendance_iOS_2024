//
//  Project.swift
//  DDDCoreUtility
//
//  Created by DDD on 9/4/26.
//

import Foundation

import DependencyPackagePlugin
import DependencyPlugin
import ProjectTemplatePlugin

import ProjectDescription

let project = Project.makeModule(
    name: "DDDCoreUtility",
    bundleId: .appBundleID(name: ".DDDCoreUtility"),
    product: .framework,
    settings: .moduleSettings,
    dependencies: [
        .SPM.composableArchitecture,
    ],
    sources: ["Sources/**"],
    hasTests: true
)
