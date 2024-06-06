import ProjectDescription

let infoPlist: [String: Plist.Value] = [
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
    ]
]

let project = Project(
    name: "DDDAttendance",
    targets: [
        .target(
            name: "DDDAttendance",
            destinations: .iOS,
            product: .app,
            bundleId: "io.DDD.DDDAttendance",
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["DDDAttendance/Sources/**"],
            resources: ["DDDAttendance/Resources/**"],
            entitlements: .file(path: "DDDAttendance/Resources/DDDAttendance.entitlements"),
            dependencies: [
                .external(name: "Then"),
                .external(name: "FlexLayout"),
                .external(name: "PinLayout"),
                .external(name: "ReactorKit"),
                .external(name: "RxCocoa"),
                .external(name: "SnapKit"),
                .external(name: "QRCodeSwift"),
                .external(name: "GoogleSignIn"),
                .external(name: "FirebaseAuth"),
                .external(name: "FirebaseFirestore"),
                .external(name: "FirebaseAnalytics"),
                .external(name: "FirebaseCrashlytics"),
                .external(name: "FirebaseRemoteConfig"),
            ],
            settings: .settings(
                base: ["OTHER_LDFLAGS": "$(inherited) -ObjC"]
            )
        ),
        .target(
            name: "DDDAttendanceTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.DDD.DDDAttendanceTests",
            infoPlist: .default,
            sources: ["DDDAttendance/Tests/**"],
            resources: [],
            dependencies: [.target(name: "DDDAttendance")]
        ),
    ]
)
