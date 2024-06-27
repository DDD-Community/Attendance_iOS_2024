//
//  DefaultFireStoreRepository.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/9/24.
//

import Foundation
import FirebaseAuth

public final class DefaultFireStoreRepository: FireStoreRepositoryProtocol {
   
    
    public init() {}
    
    public func fetchFireStoreData<T>(from collection: FireBaseCollection, as type: T.Type, shouldSave: Bool) async throws -> [T] where T : Decodable {
        return[]
    }
    
    public func getCurrentUser() async throws -> User? {
        return nil
    }
    
    public func observeFireBaseChanges<T>(from collection: FireBaseCollection, as type: T.Type) async throws -> AsyncStream<Result<[T], CustomError>> where T : Decodable {
        return AsyncStream { continuation in
            continuation.finish()
        }
    }
    
    public func createEvent(event: DDDEvent, from collection: FireBaseCollection) async throws -> DDDEvent? {
        return nil
    }
    
    public func editEvent(event: DDDEvent, in collection: FireBaseCollection) async throws -> DDDEvent? {
        return nil
    }
    
    public func deleteEvent(from collection: FireBaseCollection) async throws   {
        
    }
    
    public func getUserLogOut() async throws -> User? {
        return nil
    }
}
