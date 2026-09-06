//
//  Project+Template.swift
//  MyPlugin
//
//  Created by DDD on 1/6/24.
//

import ProjectDescription

// MARK: - Suppress Warnings Setting

private let suppressWarningsSettings: ProjectDescription.Settings = .settings(
  base: [
    // Xcode 26의 ld가 제거한 -no_warn_empty_source_files/-no_warn_no_symbols를
    // 오래된 xcconfig에서 상속하지 않도록 타깃 수준에서 안전한 플래그만 사용한다.
    "OTHER_LDFLAGS": "-w -Wl,-no_warn_unused_dylibs -dead_strip",
    "OTHER_SWIFT_FLAGS": "$(inherited) -suppress-warnings -module-alias Sharing=DDDPointFreeSharing"
  ],
  configurations: XCConfig.configurations
)

public extension Project {
  static func makeAppModule(
    name: String = Environment.appName,
    bundleId: String,
    platform _: Platform = .iOS,
    product: Product,
    packages: [Package] = [],
    deploymentTarget: ProjectDescription.DeploymentTargets = Environment.deploymentTarget,
    destinations: ProjectDescription.Destinations = Environment.deploymentDestination,
    settings: ProjectDescription.Settings,
    scripts: [ProjectDescription.TargetScript] = [],
    dependencies: [ProjectDescription.TargetDependency] = [],
    testDependencies: [ProjectDescription.TargetDependency] = [],
    sources _: ProjectDescription.SourceFilesList = ["Sources/**"],
    resources: ProjectDescription.ResourceFileElements? = nil,
    infoPlist: ProjectDescription.InfoPlist = .default,
    entitlements: ProjectDescription.Entitlements? = nil,
    schemes: [ProjectDescription.Scheme] = [],
    hasTests: Bool = false
  ) -> Project {
    let appTarget: Target = .target(
      name: name,
      destinations: destinations,
      product: product,
      bundleId: bundleId,
      deploymentTargets: deploymentTarget,
      infoPlist: infoPlist,
      buildableFolders: resources != nil ? ["Sources", "Resources"] : ["Sources"],
      entitlements: entitlements,
      scripts: scripts,
      dependencies: dependencies,
      settings: suppressWarningsSettings
    )

    // 단일 타깃 + 다중 config 구조.
    // 예전에는 환경별 타깃을 복제했지만, 타깃은 name 만 다르고
    // 나머지가 전부 동일해 불필요했다. 환경 분기는 config(xcconfig)와 스킴으로만 한다.
    var targets: [Target] = [appTarget]

    if hasTests {
      let appTestTarget: Target = .target(
        name: "\(name)Tests",
        destinations: destinations,
        product: .unitTests,
        bundleId: "\(bundleId).\(name)Tests",
        deploymentTargets: deploymentTarget,
        infoPlist: .default,
        // 테스트 플랜은 Tests 루트에 두되 test bundle의 리소스로 복사하지 않는다.
        // 실제 Swift Testing 소스만 동기화하면 workspace test plan이 다른 프로젝트의
        // 테스트 타깃을 안정적으로 참조할 수 있다.
        buildableFolders: ["Tests/Sources"],
        dependencies: [.target(name: name)] + testDependencies,
        settings: suppressWarningsSettings
      )
      targets.append(appTestTarget)
    }

    return Project(
      name: name,
      options: .options(
        automaticSchemesOptions: .enabled(codeCoverageEnabled: true),
        defaultKnownRegions: ["en", "ko"],
        developmentRegion: "ko"
      ),
      packages: packages,
      settings: settings,
      targets: targets,
      schemes: schemes.isEmpty ? appEnvironmentSchemes(name: name, hasTests: hasTests) : schemes,
      fileHeaderTemplate: .default,
      additionalFiles: hasTests ? ["Tests/*.xctestplan"] : []
    )
  }

  /// 앱 프로젝트를 단독으로 열 때 사용하는 배포 스킴.
  /// Stage 스킴은 workspace에서 전체 모듈 테스트와 함께 정의하므로 여기서 중복 생성하지 않는다.
  private static func appEnvironmentSchemes(name: String, hasTests: Bool) -> [Scheme] {
    func envScheme(_ schemeName: String, config: ConfigurationName) -> Scheme {
      return .scheme(
        name: schemeName,
        shared: true,
        buildAction: .buildAction(
          targets: [.target(name)],
          postActions: [
            .executionAction(
              title: "Inspect Build",
              scriptText: "[ -z \"${SRCROOT:-}\" ] || $HOME/.local/bin/mise x -C \"$(git -C \"$SRCROOT\" rev-parse --show-toplevel)\" -- tuist inspect build",
              target: .target(name)
            )
          ],
          runPostActionsOnFailure: true
        ),
        testAction: hasTests ? .targets(
          [.testableTarget(target: .target("\(name)Tests"))],
          configuration: config,
          postActions: [
            .executionAction(
              title: "Inspect Test",
              scriptText: "[ -z \"${SRCROOT:-}\" ] || $HOME/.local/bin/mise x -C \"$(git -C \"$SRCROOT\" rev-parse --show-toplevel)\" -- tuist inspect test",
              target: .target(name)
            )
          ],
          options: .options(coverage: true)
        ) : nil,
        runAction: .runAction(configuration: config),
        archiveAction: .archiveAction(configuration: config),
        profileAction: .profileAction(configuration: config),
        analyzeAction: .analyzeAction(configuration: config)
      )
    }
    return [
      envScheme("\(name)-Prod", config: .prod)
    ]
  }

  static func makeModule(
    name: String = Environment.appName,
    bundleId: String,
    platform _: Platform = .iOS,
    product: Product,
    packages: [Package] = [],
    deploymentTarget: ProjectDescription.DeploymentTargets = Environment.deploymentTarget,
    destinations: ProjectDescription.Destinations = Environment.deploymentDestination,
    settings: ProjectDescription.Settings,
    scripts: [ProjectDescription.TargetScript] = [],
    dependencies: [ProjectDescription.TargetDependency] = [],
    testDependencies: [ProjectDescription.TargetDependency] = [],
    sources _: ProjectDescription.SourceFilesList = ["Sources/**"],
    resources: ProjectDescription.ResourceFileElements? = nil,
    infoPlist: ProjectDescription.InfoPlist = .default,
    entitlements: ProjectDescription.Entitlements? = nil,
    schemes: [ProjectDescription.Scheme] = [],
    hasTests: Bool = false,
    hasInterface: Bool = false,
    interfaceDependencies: [ProjectDescription.TargetDependency] = [],
    hasTesting: Bool = false,
    testingDependencies: [ProjectDescription.TargetDependency] = [],
    hasDemo: Bool = false,
    demoDependencies: [ProjectDescription.TargetDependency] = []
  ) -> Project {
    // Interface 타깃은 Interface/ 폴더가 실제로 있을 때만 만든다(buildableFolders 는 폴더가 없으면 generate 실패).
    let interfaceTarget: Target? = hasInterface ? .target(
      name: "\(name)Interface",
      destinations: destinations,
      product: product,
      bundleId: "\(bundleId)Interface",
      deploymentTargets: deploymentTarget,
      infoPlist: .default,
      buildableFolders: ["Interface"],
      dependencies: interfaceDependencies,
      settings: suppressWarningsSettings
    ) : nil

    let appTarget: Target = .target(
      name: name,
      destinations: destinations,
      product: product,
      bundleId: bundleId,
      deploymentTargets: deploymentTarget,
      infoPlist: infoPlist,
      buildableFolders: resources != nil ? ["Sources", "Resources"] : ["Sources"],
      entitlements: entitlements,
      scripts: scripts,
      // 구현은 자기 Interface 를 항상 의존한다.
      dependencies: (hasInterface ? [.target(name: "\(name)Interface")] : []) + dependencies,
      settings: suppressWarningsSettings
    )

    var targets: [Target] = interfaceTarget.map { [$0, appTarget] } ?? [appTarget]

    // Testing: Interface 를 구현한 목/더블. 구현이 아니라 Interface 에만 의존해야
    // 다른 모듈 테스트가 구현을 끌고 오지 않고 재사용할 수 있다.
    if hasTesting {
      targets.append(.target(
        name: "\(name)Testing",
        destinations: destinations,
        product: product,
        bundleId: "\(bundleId)Testing",
        deploymentTargets: deploymentTarget,
        infoPlist: .default,
        buildableFolders: ["Testing"],
        dependencies: (hasInterface ? [.target(name: "\(name)Interface")] : [.target(name: name)])
          + testingDependencies,
        settings: suppressWarningsSettings
      ))
    }

    // Demo: 이 모듈 하나만 띄우는 단독 실행 앱. Demo/ 폴더가 실제로 있을 때만 만든다
    // (buildableFolders 는 폴더가 없으면 generate 가 실패한다).
    // 앱 전체를 빌드하지 않고 피처 하나를 시뮬레이터에서 확인하려는 용도이고,
    // tuist share 로 Previews 에 올려 링크로 넘기는 대상이기도 하다.
    if hasDemo {
      targets.append(.target(
        name: "\(name)Demo",
        destinations: destinations,
        product: .app,
        bundleId: "\(bundleId)Demo",
        deploymentTargets: deploymentTarget,
        infoPlist: .demoInfoPlist,
        buildableFolders: ["Demo"],
        dependencies: [.target(name: name)] + demoDependencies,
        settings: suppressWarningsSettings
      ))
    }

    if hasTests {
      let appTestTarget: Target = .target(
        name: "\(name)Tests",
        destinations: destinations,
        product: .unitTests,
        bundleId: "\(bundleId).\(name)Tests",
        deploymentTargets: deploymentTarget,
        infoPlist: .default,
        buildableFolders: ["Tests"],
        // 모듈 테스트는 별도 앱 호스트 없이 로직 테스트로 실행한다.
        // Testing 이 있으면 테스트가 그 목을 그대로 쓴다.
        dependencies: [
          .target(name: name)
        ] + testDependencies + (hasTesting ? [.target(name: "\(name)Testing")] : []),
        settings: suppressWarningsSettings
      )
      targets.append(appTestTarget)
    }

    let generatedSchemes: [Scheme]
    let projectOptions: Project.Options
    if hasDemo {
      // 자동 스킴은 구현/Interface/Demo를 하나의 BuildAction에 묶는다.
      // 그 결과 일반 모듈 빌드와 Xcode의 workspace build-info 수집까지 Demo 앱을
      // 따라가므로, Demo가 있는 프로젝트는 실행 목적별 스킴을 명시적으로 분리한다.
      generatedSchemes = schemes + [
        .module(name: name, hasTests: hasTests),
        .demo(name: "\(name)Demo")
      ]
      projectOptions = .options(
        automaticSchemesOptions: .disabled,
        defaultKnownRegions: ["en", "ko"],
        developmentRegion: "ko"
      )
    } else {
      generatedSchemes = schemes
      projectOptions = .options(
        automaticSchemesOptions: .enabled(codeCoverageEnabled: true),
        defaultKnownRegions: ["en", "ko"],
        developmentRegion: "ko"
      )
    }

    return Project(
      name: name,
      // tuist test 는 모듈별 자동 생성 스킴으로 도는데, 여기서 커버리지를 켜지 않으면
      // 결과 번들에 커버리지가 담기지 않아 리포트가 비어 나온다.
      options: projectOptions,
      packages: packages,
      settings: settings,
      targets: targets,
      schemes: generatedSchemes,
      fileHeaderTemplate: .default
    )
  }
}
