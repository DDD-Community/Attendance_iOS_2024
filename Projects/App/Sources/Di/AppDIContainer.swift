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
    }
    
    private func registerFireStoreUseCase() async {
        await diContainer.register(FirestoreUseCaseProtocol.self) {
            guard let repository =  self.diContainer.resolve(FirestoreRepositiryProtocol.self) else {
                assertionFailure("AuthRepositoryProtocol must be registered before registering AuthUseCaseProtocol")
                return FireStoreUseCase(repository: DefaultFireStoreRepository())
            }
            return FireStoreUseCase(repository: repository)
        }
    }
    
    // MARK: - Repositories Registration
    private func registerRepositories() async {
        await registerFireStoreRepositories()
    }
    
    private func registerFireStoreRepositories() async {
        await diContainer.register(FireStoreRepository.self) {
            FireStoreRepository()
        }
    }
}

