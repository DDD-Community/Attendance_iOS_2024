//
//  AppUpdateRepositoryImpl.swift
//  AppUpdateDomain
//
//  Created by DDD on 3/9/26.
//

import Foundation

import AppUpdateDomainInterface
import DDDCoreLogger

public final class AppUpdateRepositoryImpl: AppUpdateInterface {
    private let urlSession: URLSession
    private let bundleId: String

    public init(
        urlSession: URLSession = .shared,
        bundleId: String? = nil
    ) {
        self.urlSession = urlSession
        self.bundleId = bundleId ?? Bundle.main.bundleIdentifier ?? ""
    }

    public func checkForUpdate() async throws(AppUpdateError) -> AppUpdateInfo {
        guard !bundleId.isEmpty else {
            throw .invalidBundleId
        }

        let currentVersion = getCurrentAppVersion()
        let appStoreInfo = try await fetchAppStoreInfo()

        return appStoreInfo.toEntity(currentVersion: currentVersion)
    }

    // MARK: - Private Methods

    private func getCurrentAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private func getCurrentAppLanguage() -> String {
        // 1. 현재 Locale의 언어 코드 확인
        if let languageCode = Locale.current.language.languageCode?.identifier {
            return languageCode
        }

        // 2. 시스템 선호 언어 확인
        if let preferredLanguage = NSLocale.preferredLanguages.first {
            let language = String(preferredLanguage.prefix(2))
            return language
        }

        // 3. Bundle의 기본 언어 확인
        if let bundleLanguage = Bundle.main.preferredLocalizations.first {
            let language = String(bundleLanguage.prefix(2))
            return language
        }

        // 4. 최종 fallback - 영어
        return "en"
    }

    private func fetchAppStoreInfo() async throws(AppUpdateError) -> AppStoreInfoDTO {
        let currentLanguage = getCurrentAppLanguage()
        DDDLogger.debug("[AppUpdate] Current app language: \(currentLanguage)", category: .network)

        // 언어에 따른 우선순위 결정
        let primaryCountry = currentLanguage == "ko" ? "kr" : "us"
        let fallbackCountry = currentLanguage == "ko" ? "us" : "kr"

        // 우선 스토어 시도
        if let result = try? await fetchAppStoreInfo(country: primaryCountry) {
            DDDLogger.debug("[AppUpdate] Using \(primaryCountry) store result", category: .network)
            return result
        }

        // 폴백 스토어 시도
        DDDLogger.debug("[AppUpdate] \(primaryCountry) store failed, trying \(fallbackCountry)", category: .network)
        let fallbackResult = try await fetchAppStoreInfo(country: fallbackCountry)
        DDDLogger.debug("[AppUpdate] Using \(fallbackCountry) store as fallback", category: .network)
        return fallbackResult
    }

    private func fetchAppStoreInfo(country: String) async throws(AppUpdateError) -> AppStoreInfoDTO {
        let urlString = "https://itunes.apple.com/lookup?bundleId=\(bundleId)&country=\(country)"
        guard let url = URL(string: urlString) else {
            throw .invalidBundleId
        }

        let data: Data
        do {
            (data, _) = try await urlSession.data(from: url)
        } catch {
            DDDLogger.error("[AppUpdate] Network error for \(country): \(error.localizedDescription)", category: .network)
            throw .lookupFailed
        }

        let response: AppUpdateResponseDTO
        do {
            response = try JSONDecoder().decode(AppUpdateResponseDTO.self, from: data)
        } catch {
            DDDLogger.error("[AppUpdate] Decoding error for \(country): \(error.localizedDescription)", category: .network)
            throw .invalidResponse
        }

        guard let appInfo = response.results.first else {
            throw .appNotFound
        }
        return appInfo
    }
}
