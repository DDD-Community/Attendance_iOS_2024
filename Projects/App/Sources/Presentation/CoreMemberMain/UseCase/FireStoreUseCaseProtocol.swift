//
//  FireStoreUseCaseProtocol.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/9/24.
//

import Foundation
import FirebaseAuth

public protocol FireStoreUseCaseProtocol {
    func fetchFireStoreData<T: Decodable>(from collection: FireBaseCollection, as type: T.Type, shouldSave: Bool) async throws -> [T]
    func getCurrentUser() async throws -> User?
    func observeFireBaseChanges<T: Decodable>(from collection: FireBaseCollection, as type: T.Type) async throws -> AsyncStream<Result<[T], CustomError>>
    func createEvent(event: DDDEvent, from collection: FireBaseCollection) async throws -> DDDEvent?
    func editEvent(event: DDDEvent, in collection: FireBaseCollection) async throws -> DDDEvent?
    func deleteEvent(from collection: FireBaseCollection) async throws
    func getUserLogOut() async throws -> User?
}
