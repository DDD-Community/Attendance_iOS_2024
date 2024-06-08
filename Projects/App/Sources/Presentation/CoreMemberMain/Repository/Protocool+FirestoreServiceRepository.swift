//
//  Protocool+FirestoreServiceRepository.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/8/24.
//

import Foundation

public protocol FirestoreRepositiryProtocol {
    func fetchData<T: Codable>(from collection: String, as type: T.Type) async throws -> [T]
    func fetchData<T: Codable>(from collection: String, withID id: String, as type: T.Type) async throws -> T?
}
