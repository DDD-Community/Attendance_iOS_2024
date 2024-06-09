//
//  FireStoreRepository.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/9/24.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import Service

@Observable public class FireStoreRepository: FireStoreRepositoryProtocol {
   
   private let fireStoreDB = Firestore.firestore()
    
    public init() {
        
    }
    
    public func fetchFireStoreData<T>(from collection: String, as type: T.Type) async throws -> [T] where T : Decodable {
        let querySnapshot = try await fireStoreDB.collection(collection).getDocuments()
        Log.debug("firebasee 데이터 가져오기 성공", collection, querySnapshot.documents.first?.data())
        return try querySnapshot.documents.compactMap { document in
            try document.data(as: T.self)
        }
    }
    
}

