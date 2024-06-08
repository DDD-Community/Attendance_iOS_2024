//
//  FireStoreUseCase.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/8/24.
//

import Foundation
import ComposableArchitecture
import DiContainer

public struct FireStoreUseCase: FirestoreUseCaseProtocol {
    
    private let repository: FirestoreRepositiryProtocol
    
    public init(
        repository: FirestoreRepositiryProtocol
    ) {
        self.repository = repository
    }
    
    public func fetchData<T>(from collection: String, as type: T.Type) async throws -> [T] where T : Decodable, T : Encodable {
        return try await repository.fetchData(from: collection , as: type)
    }
    
    public func fetchData<T>(from collection: String, withID id: String, as type: T.Type) async throws -> T? where T : Decodable, T : Encodable {
        return try await repository.fetchData(from: collection, withID: id, as: type)
    }
}

extension FireStoreUseCase: DependencyKey {
    public static let liveValue: FireStoreUseCase = {
        let authRepository = DependencyContainer.live.resolve(FirestoreRepositiryProtocol.self) ?? DefaultFireStoreRepository()
         return FireStoreUseCase(repository: authRepository)
       }()
    
    public static let testValue: FireStoreUseCase = {
        let authRepository = DependencyContainer.live.resolve(FirestoreRepositiryProtocol.self) ?? DefaultFireStoreRepository()
         return FireStoreUseCase(repository: authRepository)
    }()
}

public extension DependencyValues {
    var authUseCase: FirestoreUseCaseProtocol {
        get { self[FireStoreUseCase.self] }
        set { self[FireStoreUseCase.self] = newValue as! FireStoreUseCase}
    }
}


