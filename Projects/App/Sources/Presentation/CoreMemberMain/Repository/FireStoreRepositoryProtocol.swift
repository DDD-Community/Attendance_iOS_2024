//
//  FireStoreRepositoryProtocol.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/9/24.
//

import Foundation

public protocol FireStoreRepositoryProtocol {
    func fetchFireStoreData<T: Decodable>(from collection: String, as type: T.Type) async throws -> [T]
    
}
