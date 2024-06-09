//
//  Project+Settings.swift
//  MyPlugin
//
//  Created by 서원지 on 1/6/24.
//

import Foundation
import ProjectDescription

extension Settings {
    public static let appMainSetting: Settings = .settings(
        base: [ "PRODUCT_NAME": "\(Project.Environment.appName)",
                "CFBundleDisplayName" : "\(Project.Environment.appName)",
                "MARKETING_VERSION": .string(.appVersion()),
                "AS_AUTHENTICATION_SERVICES_ENABLED": "YES",
                "PUSH_NOTIFICATIONS_ENABLED":"YES",
                "ENABLE_BACKGROUND_MODES" : "YES",
                "BACKGROUND_MODES" : "remote-notification",
                "ARCHS": "$(ARCHS_STANDARD)",
                "OTHER_LDFLAGS": "$(inherited) -ObjC",
                "CURRENT_PROJECT_VERSION": .string(.appBuildVersion()),
                "CODE_SIGN_IDENTITY": "iPhone Developer",
                "CODE_SIGN_STYLE": "Automatic",
                "VERSIONING_SYSTEM": "apple-generic",
                "DEBUG_INFORMATION_FORMAT": "DWARF with dSYM File"
                ]
        ,configurations: [
            .debug(name: .debug, settings: [
                "PRODUCT_NAME" : "\(Project.Environment.appName)",
                "DISPLAY_NAME" : "\(Project.Environment.appName)",
                "OTHER_LDFLAGS": [
                    "-ObjC","-all_load",
                ],
                "STRIP_STYLE": [
                    "non-global"
                ],
//                "EXCLUDED_ARCHS[sdk=iphonesimulator*]": "arm64"
//                "EXCLUDED_ARCHS": "arm64"
            ]),
            .debug(name: "QA", settings: [
                "PRODUCT_NAME" : "\(Project.Environment.appDevName)",
                "DISPLAY_NAME" : "\(Project.Environment.appDevName)",
                "OTHER_LDFLAGS": [
                    "-ObjC","-all_load",
                ],
                "STRIP_STYLE": [
                    "non-global"
                ],

            ]),
            .release(name: .release, settings: [
//                "DEVELOPMENT_ASSET_PATHS": "\"Resources/Preview Content\"",
                "PRODUCT_NAME" : "\(Project.Environment.appName)" ,
                "DISPLAY_NAME" : "\(Project.Environment.appName)" ,
                "OTHER_LDFLAGS": [
                    "-ObjC","-all_load",
                ],
                "STRIP_STYLE": [
                    "non-global"
                ],

            ])], defaultSettings: .recommended)
    
    public static func appBaseSetting(appName: String) -> Settings {
         let appBaseSetting: Settings = .settings(
            base: ["PRODUCT_NAME": "\(appName)",
                   "MARKETING_VERSION": .string(.appVersion()),
                   "CURRENT_PROJECT_VERSION": .string(.appBuildVersion()),
                   "CODE_SIGN_IDENTITY": "iPhone Developer",
                   "AS_AUTHENTICATION_SERVICES_ENABLED": "YES",
                   "ARCHS": "$(ARCHS_STANDARD)",
                   "VERSIONING_SYSTEM": "apple-generic",
                   "DEBUG_INFORMATION_FORMAT": "DWARF with dSYM File"],
            configurations: [
                .debug(name: .debug, settings: [
                    "PRODUCT_NAME": "\(appName)",
                    "OTHER_LDFLAGS": [
                        "-ObjC","-all_load",
                    ],
                    "STRIP_STYLE": [
                        "non-global"
                    ],
                ]),
                .debug(name: "QA", settings: [
                    "PRODUCT_NAME" : "\(appName)-QA",
    //
                    "OTHER_LDFLAGS": [
                         "-ObjC","-all_load",
                    ],
                    "STRIP_STYLE": [
                        "non-global"
                    ],

                    
                ]),
                .release(name: .release, settings: [
                    "PRODUCT_NAME": "\(appName)",
                    "OTHER_LDFLAGS": [
                        "-ObjC","-all_load"
                    ],
                    "STRIP_STYLE": [
                        "non-global"
                    ],
                ])], defaultSettings: .recommended)
        
        return appBaseSetting
        
    }
    
    
}
