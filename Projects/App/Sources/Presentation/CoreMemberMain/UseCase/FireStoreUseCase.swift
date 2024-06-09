//
//  FireStoreUseCase.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/9/24.
//

import Foundation
import DiContainer

import ComposableArchitecture

public struct FireStoreUseCase: FireStoreUseCaseProtocol {
    
    private let repository: FireStoreRepositoryProtocol
    
    public init(
        repository: FireStoreRepositoryProtocol
    ) {
        self.repository = repository
    }
    
    
    public func fetchFireStoreData<T>(from collection: String, as type: T.Type) async throws -> [T] where T : Decodable {
        try await repository.fetchFireStoreData(from: collection, as: T.self)
    }
}

extension FireStoreUseCase: DependencyKey {
    public static var liveValue: FireStoreUseCase = {
        let fireStoreRepository = DependencyContainer.live.resolve(FireStoreRepositoryProtocol.self) ?? DefaultFireStoreRepository()
        return FireStoreUseCase(repository: fireStoreRepository)
    }()
}

public extension DependencyValues {
    var fireStoreUseCase: FireStoreUseCaseProtocol {
        get { self[FireStoreUseCase.self] }
        set { self[FireStoreUseCase.self] = newValue as! FireStoreUseCase}
    }
}
