import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
    name: "DesignSystem",
    bundleId: .appBundleID(name: ".DesignSystem"),
    product: .staticFramework,
    settings:  .settings(),
    dependencies: [
        .Networking(implements: .Model),
        .Shared(implements: .Utill),
        .Shared(implements: .ThirdParty)
    ],
    sources: ["Sources/**"],
    resources: ["Resources/**", "FontAsset"]
)
