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
import FirebaseDatabase
import KeychainAccess
import Service
import ConcurrencyExtras

import Model
import LogMacro

@Observable public class FireStoreRepository: FireStoreRepositoryProtocol {
    
    private let fireStoreDB = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    public init() {
        
    }
    
    //MARK: - firebase 데이터 베이스에서 members 값 가지고 오기
    public func fetchFireStoreData<T: Decodable>(
        from collection: FireBaseCollection,
        as type: T.Type,
        shouldSave: Bool
    ) async throws -> [T] {
        let querySnapshot = try await fireStoreDB.collection(collection.desc).getDocuments()
        Log.debug("firebase 데이터 가져오기 성공", collection, querySnapshot.documents.map { $0.data() })
        
        var decodedData: [T] = []
        var uniqueKeys: Set<String> = Set()
        
        for document in querySnapshot.documents {
            do {
                let data = try document.data(as: T.self)
                let uniqueKey = document.documentID  // Use documentID or another unique attribute
                if !uniqueKeys.contains(uniqueKey) {
                    decodedData.append(data)
                    uniqueKeys.insert(uniqueKey)
                } else {
                    // If shouldSave is true, remove duplicate document from Firestore
                    if shouldSave {
                        try await fireStoreDB.collection(collection.desc).document(document.documentID).delete()
                        Log.debug("Duplicate document removed with ID: ", "\(#function)", "\(document.documentID)")
                    }
                }
            } catch {
                Log.error("Failed to decode document to \(T.self): \(error)")
            }
        }
        
        return decodedData
    }
    
    //MARK: -  firebase 데이터 베이스에서 실기간으로 값 가지고 오기
    public func fetchFireStoreRealTimeData<T: Decodable>(
        from collection: FireBaseCollection,
        as type: T.Type,
        shouldSave: Bool
    ) async throws -> AsyncStream<Result<[T], CustomError>> {
        AsyncStream { continuation in
            Task {
                do {
                    let querySnapshot = try await fireStoreDB.collection(collection.desc).getDocuments()
                    #logDebug("firebase 데이터 실시간 가져오기 성공", collection, querySnapshot.documents.map { $0.data() })
                    
                    var decodedData: [T] = []
                    var uniqueKeys: Set<String> = Set()
                    
                    for document in querySnapshot.documents {
                        do {
                            let data = try document.data(as: T.self)
                            let uniqueKey = document.documentID 
                            if !uniqueKeys.contains(uniqueKey) {
                                decodedData.append(data)
                                uniqueKeys.insert(uniqueKey)
                                continuation.yield(.success(decodedData))
                            } else {
                                if shouldSave {
                                    try await fireStoreDB.collection(collection.desc).document(document.documentID).delete()
                                    #logDebug("Duplicate document removed with ID: ", "\(#function)", "\(document.documentID)")
                                }
                            }
                        } catch {
                            #logError("Failed to decode document to \(T.self): \(error)")
                            continuation.yield(.failure(CustomError.firestoreError(error.localizedDescription)))
                        }
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.yield(.failure(CustomError.firestoreError(error.localizedDescription)))
                    continuation.finish()
                }
            }
        }
    }

    
    //MARK: - firebase 유저 정보가져오기
    public func getCurrentUser() async throws -> User? {
        #logDebug("유저가져오기", Auth.auth().currentUser ?? .none)
        return Auth.auth().currentUser
    }
    
    public func getUserLogOut() async throws -> User? {
        do {
            try Auth.auth().signOut()
            #logDebug("User successfully signed out")
            try? Keychain().removeAll()
            return nil
        } catch let signOutError as NSError {
            #logError("로그아웃 에러: \(signOutError)")
            throw CustomError.unknownError(signOutError.localizedDescription)
        }
    }
    
    //MARK: - firebase 실시간 정보 가져오기
    public func observeFireBaseChanges<T>(
        from collection: FireBaseCollection,
        as type: T.Type
    ) async throws -> AsyncStream<Result<[T], CustomError>> where T: Decodable {
        AsyncStream { continuation in
            let collectionRef = fireStoreDB.collection(collection.desc)
            
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
                        #logDebug("firebase 데이터 실시간 변경", records.map { $0 }, #function)
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
        .eraseToStream()

    }
    
    //MARK: - firebase 로 이벤트 만들기
    public func createEvent(
        event: DDDEvent,
        from collection: FireBaseCollection,
        uuid: String
    ) async throws -> DDDEvent? {
          
        var newEvent = event
        let documentReference = fireStoreDB.collection(collection.desc).document(uuid)
        let newDocumentID = documentReference.documentID
        newEvent.id = newDocumentID
        
        var data = newEvent.toDictionary()
        data["id"] = newDocumentID

        do {
            try await documentReference.setData(data)
            #logDebug("이벤트 생성 ID: \(documentReference.documentID)")
            return newEvent
        } catch {
            #logError("이벤트 생성 실패 \(error)")
            throw CustomError.unknownError("Error adding document: \(error.localizedDescription)")
        }
    }
    
    //MARK: - event 수정하기
    public func editEvent(
        event: DDDEvent,
        in collection: FireBaseCollection,
        eventID: String
    ) async throws -> DDDEvent? {

        let eventRef = fireStoreDB.collection(collection.desc).document(eventID)
        let data: [String: Any] =  event.toDictionary()

        do {
            try await eventRef.updateData(data)
            #logDebug("event 수정 ID: \(eventID)")
            return event
        } catch {
            #logError("이벤트 수정 실패: \(error)")
            throw CustomError.unknownError("이벤트 수정 실패: \(error.localizedDescription)")
        }
    }
    
    //MARK: - evnet삭제 하기
    public func deleteEvent(
        from collection: FireBaseCollection,
        eventID: String
    ) async throws -> DDDEventDTO? {
        let db = fireStoreDB.collection(collection.desc)
        let eventRef = db.document(eventID)
        do {
            let document = try await eventRef.getDocument()
            
            guard let eventData = document.data(), document.exists else {
                #logError("이벤트 삭제 아이디를 찾을수 없어요: \(eventID)")
                throw CustomError.unknownError("이벤트를 찾을 수 없습니다: \(eventID)")
            }
            
            let event = try Firestore.Decoder().decode(DDDEvent.self, from: eventData)
            
            try await eventRef.delete()
            #logDebug("Document successfully 이벤트 ID 삭제 : \(eventID)")
            return event.toModel()
            
        } catch {
            #logError("이벤트 ID 삭제 실패: \(error)")
            throw CustomError.unknownError("이벤트 ID 삭제 실패: \(error.localizedDescription)")
        }
    }

    
    //MARK: - 출석 현황 체크
    public func fetchAttendanceHistory(
        _ uid: String, 
        from collection: FireBaseCollection
    ) async throws -> AsyncStream<Result<[Attendance], CustomError>> {
        AsyncStream { continuation in
            let db = Firestore.firestore()
            let attendanceRef = db.collection(collection.desc).whereField("id", isEqualTo: uid)
            
            let listener = attendanceRef.addSnapshotListener { querySnapshot, error in
                if let error = error {
                    continuation.yield(.failure(CustomError.firestoreError(error.localizedDescription)))
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    continuation.yield(.failure(CustomError.firestoreError(error?.localizedDescription ?? "")))
                    return
                }
                
                let attendances: [Attendance] = documents.compactMap { document in
                    let data = document.data()
                    let id: String = data["id"] as? String ?? ""
                    let memberId: String = data["memberId"] as? String ?? ""
                    let eventId: String = data["eventId"] as? String ?? ""
                    let createdAt: Date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
                    let updatedAt: Date = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
                    let status: AttendanceType = AttendanceType(rawValue: data["status"] as? String ?? "") ?? .absent
                    let generation: Int = data["generation"] as? Int ?? 0
                    let memberType: MemberType = MemberType(rawValue: data["memberType"] as? String ?? "") ?? .member
                    let manging: Managing = Managing(rawValue: data["managing"] as? String ?? "") ?? .notManging
                    let memberTeam: ManagingTeam = ManagingTeam(rawValue: data["memberTeam"] as? String ?? "") ?? .notTeam
                    let roleType : SelectPart = SelectPart(rawValue:  data["roleType"] as? String ?? "") ?? .all
                    return Attendance(
                        id: id,
                        memberId: memberId,
                        memberType: memberType,
                        manging: manging,
                        memberTeam: memberTeam,
                        name: data["name"] as? String ?? "",
                        roleType: roleType,
                        eventId: eventId,
                        createdAt: createdAt,
                        updatedAt: updatedAt,
                        status: status,
                        generation: generation
                    )
                }
                
                continuation.yield(.success(attendances))
                #logDebug("출석현황", attendances)
            }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
}
    
    
    
    
