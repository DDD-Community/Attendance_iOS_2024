//
//  AuthAccessibilityID.swift
//  Auth
//

import AuthDomainInterface

enum AuthAccessibilityID {
  enum Login {
    static let root = "auth.login.root"
    static let logo = "auth.login.logo"

    static func socialButton(_ socialType: SocialType) -> String {
      "auth.login.social.\(socialType.rawValue).button"
    }
  }
}
