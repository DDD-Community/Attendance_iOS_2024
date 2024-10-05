import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
    name: "ThirdParty",
    bundleId: .appBundleID(name: ".ThirdParty"),
    product: .staticFramework,
    settings:  .settings(),
    dependencies: [
        .SPM.composableArchitecture,
        .SPM.concurrencyExtras,
        .SPM.tcaCoordinator,
        .SPM.sdwebImage,
        .SPM.collections,
        .SPM.popupView,
        .SPM.collections,
        .SPM.asyncMoya,
        
        
        //MARK: - 제거 하고 SWIFTUI 로 변경
        .SPM.gifu,
        .SPM.then,
        .SPM.firebaseAuth,
        .SPM.flexLayout,
        .SPM.pinLayout,
        .SPM.reactorKit,
        .SPM.rxCocoa,
        .SPM.snapKit,
        .SPM.qrCodeSwift,
        .SPM.googleSignIn,
        .SPM.keychainAccess,
        
        .SPM.firebaseAuth,
        .SPM.firebaseFirestore,
        .SPM.firebaseAnalytics,
        .SPM.firebaseCrashlytics,
        .SPM.firebaseRemoteConfig,
        .SPM.firebaseDatabase,
    ],
    sources: ["Sources/**"]
)

