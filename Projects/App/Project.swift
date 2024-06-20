//
//  Project.swift
//  Manifests
//
//  Created by 서원지 on 6/7/24.
//

import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin


let infoPlist: [String: ProjectDescription.Plist.Value] = [
    "UILaunchStoryboardName": "LaunchScreen.storyboard",
    "UIApplicationSceneManifest": [
        "UIApplicationSupportsMultipleScenes": false,
        "UISceneConfigurations": [
            "UIWindowSceneSessionRoleApplication": [
                [
                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate",
                    "UISceneConfigurationName": "Default Configuration"
                ]
            ]
        ]
    ],
    "GIDClientID": "882277748169-ouegejt3kc6jo5enbfjmmre2nnbthj82.apps.googleusercontent.com",
    "CFBundleURLTypes": [
        ["CFBundleURLSchemes": ["com.googleusercontent.apps.882277748169-ouegejt3kc6jo5enbfjmmre2nnbthj82"]]
    ],
    "NSCameraUsageDescription": "We need access to the camera to take photos."
]

let project = Project.makeAppModule(
    name: Project.Environment.appName,
    bundleId: .mainBundleID(),
    product: .app,
    settings: .appMainSetting,
    scripts: [],
    dependencies: [
        .Shared(implements: .Shareds)
    ],
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    infoPlist: .file(path: "../Support/Info.plist"),
    entitlements: .file(path: "../Entitlements/DDDAttendance.entitlements")
)
