//
//  AppDIContainer.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/8/24.
//

import Foundation
import DiContainer

public final class AppDIContainer {
    public static let shared: AppDIContainer = .init()

    private let diContainer: DependencyContainer = .live

    private init() {
    }

    public func registerDependencies() async {
        await registerRepositories()
        await registerUseCases()
    }

    // MARK: - Use Cases
    private func registerUseCases() async {
        await registerFireStoreUseCase()
        await registerQrCodeUseCase()
    }

    private func registerFireStoreUseCase() async {
        await diContainer.register(FireStoreUseCaseProtocol.self) {
            guard let repository = self.diContainer.resolve(FireStoreRepositoryProtocol.self) else {
                assertionFailure("FirestoreRepositoryProtocol must be registered before registering FirestoreUseCaseProtocol")
                return FireStoreUseCase(repository: DefaultFireStoreRepository())
            }
            return FireStoreUseCase(repository: repository)
        }
    }
    
    private func registerQrCodeUseCase() async {
        await diContainer.register(QrCodeUseCaseProtocool.self) {
            guard let repository = self.diContainer.resolve(QrCodeRepositoryProtcool.self) else {
                assertionFailure("FirestoreRepositoryProtocol must be registered before registering FirestoreUseCaseProtocol")
                return QrCodeUseCase(repository: DefaultQrCodeRepository())
            }
            return QrCodeUseCase(repository: repository)
        }
    }

    // MARK: - Repositories Registration
    private func registerRepositories() async {
        await registerFireStoreRepositories()
        await registerQrCodeRepositories()
    }

    private func registerFireStoreRepositories() async {
        await diContainer.register(FireStoreRepositoryProtocol.self) {
            FireStoreRepository()
        }
    }
    
    private func registerQrCodeRepositories() async {
        await diContainer.register(QrCodeRepositoryProtcool.self) {
            QrCodeRepository()
        }
    }
}

