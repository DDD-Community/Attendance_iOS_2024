//
//  OAuthGoogleService.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/6/24.
//

import FirebaseAuth
import GoogleSignIn
import RxSwift


import UIKit

struct OAuthGoogleService: OAuthServiceProtocol {
    func authorize() -> Single<OAuthTokenResponse> {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let viewController = windowScene.windows.first?.topViewController else {
            return .error(OAuthError.googleLoginError)
        }
        return Single.create { single in
            DispatchQueue.main.async {
                GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { user, error in
                    guard error == nil,
                          let user else {
                        return single(.failure(OAuthError.googleLoginError))
                    }
                    let accessToken: String = user.user.idToken?.tokenString ?? ""
                    let firebaseCredential = GoogleAuthProvider.credential(
                        withIDToken: accessToken,
                        accessToken: user.user.accessToken.tokenString
                    )
                    let tokenResponse = OAuthTokenResponse(
                        accessToken: accessToken,
                        refreshToken: "",
                        provider: .GOOGLE,
                        credential: firebaseCredential
                    )
                    single(.success(tokenResponse))
                }
            }
            return Disposables.create()
        }
    }
}
