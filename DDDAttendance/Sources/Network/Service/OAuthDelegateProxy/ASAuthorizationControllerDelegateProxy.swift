//
//  ASAuthorizationControllerDelegateProxy.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import RxSwift
import RxCocoa

import AuthenticationServices
import Foundation

class ASAuthorizationControllerDelegateProxy: DelegateProxy<ASAuthorizationController, ASAuthorizationControllerDelegate>,
                                              DelegateProxyType,
                                              ASAuthorizationControllerDelegate {
    static func registerKnownImplementations() {
        self.register { (controller) -> ASAuthorizationControllerDelegateProxy in
            ASAuthorizationControllerDelegateProxy(parentObject: controller, delegateProxy: self)
        }
    }

    static func currentDelegate(for object: ASAuthorizationController) -> ASAuthorizationControllerDelegate? {
        return object.delegate
    }

    static func setCurrentDelegate(
        _ delegate: ASAuthorizationControllerDelegate?,
        to object: ASAuthorizationController
    ) {
        object.delegate = delegate
    }

}

extension Reactive where Base: ASAuthorizationController {
    var delegate: DelegateProxy<ASAuthorizationController, ASAuthorizationControllerDelegate> {
        return ASAuthorizationControllerDelegateProxy.proxy(for: self.base)
    }

    var didCompleteWithAuthorization: Observable<OAuthTokenResponse> {
        delegate.methodInvoked(
            #selector(
                ASAuthorizationControllerDelegate
                    .authorizationController(controller:didCompleteWithAuthorization:)
            )
        )
        .map { parameters in
            guard let authorization = parameters[1] as? ASAuthorization,
                  let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken else {
                print("🔴 Failed to sign in with apple")
                return OAuthTokenResponse(
                    accessToken: "",
                    refreshToken: "",
                    provider: .APPLE
                )
            }
            
            let accessToken: String = .init(decoding: tokenData, as: UTF8.self)
            return OAuthTokenResponse(
                accessToken: accessToken,
                refreshToken: "",
                provider: .APPLE
            )
        }
    }
}
