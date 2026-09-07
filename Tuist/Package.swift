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
        "OTHER_SWIFT_FLAGS": "$(inherited) -module-alias Sharing=DDDPointFreeSharing"
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
    // SPM 의존성은 정적으로 링크해 framework 내부에 중첩 Frameworks 폴더가
    // 생성되지 않도록 한다(App Store Connect 90206 방지).
    "Firebase": .staticFramework,
    "FirebaseCore": .staticFramework,
    "FirebaseCoreExtension": .staticFramework,
    "FirebaseCoreInternal": .staticFramework,
    "FirebaseInstallations": .staticFramework,
    "FirebaseSessions": .staticFramework,
    "FirebaseSessionsObjC": .staticFramework,
    "FirebaseCrashlytics": .staticFramework,
    "FirebaseCrashlyticsSwift": .staticFramework,
    "FirebaseRemoteConfigInterop": .staticFramework,
    "FirebaseAppCheck": .staticFramework,
    "FirebaseAppCheckInterop": .staticFramework,
    "GoogleDataTransport": .staticFramework,
    "nanopb": .staticFramework,
    "AppCheckCore": .staticFramework,
    "FBLPromises": .staticFramework,
    "Promises": .staticFramework,
    "GoogleUtilities-AppDelegateSwizzler": .staticFramework,
    "GoogleUtilities-Environment": .staticFramework,
    "GoogleUtilities-Logger": .staticFramework,
    "GoogleUtilities-MethodSwizzler": .staticFramework,
    "GoogleUtilities-Network": .staticFramework,
    "GoogleUtilities-NSData": .staticFramework,
    "GoogleUtilities-Reachability": .staticFramework,
    "GoogleUtilities-UserDefaults": .staticFramework,

    // GoogleSignIn 전이 의존성도 정적으로 링크한다.
    "AppAuth": .staticFramework,
    "AppAuthCore": .staticFramework,
    "GTMAppAuth": .staticFramework,
    "GTMSessionFetcherCore": .staticFramework,

    "ComposableArchitecture": .staticFramework,
    "IdentifiedCollections": .staticFramework,
    "TCAFlow": .staticFramework,
    "IssueReporting": .staticFramework,
    "IssueReportingPackageSupport": .staticFramework,
    "XCTestDynamicOverlay": .staticFramework,
    "Clocks": .staticFramework,
    "CombineSchedulers": .staticFramework,
    "ConcurrencyExtras": .staticFramework,
    "SDWebImageSwiftUI": .staticFramework,
    "SDWebImage": .staticFramework,

    // ── 경고에 떴지만 productTypes에 없어서 기본값(static)으로 중복되던 전이 의존성 ──
    "Dependencies": .staticFramework,
    "DependenciesMacros": .staticFramework,
    "PerceptionCore": .staticFramework,
    "Perception": .staticFramework,
    // Sharing과 SQLiteData는 여러 동적 DDD 모듈에서 사용하므로 단일 런타임으로 공유한다.
    // 버전 마커는 정적으로 링크해 앱이 Sharing1/2.framework를 찾지 않게 한다.
    "Sharing": .staticFramework,
    "Sharing1": .staticFramework,
    "Sharing2": .staticFramework,
    "SQLiteData": .staticFramework,
    "GRDB": .staticFramework,
    "GRDBSQLite": .staticFramework,
    "GRDB_GRDB": .staticFramework,
    "StructuredQueries": .staticFramework,
    "StructuredQueriesCore": .staticFramework,
    "StructuredQueriesSQLite": .staticFramework,
    "StructuredQueriesSQLiteCore": .staticFramework,
    "SwiftNavigation": .staticFramework,
    "SwiftUINavigation": .staticFramework,
    "CasePaths": .staticFramework,
    "Alamofire": .staticFramework,

    // GoogleSignIn 관련
    "GoogleSignIn": .staticFramework,
    "GoogleSignInSwift": .staticFramework,
    "GTMSessionFetcher": .staticFramework
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
