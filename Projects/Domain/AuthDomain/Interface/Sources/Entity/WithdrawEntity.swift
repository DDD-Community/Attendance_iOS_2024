//
//  WithdrawEntity.swift
//  Entity
//
//  Created by DDD on 1/2/26.
//

import Foundation

import ProfileDomainInterface

public struct WithdrawEntity: Equatable {
  public let isSuccess: Bool
  public let code: String?
  public let message: String?
  public let detail: String?

  public init(
    isSuccess: Bool,
    code: String? = nil,
    message: String? = nil,
    detail: String? = nil
  ) {
    self.isSuccess = isSuccess
    self.code = code
    self.message = message
    self.detail = detail
  }
}
