//
//  VerifyCodeEntity.swift
//  Entity
//
//  Created by DDD on 12/30/25.
//

import Foundation

import AuthDomainInterface
import ProfileDomainInterface

public struct VerifyCodeEntity: Equatable {
  public let generationID: Int
  public let type: Staff

  public init(
    generationID: Int,
    type: Staff
  ) {
    self.generationID = generationID
    self.type = type
  }
}
