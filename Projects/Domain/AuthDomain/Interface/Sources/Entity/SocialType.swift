//
//  SocialType.swift
//  Entity
//
//  Created by DDD on 12/29/25.
//

import Foundation

import ProfileDomainInterface

public enum SocialType: String, CaseIterable, Identifiable, Hashable, Equatable {
  case apple
  case google

  public var id: String { rawValue }

  public var description: String {
    switch self {
      case .apple:
        return "APPLE"
      case .google:
        return "GOOGLE"
    }
  }

  public var image: String {
    switch self {
      case .apple:
        return "apple.logo"
      case .google:
        return "google"
    }
  }
}
