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
            do {
                return try document.data(as: T.self)
            } catch {
                Log.error("Failed to decode document to \(T.self): \(error)")
                return nil
            }
        }
    }
    
    
    //MARK: - firebase 유저 정보가져오기
    public func getCurrentUser() async throws -> User? {
        return Auth.auth().currentUser
    }
    
    //MARK: - firebase 실시간 정보 가져오기
    public func observeFireBaseChanges<T>(from collection: String, as type: T.Type) async throws -> AsyncStream<Result<[T], CustomError>> where T: Decodable {
        AsyncStream { continuation in
            let collectionRef = fireStoreDB.collection(collection)
            
            listener = collectionRef.addSnapshotListener { querySnapshot, error in
                let result: Result<[T], CustomError> = {
                    guard let snapshot = querySnapshot else {
                        let customError = error.map { CustomError.unknownError($0.localizedDescription) } ?? CustomError.unknownError("Unknown error")
                        return .failure(customError)
                    }
                    
                    do {
                        let records = try snapshot.documents.compactMap { document in
                            try document.data(as: T.self)
                        }
                        Log.debug("firebase 데이터 실시간 변경", records.map { $0 }, #function)
                        return .success(records)
                    } catch {
                        return .failure(.decodeFailed)
                    }
                }()
                
                switch result {
                case .success(let records):
                    continuation.yield(.success(records))
                case .failure(let error):
                    continuation.yield(.failure(error))
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                self.listener?.remove()
            }
        }
    }
    
    //MARK: - firebase 로 이벤트 만들기
    public func createEvent(event: DDDEvent, from collection: String) async throws -> DDDEvent? {
        var newEvent = event
        if let documentReference = try? await fireStoreDB.collection(collection).addDocument(data: event.toDictionary()) {
            newEvent.id = documentReference.documentID
            Log.debug("Document added with ID: ", "\(#function)", "\(documentReference.documentID)")
            return newEvent
        } else {
            Log.error("Error adding document")
            return nil
        }
    }
}

