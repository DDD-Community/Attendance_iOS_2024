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
    
    public func observeFireBaseChanges<T>(
        from collection: String,
        as type: T.Type
    ) async throws -> AsyncStream<Result<[T], CustomError>> where T : Decodable {
        try await repository.observeFireBaseChanges(from: collection, as: T.self)
    }
   
    public func createEvent(event: DDDEvent, from collection: String) async throws -> DDDEvent? {
        try await repository.createEvent(event: event, from: collection)
    }
    
    public func editEventStream(event: DDDEvent, in collection: String) async throws -> AsyncStream<Result<DDDEvent, CustomError>> {
        try await repository.editEventStream(event: event, in: collection)
    }
    
    public func deleteEvent(from collection: String) async throws {
        try await repository.deleteEvent(from: collection)
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
