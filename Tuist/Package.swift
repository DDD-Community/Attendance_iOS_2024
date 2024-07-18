// swift-tools-version: 5.9
@preconcurrency import PackageDescription

#if TUIST
@preconcurrency import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "FirebaseCore": .staticLibrary,
            "FirebaseAuth": .staticLibrary,
            "FirebaseFirestore": .staticLibrary,
            "FirebaseAnalytics": .staticLibrary,
            "FirebaseCrashlytics": .staticLibrary,
            "FirebaseRemoteConfig": .staticLibrary
        ]
    )
#endif

let package = Package(
    name: "DDDAttendance",
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.7.0"),
        .package(url: "https://github.com/layoutBox/FlexLayout", from: "2.0.7"),
        .package(url: "https://github.com/layoutBox/PinLayout", from: "1.10.5"),
        .package(url: "https://github.com/ReactorKit/ReactorKit", from: "3.2.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.27.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "7.1.0"),
        .package(url: "https://github.com/EFPrefix/EFQRCode.git", from: "6.2.2"),
        .package(url: "https://github.com/devxoul/Then", from: "3.0.0"),
        .package(url: "http://github.com/pointfreeco/swift-composable-architecture", from: "1.11.2"),
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.0.0"),
        .package(url: "https://github.com/kaishin/Gifu.git", from: "3.4.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2"),
        .package(url: "https://github.com/exyte/PopupView.git", from: "2.10.4"),
        .package(url: "https://github.com/pointfreeco/swift-concurrency-extras.git", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-collections.git", branch: "main")
      
        
    ]
)
