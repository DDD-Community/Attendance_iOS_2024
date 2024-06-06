//
//  OAuthAppleService.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import RxSwift

import AuthenticationServices
import Foundation

final class OAuthAppleService: OAuthServiceProtocol {
    
    func authorize() -> Single<OAuthTokenResponse> {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.performRequests()
        return controller.rx.didCompleteWithAuthorization.asSingle()
    }
}
