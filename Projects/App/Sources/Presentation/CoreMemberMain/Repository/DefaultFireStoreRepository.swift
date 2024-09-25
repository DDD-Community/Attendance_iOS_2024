//
//  DefaultFireStoreRepository.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/9/24.
//

import Foundation
import FirebaseAuth

import Model

public final class DefaultFireStoreRepository: FireStoreRepositoryProtocol {
   
    
    public init() {}
    
    public func fetchFireStoreData<T>(
        from collection: FireBaseCollection,
        as type: T.Type,
        shouldSave: Bool) async throws -> [T] where T : Decodable {
        return[]
    }
    
    public func fetchFireStoreRealTimeData<T>(
        from collection: FireBaseCollection,
        as type: T.Type,
        shouldSave: Bool
    ) async throws -> AsyncStream<Result<[T], CustomError>> where T : Decodable {
        return AsyncStream { continuation in
            continuation.finish()
        }
    }
    
    public func getCurrentUser() async throws -> User? {
        return nil
    }
    
    public func observeFireBaseChanges<T>(
        from collection: FireBaseCollection,
        as type: T.Type
    ) async throws -> AsyncStream<Result<[T], CustomError>> where T : Decodable {
        return AsyncStream { continuation in
            continuation.finish()
        }
    }
    
    public func createEvent(
        event: DDDEvent,
        from collection: FireBaseCollection,
        uuid: String) async throws -> DDDEvent? {
        return nil
    }
    
    public func editEvent(
        event: DDDEvent,
        in collection: FireBaseCollection,
        eventID: String
    ) async throws -> DDDEvent? {
        return nil
    }
    
    public func deleteEvent(
        from collection: FireBaseCollection,
        eventID: String
    ) async throws  -> DDDEventDTO?  {
        return nil
    }
    
    public func getUserLogOut() async throws -> User? {
        return nil
    }
    
    public func fetchAttendanceHistory(
        _ uid: String,
        from collection: FireBaseCollection
    ) async throws -> AsyncStream<Result<[Attendance], CustomError>> {
        return AsyncStream { continuation in
            continuation.finish()
        }
    }
}
