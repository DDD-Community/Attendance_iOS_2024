import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin

let project = Project.makeAppModule(
    name: "Shareds",
    bundleId: .appBundleID(name: ".Shareds"),
    product: .staticFramework,
    settings:  .settings(),
    dependencies: [
        .Shared(implements: .ThirdParty),
        .Shared(implements: .Utill),
        .Shared(implements: .DesignSystem)
    ],
    sources: ["Sources/**"]
)
