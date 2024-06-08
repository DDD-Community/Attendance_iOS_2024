//
//  DefaultFireStoreRepository.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/8/24.
//

import Foundation

public class DefaultFireStoreRepository: FirestoreRepositiryProtocol {
    
    public init() {
       
   }

    
    public func fetchData<T>(from collection: String, as type: T.Type) async throws -> [T] where T : Decodable, T : Encodable {
        return []
    }
    
    public func fetchData<T>(from collection: String, withID id: String, as type: T.Type) async throws -> T? where T : Decodable, T : Encodable {
        return nil
    }
        
}
