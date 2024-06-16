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
        return []
    }
    
    public func getCurrentUser() async throws -> User? {
        return nil
    }
    
    public func observeAttendanceChanges(from collection: String) async throws -> AsyncStream<Result<[Attendance],  CustomError>> {
        return AsyncStream { continuation in
                // Placeholder implementation: immediately terminate the stream
                continuation.finish()
            }
    }
}
