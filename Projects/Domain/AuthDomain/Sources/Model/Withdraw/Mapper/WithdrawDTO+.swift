//
//  WithdrawDTO+.swift
//  AuthDomain
//
//  Created by DDD on 1/2/26.
//

import Foundation

import AuthDomainInterface

public extension WithdrawDTO {
  func toDomain(isSuccess: Bool) -> WithdrawEntity {
    WithdrawEntity(
      isSuccess: isSuccess,
      code: code,
      message: message,
      detail: detail
    )
  }
}
