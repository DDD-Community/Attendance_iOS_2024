//
//  FireStoreUseCase.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/9/24.
//

import Foundation
import DiContainer

import ComposableArchitecture
import Firebase

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
    
    public func getCurrentUser() async throws -> User? {
        try await repository.getCurrentUser()
    }
    
    public func observeAttendanceChanges(from collection: String) async throws -> AsyncStream<Result<[Attendance], CustomError>> {
        try await repository.observeAttendanceChanges(from: collection)
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
