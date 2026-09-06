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
    // Firebase 체인은 통째로 동적 프레임워크로 올린다.
    // 앱에 .framework 모듈(DDDDesignKit)이 있으면 정적 산출물이 그 경계에서 흡수돼
    // 앱 링크 라인까지 전파되지 않는다. 일부만 올리면 nanopb/FirebaseSessions 심볼이 풀리지 않아
    // 체인 전체를 함께 올려야 한다.
    // 키는 패키지 이름이 아니라 SPM 타깃 이름이다 ("GoogleUtilities" 같은 패키지 이름은 매칭되지 않는다).
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
    "AppCheckCore": .framework,
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

    // GoogleSignIn 전이 의존성은 하나의 동적 링크 경계로 맞춘다.
    // 정적 프레임워크로 생성하면 GoogleSignIn 코드만 앱에 흡수되고
    // AppAuth·GTMAppAuth·GTMSessionFetcher 심볼이 앱 링크 라인에 전파되지 않는다.
    "AppAuth": .framework,
    "AppAuthCore": .framework,
    "GTMAppAuth": .framework,
    "GTMSessionFetcherCore": .framework,

    "ComposableArchitecture": .framework,
    "IdentifiedCollections": .framework,
    "TCAFlow": .framework,
    "IssueReporting": .framework,
    "IssueReportingPackageSupport": .framework,
    "XCTestDynamicOverlay": .framework,
    "Clocks": .framework,
    "CombineSchedulers": .framework,
    "ConcurrencyExtras": .framework,
    "SDWebImageSwiftUI": .framework,
    "SDWebImage": .framework,

    // ── 경고에 떴지만 productTypes에 없어서 기본값(static)으로 중복되던 전이 의존성 ──
    "Dependencies": .framework,
    "DependenciesMacros": .framework,
    "PerceptionCore": .framework,
    "Perception": .framework,
    // Sharing과 SQLiteData는 여러 동적 DDD 모듈에서 사용하므로 단일 런타임으로 공유한다.
    // 버전 마커는 정적으로 링크해 앱이 Sharing1/2.framework를 찾지 않게 한다.
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
    "SwiftNavigation": .framework,
    "SwiftUINavigation": .framework,
    "CasePaths": .framework,
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
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.25.5"),
    .package(url: "https://github.com/pointfreeco/sqlite-data", exact: "1.11.0"),
    .package(url: "https://github.com/pointfreeco/swift-structured-queries", exact: "0.36.0"),
    .package(url: "https://github.com/pointfreeco/swift-case-paths", exact: "1.7.2"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.1.0"),
    .package(url: "https://github.com/Roy-wonji/TCAFlow.git", exact: "1.1.3"),
    .package(url: "https://github.com/openid/AppAuth-iOS.git", exact: "2.1.0"),
    .package(url: "https://github.com/Alamofire/Alamofire", exact: "5.12.0"),
  ]
)
