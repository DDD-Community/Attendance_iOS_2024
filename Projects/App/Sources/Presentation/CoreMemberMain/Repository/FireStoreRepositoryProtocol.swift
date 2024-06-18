//
//  FireStoreRepositoryProtocol.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/9/24.
//

import Foundation
import Firebase

public protocol FireStoreRepositoryProtocol {
    func fetchFireStoreData<T: Decodable>(from collection: String, as type: T.Type) async throws -> [T]
    func getCurrentUser() async throws -> User?
    func observeFireBaseChanges<T: Decodable>(from collection: String, as type: T.Type) async throws -> AsyncStream<Result<[T], CustomError>>
    func createEvent(event: DDDEvent, from collection: String) async throws -> DDDEvent?
}
