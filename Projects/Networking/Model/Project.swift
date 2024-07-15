import Foundation
import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin

let project = Project.makeAppModule(
    name: "Model",
    bundleId: .appBundleID(name: ".Model"),
    product: .staticFramework,
    settings:  .settings(),
    dependencies: [
        
    ],
    sources: ["Sources/**"]
)
