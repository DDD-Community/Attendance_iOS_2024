import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
    name: "Utill",
    bundleId: .appBundleID(name: ".Utill"),
    product: .staticFramework,
    settings:  .settings(),
    dependencies: [
        .SPM.composableArchitecture
    ],
    sources: ["Sources/**"]
)
