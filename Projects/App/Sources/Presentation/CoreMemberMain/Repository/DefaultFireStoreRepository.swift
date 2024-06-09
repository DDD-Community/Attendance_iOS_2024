//
//  DefaultFireStoreRepository.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/9/24.
//

import Foundation

public final class DefaultFireStoreRepository: FireStoreRepositoryProtocol {
    
    public init() {}
    
    public func fetchFireStoreData<T>(from collection: String, as type: T.Type) async throws -> [T] where T : Decodable {
        return []
    }
}
