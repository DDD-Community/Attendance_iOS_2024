//
//  AppUpdateUseCaseImpl.swift
//  AppUpdateDomain
//
//  Created by DDD on 3/9/26.
//

import AppUpdateDomainInterface
import Foundation
import ComposableArchitecture

public struct AppUpdateUseCaseImpl: AppUpdateUseCaseInterface {
  @Dependency(\.appUpdateRepository) var repository

  public init() {}

  public func checkForUpdate() async throws(AppUpdateError) -> AppUpdateInfo? {
    let updateInfo = try await repository.checkForUpdate()

    // 업데이트가 필요한 경우만 반환
    if updateInfo.isUpdateAvailable {
      return updateInfo.resolvingDisplayVersion()
    }

    return nil
  }
}

private extension AppUpdateInfo {
  /// 릴리스 노트에 적힌 실제 배포 버전을 displayVersion 으로 채운다.
  ///
  /// 스토어의 latestVersion 과 릴리스 노트의 버전이 어긋나는 경우가 있어
  /// 노트에 `[v 1.0.2]` 가 있으면 그쪽을 사용자에게 보여준다.
  /// 화면이 아니라 여기서 정하는 이유는 이게 버전 해석 규칙이기 때문이다.
  /// 예전에는 Splash 리듀서가 NSRegularExpression 을 직접 들고 있어
  /// 다른 화면에서 같은 안내를 띄우려면 규칙을 복사해야 했다.
  func resolvingDisplayVersion() -> AppUpdateInfo {
    AppUpdateInfo(
      currentVersion: currentVersion,
      latestVersion: latestVersion,
      releaseNotes: releaseNotes,
      appStoreUrl: appStoreUrl,
      isUpdateAvailable: isUpdateAvailable,
      displayVersion: Self.extractVersion(from: releaseNotes) ?? latestVersion
    )
  }

  /// `[v 1.0.2]` 또는 `v 1.0.2` 패턴에서 버전을 뽑는다. 없으면 nil.
  static func extractVersion(from releaseNotes: String?) -> String? {
    guard let releaseNotes else { return nil }

    let patterns = [
      #"\[v\s*([0-9]+\.[0-9]+\.[0-9]+)\]"#,
      #"v\s*([0-9]+\.[0-9]+\.[0-9]+)"#
    ]

    for pattern in patterns {
      guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
        continue
      }
      let range = NSRange(releaseNotes.startIndex..., in: releaseNotes)
      guard
        let match = regex.firstMatch(in: releaseNotes, range: range),
        let versionRange = Range(match.range(at: 1), in: releaseNotes)
      else {
        continue
      }
      return String(releaseNotes[versionRange])
    }

    return nil
  }
}
