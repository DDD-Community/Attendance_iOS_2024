//
//  FireStoreUseCaseProtocol.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/9/24.
//

import Foundation
import FirebaseAuth
import Model

public protocol FireStoreUseCaseProtocol {
    func fetchFireStoreData<T: Decodable>(from collection: FireBaseCollection, as type: T.Type, shouldSave: Bool) async throws -> [T]
    func fetchFireStoreRealTimeData<T: Decodable>(from collection: FireBaseCollection, as type: T.Type, shouldSave: Bool)  async throws -> AsyncStream<Result<[T], CustomError>>
    func getCurrentUser() async throws -> User?
    func observeFireBaseChanges<T: Decodable>(from collection: FireBaseCollection, as type: T.Type) async throws -> AsyncStream<Result<[T], CustomError>>
    func createEvent(event: DDDEvent, from collection: FireBaseCollection, uuid: String) async throws -> DDDEvent?
    func editEvent(event: DDDEvent, in collection: FireBaseCollection, eventID: String) async throws -> DDDEvent?
    func deleteEvent(from collection: FireBaseCollection, eventID: String) async throws -> DDDEventDTO?
    func getUserLogOut() async throws -> User?
    func fetchAttendanceHistory(_ uid: String, from collection: FireBaseCollection) async throws -> AsyncStream<Result<[Attendance], CustomError>> 
    
}
