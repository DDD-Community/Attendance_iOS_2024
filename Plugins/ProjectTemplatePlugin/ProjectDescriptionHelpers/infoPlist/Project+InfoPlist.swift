//
//  Project+InfoPlist.swift
//  Plugins
//
//  Created by DDD on 3/22/25.
//

import Foundation
import ProjectDescription

public extension InfoPlist {
  static let appInfoPlist: Self = .extendingDefault(
    with: InfoPlistDictionary()
      .setUIUserInterfaceStyle("Light")
      .setCFBundleDevelopmentRegion("$(DEVELOPMENT_LANGUAGE)")
      .setCFBundleExecutable("$(EXECUTABLE_NAME)")
      .setCFBundleIdentifier("$(PRODUCT_BUNDLE_IDENTIFIER)")
      .setCFBundleInfoDictionaryVersion("6.0")
      .setCFBundleName("${BUNDLE_DISPLAY_NAME}")
      .setCFBundlePackageType("APPL")
      .setCFBundleShortVersionString(.appVersion())
      .setAppTransportSecurity()
      .setCFBundleURLTypes()
      .setAppUseExemptEncryption(value: false)
      .setCFBundleVersion(.appBuildVersion())
      .setLSRequiresIPhoneOS(true)
      .setUIApplicationSceneManifest([
        "UIApplicationSupportsMultipleScenes": true,
        "UISceneConfigurations": [
          "UIWindowSceneSessionRoleApplication": [
            [
              "UISceneConfigurationName": "Default Configuration",
            ]
          ]
        ]
      ])
      .setUIRequiredDeviceCapabilities(["armv7"])
      .setUISupportedInterfaceOrientations(["UIInterfaceOrientationPortrait"])
      .setNSCameraUsageDescription("QR 코드 인식을 위해 카메라 접근 권한이 필요합니다")
      .setUILaunchScreen()
      .setCalenderUsage("캘린더의 정보를 가져오기 위해서 접근 권한을 허용해주세요")
      .setCFBundleDevelopmentRegion()
      .setGoogleReversedClientID("${REVERSED_CLIENT_ID}")
      .setGoogleClientID("${GOOGLE_CLIENT_ID}")
      .setGoogleClientiOSID("${GOOGLE_IOS_CLIENT_ID}")
      .setGIDClientID("${GOOGLE_CLIENT_ID}")
      .setBaseURL("$(BASE_URL)")
  )
  
  /// Demo 앱용. 모듈 하나만 띄우므로 실제 앱의 권한·OAuth·URL 스킴 설정은 넣지 않는다.
  /// 런치 스크린이 없으면 시뮬레이터가 호환 모드로 letterbox 표시하므로 이는 반드시 둔다.
  static let demoInfoPlist: Self = .extendingDefault(
    with: InfoPlistDictionary()
      .setUIUserInterfaceStyle("Light")
      .setCFBundleDevelopmentRegion("$(DEVELOPMENT_LANGUAGE)")
      .setCFBundleExecutable("$(EXECUTABLE_NAME)")
      .setCFBundleIdentifier("$(PRODUCT_BUNDLE_IDENTIFIER)")
      .setCFBundleInfoDictionaryVersion("6.0")
      .setCFBundlePackageType("APPL")
      .setCFBundleShortVersionString(.appVersion())
      .setCFBundleVersion(.appBuildVersion())
      .setLSRequiresIPhoneOS(true)
      .setUILaunchScreen()
      .setUISupportedInterfaceOrientations(["UIInterfaceOrientationPortrait"])
      .setBaseURL("$(BASE_URL)")
  )

  static let moduleInfoPlist: Self = .extendingDefault(
    with: InfoPlistDictionary()
      .setUIUserInterfaceStyle("Light")
      .setCFBundleDevelopmentRegion("$(DEVELOPMENT_LANGUAGE)")
      .setCFBundleExecutable("$(EXECUTABLE_NAME)")
      .setCFBundleIdentifier("$(PRODUCT_BUNDLE_IDENTIFIER)")
      .setCFBundleInfoDictionaryVersion("6.0")
      .setCFBundlePackageType("APPL")
      .setCFBundleShortVersionString(.appVersion())
      .setBaseURL("$(BASE_URL)")
  )
}
