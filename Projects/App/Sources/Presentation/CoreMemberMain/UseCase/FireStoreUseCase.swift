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
import Model

public struct FireStoreUseCase: FireStoreUseCaseProtocol {
   
    private let repository: FireStoreRepositoryProtocol
    
    public init(
        repository: FireStoreRepositoryProtocol
    ) {
        self.repository = repository
    }
    
    public func fetchFireStoreData<T>(
        from collection: FireBaseCollection,
        as type: T.Type, shouldSave: Bool
    ) async throws -> [T] where T : Decodable {
        try await repository.fetchFireStoreData(from: collection, as: T.self, shouldSave: shouldSave)
    }
    
    public func getCurrentUser() async throws -> User? {
        try await repository.getCurrentUser()
    }
    
    public func observeFireBaseChanges<T>(
        from collection: FireBaseCollection,
        as type: T.Type
    ) async throws -> AsyncStream<Result<[T], CustomError>> where T : Decodable {
        try await repository.observeFireBaseChanges(from: collection, as: T.self)
    }
   
    public func createEvent(
        event: DDDEvent,
        from collection: FireBaseCollection,
        uuid: String
    ) async throws -> DDDEvent? {
        try await repository.createEvent(event: event, from: collection, uuid: uuid)
    }
    
    public func editEvent(
        event: DDDEvent,
        in collection: FireBaseCollection,
        eventID: String
    ) async throws -> DDDEvent? {
        try await repository.editEvent(event: event, in: collection, eventID: eventID)
    }
    
    public func deleteEvent(
        from collection: FireBaseCollection,
        eventID: String
    ) async throws -> DDDEventDTO? {
        try await repository.deleteEvent(from: collection, eventID: eventID)
    }
    
    public func getUserLogOut() async throws -> User? {
        try await repository.getUserLogOut()
    }
    
    public func fetchAttendanceHistory
    (_ uid: String,
     from collection: FireBaseCollection
    ) async throws -> AsyncStream<Result<[Attendance], CustomError>> {
        try await repository.fetchAttendanceHistory(uid, from: collection)
    }
    
    public func fetchFireStoreRealTimeData<T>(
        from collection: FireBaseCollection,
        as type: T.Type,
        shouldSave: Bool
    ) async throws -> AsyncStream<Result<[T], CustomError>> where T : Decodable {
        try await repository.fetchFireStoreRealTimeData(from: collection, as: T.self, shouldSave: shouldSave)
    }
}

extension FireStoreUseCase: DependencyKey {
    public static var liveValue: FireStoreUseCase = {
        let fireStoreRepository = DependencyContainer.live.resolve(FireStoreRepositoryProtocol.self) ?? DefaultFireStoreRepository()
        return FireStoreUseCase(repository: fireStoreRepository)
    }()
    
    public static var testValue: FireStoreUseCase = {
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
