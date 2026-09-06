//
//  AppUpdateUseCaseTest.swift
//  AppUpdateDomainTests
//
//  Created by DDD on 9/4/26.
//

import Testing

@testable import AppUpdateDomain
import AppUpdateDomainInterface

import ComposableArchitecture

@Suite("AppUpdate UseCase")
struct AppUpdateUseCaseTest {
  @Test("업데이트가 필요하면 업데이트 정보를 반환한다")
  func returnsAvailableUpdate() async throws {
    let expected = AppUpdateInfo(
      currentVersion: "1.0.0",
      latestVersion: "1.1.0",
      releaseNotes: "새 기능",
      appStoreUrl: "https://apps.apple.com/app/id1",
      isUpdateAvailable: true
    )

    let result = try await withDependencies {
      $0.appUpdateRepository = AppUpdateRepositoryStub(result: .success(expected))
    } operation: {
      try await AppUpdateUseCaseImpl().checkForUpdate()
    }

    #expect(result == expected)
  }

  @Test("최신 버전이면 nil을 반환한다")
  func returnsNilWhenAlreadyCurrent() async throws {
    let current = AppUpdateInfo(
      currentVersion: "1.1.0",
      latestVersion: "1.1.0",
      releaseNotes: nil,
      appStoreUrl: "https://apps.apple.com/app/id1",
      isUpdateAvailable: false
    )

    let result = try await withDependencies {
      $0.appUpdateRepository = AppUpdateRepositoryStub(result: .success(current))
    } operation: {
      try await AppUpdateUseCaseImpl().checkForUpdate()
    }

    #expect(result == nil)
  }

  @Test("릴리스 노트의 [v x.y.z] 를 표시 버전으로 쓴다")
  func prefersVersionInReleaseNotes() async throws {
    let info = AppUpdateInfo(
      currentVersion: "1.0.0",
      latestVersion: "1.1.0",
      releaseNotes: "[v 1.0.2]\n- 버그 수정",
      appStoreUrl: "https://apps.apple.com/app/id1",
      isUpdateAvailable: true
    )

    let result = try await withDependencies {
      $0.appUpdateRepository = AppUpdateRepositoryStub(result: .success(info))
    } operation: {
      try await AppUpdateUseCaseImpl().checkForUpdate()
    }

    // 서버 원본은 그대로 두고 표시 버전만 노트 값으로 바뀐다
    #expect(result?.displayVersion == "1.0.2")
    #expect(result?.latestVersion == "1.1.0")
  }

  @Test("접두 대괄호가 없는 v x.y.z 도 인식한다")
  func acceptsBareVersionPattern() async throws {
    let info = AppUpdateInfo(
      currentVersion: "1.0.0",
      latestVersion: "1.1.0",
      releaseNotes: "v 2.3.4 릴리스",
      appStoreUrl: "https://apps.apple.com/app/id1",
      isUpdateAvailable: true
    )

    let result = try await withDependencies {
      $0.appUpdateRepository = AppUpdateRepositoryStub(result: .success(info))
    } operation: {
      try await AppUpdateUseCaseImpl().checkForUpdate()
    }

    #expect(result?.displayVersion == "2.3.4")
  }

  @Test("릴리스 노트에 버전이 없으면 latestVersion 을 그대로 쓴다")
  func fallsBackToLatestVersion() async throws {
    let info = AppUpdateInfo(
      currentVersion: "1.0.0",
      latestVersion: "1.1.0",
      releaseNotes: "버그를 고쳤습니다",
      appStoreUrl: "https://apps.apple.com/app/id1",
      isUpdateAvailable: true
    )

    let result = try await withDependencies {
      $0.appUpdateRepository = AppUpdateRepositoryStub(result: .success(info))
    } operation: {
      try await AppUpdateUseCaseImpl().checkForUpdate()
    }

    #expect(result?.displayVersion == "1.1.0")
  }

  @Test("Repository 오류를 그대로 전달한다")
  func forwardsRepositoryError() async {
    await #expect(throws: AppUpdateError.lookupFailed) {
      try await withDependencies {
        $0.appUpdateRepository = AppUpdateRepositoryStub(result: .failure(.lookupFailed))
      } operation: {
        try await AppUpdateUseCaseImpl().checkForUpdate()
      }
    }
  }
}

private struct AppUpdateRepositoryStub: AppUpdateInterface {
  let result: Result<AppUpdateInfo, AppUpdateError>

  func checkForUpdate() async throws(AppUpdateError) -> AppUpdateInfo {
    try result.get()
  }
}
