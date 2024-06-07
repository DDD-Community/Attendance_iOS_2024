//
//  OAuthError.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import Foundation

enum OAuthError: Error {
    case googleLoginError
    case appleLoginError
    case firebaseLoginError
}
