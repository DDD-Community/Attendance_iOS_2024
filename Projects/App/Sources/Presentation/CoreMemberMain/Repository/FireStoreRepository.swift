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
import FirebaseAuth

import Service

@Observable public class FireStoreRepository: FireStoreRepositoryProtocol {
    
    private let fireStoreDB = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    public init() {
        
    }
    
    //MARK: - firebase 데이터 베이스에서 members 값 가지고 오기
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
    
    //MARK: - firebase 유저 정보가져오기
    public func getCurrentUser() async throws -> User? {
        return Auth.auth().currentUser
    }
    
    //MARK: - firebase 실시간 정보 가져오기
    public func observeAttendanceChanges(from collection: String) async throws -> AsyncStream<Result<[Attendance], CustomError>> {
        AsyncStream { continuation in
            let collectionRef = Firestore.firestore().collection(collection)
            
            listener = collectionRef.addSnapshotListener { querySnapshot, error in
                let result: Result<[Attendance], CustomError> = {
                    guard let snapshot = querySnapshot else {
                        let customError = error.map { CustomError.unknownError($0.localizedDescription) } ?? CustomError.unknownError("Unknown error")
                        return .failure(customError)
                    }
                    
                    do {
                        let attendanceRecords = try snapshot.documents.compactMap { document in
                            try Attendance(from: document)
                        }
                        return .success(attendanceRecords)
                    } catch {
                        return .failure(.decodeFailed)
                    }
                }()
                
                continuation.yield(result)
            }
            
            continuation.onTermination = { @Sendable _ in
                self.listener?.remove()
            }
        }
    }
}

