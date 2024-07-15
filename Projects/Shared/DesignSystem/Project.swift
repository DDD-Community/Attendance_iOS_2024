import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin

let project = Project.makeAppModule(
    name: "DesignSystem",
    bundleId: .appBundleID(name: ".DesignSystem"),
    product: .staticFramework,
    settings:  .settings(),
    dependencies: [
        .Networking(implements: .Model)
    ],
    sources: ["Sources/**"],
    resources: ["Resources/**", "FontAsset"]
)
