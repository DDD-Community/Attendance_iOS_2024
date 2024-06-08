//
//  FirebaseService.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import FirebaseAuth
import FirebaseFirestore
import RxSwift

import Foundation

final class FirebaseService {
    
    func fetchMember(_ uid: String) -> Single<Member> {
        return Single.create { single in
            let db = Firestore.firestore()
            let userRef = db.collection("members").document(uid)
            userRef.getDocument { document, error in
                guard let document = document,
                      document.exists else {
                    single(.failure(UserRepositoryError.memberNotExist))
                    return
                }
                let data = document.data()
                let name: String = data?["name"] as? String ?? ""
                let roleType: String = data?["roleType"] as? String ?? ""
                let memberType: String = data?["memberType"] as? String ?? ""
                let createdAt: Date = data?["createdAt"] as? Date ?? Date()
                let updatedAt: Date = data?["updatedAt"] as? Date ?? Date()
                let generation: Int = data?["generation"] as? Int ?? 0
                
                let member: Member = .init(
                    uid: uid,
                    name: name,
                    role: MemberRoleType(rawValue: roleType) ?? .ios,
                    memberType: MemberType(rawValue: memberType) ?? .notYet,
                    createdAt: createdAt,
                    updatedAt: updatedAt,
                    generation: generation
                )
                single(.success(member))
            }
            return Disposables.create()
        }
    }
    
    func validateInviteCode(_ code: String) -> Single<Bool> {
        return Single.create { single in
            let db = Firestore.firestore()
            let inviteCodesRef = db.collection("invite_code")
            inviteCodesRef.whereField("code", isEqualTo: code).getDocuments { (querySnapshot, error) in
                if let error {
                    single(.success(false))
                    return
                }
                guard let documents = querySnapshot?.documents,
                      !documents.isEmpty,
                      let timeStamp = documents.first?.data()["expired_date"] as? Timestamp,
                      timeStamp.seconds > Int(Date().timeIntervalSince1970) else {
                    single(.failure(UserRepositoryError.invalidInviteCode))
                    return
                }
                single(.success(true))
            }
            return Disposables.create()
        }
    }
    
    func saveMember(_ member: Member) -> Single<Bool> {
        return Single.create { single in
            let db = Firestore.firestore()
            let userRef = db.collection("members").document(member.uid)
            
            let data: [String: Any] = [
                "name": member.name,
                "roleType": member.role.rawValue,
                "memberType": member.memberType.rawValue,
                "createdAt": member.createdAt,
                "updatedAt": member.updatedAt,
                "generation": member.generation
            ]
            userRef.setData(data) { error in
                guard error == nil else {
                    single(.failure(UserRepositoryError.saveMember))
                    return
                }
                single(.success(true))
            }
            return Disposables.create()
        }
    }
    
    func auth(_ credential: AuthCredential) -> Single<AuthDataResult> {
        return Single.create { single in
            Auth.auth().signIn(with: credential) { authResult, error in
                if let authResult {
                    single(.success(authResult))
                } else {
                    single(.failure(error ?? OAuthError.firebaseLoginError))
                }
            }
            return Disposables.create()
        }
    }
    
}
