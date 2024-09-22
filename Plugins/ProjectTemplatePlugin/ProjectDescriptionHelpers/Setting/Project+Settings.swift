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
        base: SettingsDictionary()
            .setProductName(Project.Environment.appName)
            .setCFBundleDisplayName(Project.Environment.appName)
            .setMarketingVersion(.appVersion(version: "1.0.0"))
            .setASAuthenticationServicesEnabled()
            .setPushNotificationsEnabled()
            .setEnableBackgroundModes()
            .setArchs()
            .setOtherLdFlags()
            .setCurrentProjectVersion(.appBuildVersion())
            .setCodeSignIdentity()
            .setCodeSignStyle()
            .setVersioningSystem()
            .setProvisioningProfileSpecifier("match Development io.DDD.DDDAttendance")
            .setDevelopmentTeam(Project.Environment.organizationTeamId)
            .setExplicitlyBuiltModules(true)
            .setDebugInformationFormat(),
      
        
        configurations: [
            .debug(name: .debug, settings: SettingsDictionary()
                .setProductName(Project.Environment.appName)
                .setCFBundleDisplayName(Project.Environment.appName)
                .setOtherLdFlags("-ObjC -all_load")
                .setDebugInformationFormat("non-global")
                .setProvisioningProfileSpecifier("match Development io.DDD.DDDAttendance")
                .setSkipInstall(false)
                .setExplicitlyBuiltModules(true)
            ),
            .debug(name: "QA", settings: SettingsDictionary()
                .setProductName(Project.Environment.appDevName)
                .setCFBundleDisplayName(Project.Environment.appDevName)
                .setOtherLdFlags("-ObjC -all_load")
                .setDebugInformationFormat("non-global")
                .setProvisioningProfileSpecifier("match Development io.DDD.DDDAttendance")
                .setSkipInstall(false)
                .setExplicitlyBuiltModules(true)
            ),
            .release(name: .release, settings: SettingsDictionary()
                .setProductName(Project.Environment.appName)
                .setCFBundleDisplayName(Project.Environment.appName)
                .setOtherLdFlags("-ObjC -all_load")
                .setDebugInformationFormat("non-global")
                .setProvisioningProfileSpecifier("match Development io.DDD.DDDAttendance")
                .setSkipInstall(false)
                .setExplicitlyBuiltModules(true)
            )
        ], defaultSettings: .recommended
    )
    
    public static func appBaseSetting(appName: String) -> Settings {
         let appBaseSetting: Settings = .settings(
            base: SettingsDictionary()
                .setProductName(appName)
                .setMarketingVersion(.appVersion())
                .setCurrentProjectVersion(.appBuildVersion())
                .setCodeSignIdentity()
                .setArchs()
                .setVersioningSystem()
                .setDebugInformationFormat(),
            configurations: [
                .debug(name: .debug, settings: SettingsDictionary()
                    .setProductName(appName)
                    .setOtherLdFlags("-ObjC -all_load")
                    .setStripStyle()
                    .setExplicitlyBuiltModules(true)
                ),
                .debug(name: "QA", settings: SettingsDictionary()
                    .setProductName("\(appName)-QA")
                    .setOtherLdFlags("-ObjC -all_load")
                    .setStripStyle()
                    .setExplicitlyBuiltModules(true)
                       
                ),
                .release(name: .release, settings: SettingsDictionary()
                    .setProductName(appName)
                    .setOtherLdFlags("-ObjC -all_load")
                    .setStripStyle()
                    .setExplicitlyBuiltModules(true)
                         
                )
            ], defaultSettings: .recommended)
        
        return appBaseSetting
        
    }
    
    
}
