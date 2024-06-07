import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin

let project = Project.makeAppModule(
    name: "Shared",
    bundleId: .appBundleID(name: ".Shared"),
    product: .staticFramework,
    settings:  .settings(),
    dependencies: [
        .Shared(implements: .ThirdParty)
    ],
    sources: ["Sources/**"]
)
