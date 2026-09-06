//
//  AppUpdateDTO+.swift
//  AppUpdateDomain
//
//  Created by DDD on 3/9/26.
//

import Foundation

import AppUpdateDomainInterface

public extension AppStoreInfoDTO {
    func toEntity(currentVersion: String) -> AppUpdateInfo {
        let isUpdateAvailable = isNewerVersion(
            storeVersion: version,
            currentVersion: currentVersion
        )

        return AppUpdateInfo(
            currentVersion: currentVersion,
            latestVersion: version,
            releaseNotes: releaseNotes,
            appStoreUrl: trackViewUrl,
            isUpdateAvailable: isUpdateAvailable
        )
    }

    private func isNewerVersion(storeVersion: String, currentVersion: String) -> Bool {
        return storeVersion.compare(currentVersion, options: .numeric) == .orderedDescending
    }
}
