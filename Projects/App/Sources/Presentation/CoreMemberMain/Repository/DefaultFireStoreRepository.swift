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
    
    public func fetchFireStoreData<T>(from collection: String, as type: T.Type) async throws -> [T] where T : Decodable {
        return[]
    }
    
    public func getCurrentUser() async throws -> User? {
        return nil
    }
    
    public func observeFireBaseChanges<T>(from collection: String, as type: T.Type) async throws -> AsyncStream<Result<[T], CustomError>> where T : Decodable {
        return AsyncStream { continuation in
            continuation.finish()
        }
    }
    
    public func createEvent(event: DDDEvent, from collection: String) async throws -> DDDEvent? {
        return nil
    }
    
}
