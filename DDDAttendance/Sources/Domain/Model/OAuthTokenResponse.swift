//
//  OAuthTokenResponse.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import Foundation

struct OAuthTokenResponse {
    var accessToken: String
    var refreshToken: String
    var provider: OAuthProvider
}
