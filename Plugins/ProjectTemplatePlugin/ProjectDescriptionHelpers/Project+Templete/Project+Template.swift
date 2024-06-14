//
//  Project+Template.swift
//  MyPlugin
//
//  Created by 서원지 on 1/6/24.
//

import ProjectDescription

public extension Project {
    static func makeAppModule(
        name: String = Environment.appName,
        bundleId: String,
        platform: Platform = .iOS,
        product: Product,
        packages: [Package] = [],
        deploymentTarget: ProjectDescription.DeploymentTargets = Environment.deploymentTarget,
        destinations: ProjectDescription.Destinations = Environment.deploymentDestination,
        settings: ProjectDescription.Settings,
        scripts: [ProjectDescription.TargetScript] = [],
        dependencies: [ProjectDescription.TargetDependency] = [],
        sources: ProjectDescription.SourceFilesList = ["Sources/**"],
        resources: ProjectDescription.ResourceFileElements? = nil,
        infoPlist: ProjectDescription.InfoPlist = .default,
        entitlements: ProjectDescription.Entitlements? = nil,
        schemes: [ProjectDescription.Scheme] = []
    ) -> Project {
        
        let appTarget: Target = .appTarget(
            factory: .init(
                name: name,
                platform: platform,
                bundleId: bundleId,
                deploymentTarget: deploymentTarget,
                destinations:  destinations,
                infoPlist: infoPlist,
                sources:  sources,
                resources: resources,
                entitlements: entitlements,
                dependencies:  dependencies
            ))
        
        let appDevTarget: Target = .appTarget(
            factory: .init(
                name: "\(name)-QA",
                platform: platform,
                bundleId: bundleId,
                deploymentTarget: deploymentTarget,
                destinations:  destinations,
                infoPlist: infoPlist,
                sources:  sources,
                resources: resources,
                entitlements: entitlements,
                dependencies:  dependencies
            ))
        
        let appTestTarget: Target = .appTarget(
            factory: .init(
                name: "\(name)Tests",
                product: .unitTests,
                bundleId: "\(bundleId).\(name)Tests",
                deploymentTarget:  deploymentTarget,
                destinations: destinations,
                infoPlist: .default,
                sources: ["\(name)Tests/Sources/**"],
                dependencies: [.target(name: name)]
            ))
        
        
        let targets = [appTarget, appDevTarget, appTestTarget]
        
        return Project(
            name: name,
            packages: packages,
            settings: settings,
            targets: targets,
            schemes: schemes
        )
    }
}



extension Scheme {
    public static func makeScheme(target: ConfigurationName, name: String) -> Scheme {
        return Scheme.scheme(
            name: name,
            shared: true,
            buildAction: .buildAction(targets: ["\(name)"]),
            testAction: .targets(
                ["\(name)Tests"],
                configuration: target,
                options: .options(coverage: true, codeCoverageTargets: ["\(name)"])
            ),
            runAction: .runAction(configuration: target),
            archiveAction: .archiveAction(configuration: target),
            profileAction: .profileAction(configuration: target),
            analyzeAction: .analyzeAction(configuration: target)
            
        )
        
    }
    
}
