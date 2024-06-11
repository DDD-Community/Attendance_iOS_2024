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
        .SPM.sdwebImage,
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
        .SPM.firebaseAuth,
        .SPM.firebaseFirestore,
        .SPM.firebaseAnalytics,
        .SPM.firebaseCrashlytics,
        .SPM.firebaseRemoteConfig,
        .SPM.keychainAccess
            
    ],
    sources: ["Sources/**"]
)

