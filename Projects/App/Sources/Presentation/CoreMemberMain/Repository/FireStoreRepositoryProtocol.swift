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
    func observeAttendanceChanges(from collection: String) async throws -> AsyncStream<Result<[Attendance], CustomError>>
}
