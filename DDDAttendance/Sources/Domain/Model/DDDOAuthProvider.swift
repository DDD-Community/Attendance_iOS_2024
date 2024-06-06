//
//  OAuthProvider.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import Foundation

enum DDDOAuthProvider {
    case APPLE
    case GOOGLE
    
    var service: OAuthServiceProtocol {
        switch self {
        case .APPLE: return OAuthAppleService()
        case .GOOGLE: return OAuthGoogleService()
        }
    }
}
