//
//  Project+Settings.swift
//  MyPlugin
//
//  Created by DDD on 1/6/24.
//

import Foundation
import ProjectDescription

extension Settings {
  private static func commonSettings(
    appName: String,
    displayName: String,
    provisioningProfile: String,
    setSkipInstall: Bool
  ) -> SettingsDictionary {
    return SettingsDictionary()
      .setProductName(appName)
      .setCFBundleDisplayName(displayName)
      // Assembly bootstrap이 필요한 Swift conformance를 명시적으로 보존하므로
      // 모든 정적 오브젝트를 강제로 링크하는 -all_load는 사용하지 않는다.
      .setOtherLdFlags("$(inherited) -ObjC -w -Wl,-no_warn_unused_dylibs -dead_strip")
      .setDebugInformationFormat("dwarf-with-dsym")
      .setProvisioningProfileSpecifier(provisioningProfile)
      .setSkipInstall(setSkipInstall)
      .setCFBundleDevelopmentRegion("ko")
      .setSuppressAllWarnings()
  }

  public static let appMainSetting: Settings = .settings(
    base: SettingsDictionary()
      .setProductName(Project.Environment.appName)
      .setCFBundleDisplayName(Project.Environment.appName)
      .setMarketingVersion(.appVersion())
      .setASAuthenticationServicesEnabled()
      .setPushNotificationsEnabled()
      .setEnableBackgroundModes()
      .setArchs()
      .setOtherLdFlags()
      .setCurrentProjectVersion(.appBuildVersion())
      .setCodeSignIdentity()
      .setCodeSignStyle()
      .setSwiftVersion("6.0")
      .setVersioningSystem()
      .setProvisioningProfileSpecifier("match Development \(Project.Environment.bundlePrefix)")
      .setDevelopmentTeam(Project.Environment.organizationTeamId)
      .setCFBundleDevelopmentRegion()
      .setDebugInformationFormat()
      .setSuppressAllWarnings(),
    configurations: BuildEnvironment.allCases.map { environment in
      let isStage = environment == .stage
      let settings = commonSettings(
        appName: isStage ? Project.Environment.appStageName : Project.Environment.appProdName,
        displayName: Project.Environment.appName,
        provisioningProfile: isStage
          ? "match Development \(Project.Environment.bundlePrefix)"
          : "match AppStore \(Project.Environment.bundlePrefix)",
        setSkipInstall: false
      )
      .merging(environment.buildSettings) { _, environmentValue in environmentValue }

      return environment.isDebug
        ? .debug(
          name: environment.configurationName,
          settings: settings,
          xcconfig: environment.xcconfigPath
        )
        : .release(
          name: environment.configurationName,
          settings: settings,
          xcconfig: environment.xcconfigPath
        )
    },
    defaultSettings: .recommended
  )
}

// MARK: - Settings Extensions

public extension Settings {
  /// 모듈 기본 설정 — 앱과 동일한 Stage/Prod 환경 목록을 사용한다.
  static var moduleSettings: Settings {
    return .settings(configurations: XCConfig.configurations)
  }

  static func repositoryBaseSettings() -> Settings {
    return .settings(
      base: [
        "IPHONEOS_DEPLOYMENT_TARGET": "18.0",
        "OTHER_SWIFT_FLAGS": "$(inherited) -suppress-warnings -module-alias Sharing=DDDPointFreeSharing"
      ],
      configurations: XCConfig.configurations
    )
  }

  static func repositoryTestSettings() -> Settings {
    return .settings(
      base: [
        "IPHONEOS_DEPLOYMENT_TARGET": "18.0",
        "OTHER_SWIFT_FLAGS": "$(inherited) -suppress-warnings -module-alias Sharing=DDDPointFreeSharing",
        "ENABLE_TESTING_SEARCH_PATHS": "YES",
        "SWIFT_TESTING": "YES"
      ],
      configurations: XCConfig.configurations
    )
  }
}
