//
//  FireStoreRepository.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/8/24.
//

import Foundation
import Combine
import FirebaseFirestore
import Service

@Observable public class FireStoreRepository: FirestoreRepositiryProtocol {
    
    private let db = Firestore.firestore()
    
    public func fetchData<T>(
        from collection: String,
        as type: T.Type
    ) async throws -> [T] where T : Decodable, T : Encodable {
        let querySnapshot = try await db.collection(collection).getDocuments()
        Log.debug("firebasee 데이터 가져오기 성공", collection, T.self)
        return try querySnapshot.documents.compactMap { document in
            try document.data(as: T.self)
        }
    }
    
    public func fetchData<T>(
        from collection: String,
        withID id: String,
        as type: T.Type) async throws -> T? where T : Decodable, T : Encodable {
            let documentSnapshot = try await db.collection(collection).document(id).getDocument()
            return try documentSnapshot.data(as: T.self)
    }
    
    
}

