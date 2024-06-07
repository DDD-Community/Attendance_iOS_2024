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
    
    func saveMember(_ member: Member) -> Single<Bool> {
        return Single.create { single in
            let db = Firestore.firestore()
            let userRef = db.collection("members").document(member.name)
            userRef.setData([
                "name": member.name,
                "roleType": member.role,
                "memberType": member.memberType
            ]) { error in
                if error != nil {
                    single(.success(false))
                } else {
                    single(.success(true))
                }
            }
            return Disposables.create()
        }
    }
    
    func auth(_ credential: AuthCredential) -> Single<AuthDataResult> {
        return Single.create { single in
            Auth.auth().signIn(with: credential) { authResult, error in
                guard let authResult, error == nil else {
                    return single(.failure(error ??  OAuthError.firebaseLoginError))
                }
                return single(.success(authResult))
            }
            return Disposables.create()
        }
    }
        
}
