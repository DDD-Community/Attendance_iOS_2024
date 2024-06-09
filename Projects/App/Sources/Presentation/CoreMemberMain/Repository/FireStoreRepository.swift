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
    
    public func fetchFireStoreData<T: Decodable>(from collection: String, as type: T.Type) async throws -> [T] {
        let querySnapshot = try await fireStoreDB.collection(collection).getDocuments()
        Log.debug("firebase 데이터 가져오기 성공", collection, querySnapshot.documents.forEach { Log.debug($0.data()) })

        return querySnapshot.documents.compactMap { document in
            if T.self == Attendance.self {
                return try? Attendance(from: document) as? T
            } else {
                return try? document.data(as: T.self)
            }
        }
    }



    
}

