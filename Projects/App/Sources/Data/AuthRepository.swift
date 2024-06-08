//
//  AuthRepository.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/8/24.
//

import FirebaseAuth
import RxSwift

import Foundation

final class AuthRepository: AuthRepositoryProtocol {
    
    private let firebaseService = FirebaseService()
    
    func auth(_ credential: AuthCredential) -> Single<AuthDataResult> {
        return firebaseService.auth(credential)
    }
}
