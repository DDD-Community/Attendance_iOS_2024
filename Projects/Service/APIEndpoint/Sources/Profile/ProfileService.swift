//
//  ProfileService.swift
//  Service
//
//  Created by DDD on 5/8/25.
//

import Foundation

import API
import DDDNetworkInterface

import Alamofire

public enum ProfileService: DDDDataRequest, Sendable {
  case getUserProfile
  case getAdminProfile
  case editProfile(body: EditProfileRequestDTO)

  private var domain: AttendanceDomain {
    switch self {
    case .getUserProfile:
      return .me
    case .getAdminProfile:
      return .admin
    case .editProfile:
      return .user
    }
  }

  public var path: String {
    return domain.url + urlPath
  }

  private var urlPath: String {
    switch self {
    case .getUserProfile:
      return ProfileAPI.getUser.profileDescription
    case .getAdminProfile:
      return ProfileAPI.getAdmin.profileDescription
    case .editProfile:
      return ProfileAPI.editUser.profileDescription
    }
  }

  public var method: HTTPMethod {
    switch self {
    case .getUserProfile, .getAdminProfile:
      return .get
    case .editProfile:
      return .put
    }
  }

  public var parameters: (any Encodable & Sendable)? {
    switch self {
    case .getUserProfile, .getAdminProfile:
      return nil
    case let .editProfile(body):
      return body
    }
  }
}
