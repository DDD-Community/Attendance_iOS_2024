// swift-tools-version: 6.2
//
//  Package.swift
//  Manifests
//
//  Created by DDD on 9/4/26.
//

@preconcurrency import PackageDescription

#if TUIST
@preconcurrency import ProjectDescription

private extension Settings {
  /// 외부 패키지 타깃이 앱과 동일한 빌드 configuration을 사용하도록 맞춘다.
  static var baseSettings: Settings {
    return .settings(
      base: [
        "OTHER_SWIFT_FLAGS": "$(inherited) -module-alias Sharing=DDDPointFreeSharing",
        // Swift 표준 라이브러리는 최종 앱에만 임베드한다. 프레임워크 안에
        // Frameworks/libswift_*.dylib가 생기면 App Store 업로드가 거부된다.
        "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES": "NO"
      ],
      configurations: [
        .debug(name: "Stage", settings: ["ONLY_ACTIVE_ARCH": "YES"]),
        .release(name: "Prod", settings: ["ONLY_ACTIVE_ARCH": "NO"])
      ]
    )
  }
}

let packageSettings = PackageSettings(
  productTypes: [
    // Release/TestFlight는 cache-profile none으로 생성해 SPM 소스를 직접 빌드한다.
    // 리소스(PrivacyInfo.xcprivacy 등)를 포함한 제품은 동적으로 유지하고,
    // 나머지는 정적으로 링크해 framework 내부 중첩 Frameworks를 최소화한다.
    // (App Store Connect 90206 방지)
    "Firebase": .framework,
    "FirebaseCore": .framework,
    "FirebaseCoreExtension": .framework,
    "FirebaseCoreInternal": .framework,
    "FirebaseInstallations": .framework,
    "FirebaseSessions": .framework,
    "FirebaseSessionsObjC": .framework,
    "FirebaseCrashlytics": .framework,
    "FirebaseCrashlyticsSwift": .framework,
    "FirebaseRemoteConfigInterop": .framework,
    "FirebaseAppCheck": .framework,
    "FirebaseAppCheckInterop": .framework,
    "GoogleDataTransport": .framework,
    "nanopb": .framework,
    "AppCheckCore": .staticFramework,
    "FBLPromises": .framework,
    "Promises": .framework,
    "GoogleUtilities-AppDelegateSwizzler": .framework,
    "GoogleUtilities-Environment": .framework,
    "GoogleUtilities-Logger": .framework,
    "GoogleUtilities-MethodSwizzler": .framework,
    "GoogleUtilities-Network": .framework,
    "GoogleUtilities-NSData": .framework,
    "GoogleUtilities-Reachability": .framework,
    "GoogleUtilities-UserDefaults": .framework,

    // GoogleSignIn 전이 의존성도 정적으로 링크한다.
    "AppAuth": .framework,
    "AppAuthCore": .framework,
    "GTMAppAuth": .framework,
    "GTMSessionFetcherCore": .framework,

    "ComposableArchitecture": .framework,
    "IdentifiedCollections": .staticFramework,
    "TCAFlow": .staticFramework,
    "IssueReporting": .framework,
    "IssueReportingPackageSupport": .framework,
    "XCTestDynamicOverlay": .framework,
    "Clocks": .staticFramework,
    "CombineSchedulers": .staticFramework,
    "ConcurrencyExtras": .staticFramework,
    "SDWebImageSwiftUI": .framework,
    "SDWebImage": .framework,

    // ── 경고에 떴지만 productTypes에 없어서 기본값(static)으로 중복되던 전이 의존성 ──
    "Dependencies": .framework,
    "DependenciesMacros": .framework,
    "PerceptionCore": .framework,
    "Perception": .framework,
    // Sharing은 리소스 번들을 포함하므로 동적 framework로 유지한다.
    // 버전 마커만 정적으로 링크해 앱이 Sharing1/2.framework를 찾지 않게 한다.
    "Sharing": .framework,
    "Sharing1": .staticFramework,
    "Sharing2": .staticFramework,
    "SQLiteData": .framework,
    "GRDB": .framework,
    "GRDBSQLite": .framework,
    "GRDB_GRDB": .framework,
    "StructuredQueries": .framework,
    "StructuredQueriesCore": .framework,
    "StructuredQueriesSQLite": .framework,
    "StructuredQueriesSQLiteCore": .framework,
    "SwiftNavigation": .staticFramework,
    "SwiftUINavigation": .staticFramework,
    "CasePaths": .staticFramework,
    "Alamofire": .framework,

    // GoogleSignIn 관련
    "GoogleSignIn": .framework,
    "GoogleSignInSwift": .framework,
    "GTMSessionFetcher": .framework
  ],
  baseSettings: .baseSettings,
  targetSettings: [
    // Xcode 26 XCTest가 먼저 로드하는 Apple private Sharing 모듈과 충돌하지 않도록
    // Point-Free 구현은 별도 Swift module/framework 이름으로 빌드한다.
    "Sharing": .settings(base: [
      "PRODUCT_NAME": "DDDPointFreeSharing"
    ])
  ]
)
#endif
let package = Package(
  name: "DDDAttendance",
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: "12.12.0"),
    .package(url: "https://github.com/google/GoogleSignIn-iOS", exact: "9.2.0"),
    .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", exact: "3.1.4"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.26.2"),
    .package(url: "https://github.com/pointfreeco/sqlite-data", exact: "1.11.0"),
    .package(url: "https://github.com/pointfreeco/swift-structured-queries", exact: "0.36.0"),
    .package(url: "https://github.com/Roy-wonji/TCAFlow.git", exact: "1.1.8"),
    .package(url: "https://github.com/openid/AppAuth-iOS.git", exact: "2.1.0"),
    .package(url: "https://github.com/Alamofire/Alamofire", exact: "5.12.0"),
  ]
)
