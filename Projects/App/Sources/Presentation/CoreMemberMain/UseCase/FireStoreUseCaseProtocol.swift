//
//  FireStoreUseCaseProtocol.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/9/24.
//

import Foundation

public protocol FireStoreUseCaseProtocol {
    func fetchFireStoreData<T: Decodable>(from collection: String, as type: T.Type) async throws -> [T]
}
