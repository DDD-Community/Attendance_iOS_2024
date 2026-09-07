//
//  SignUpUser.swift
//  Entity
//
//  Created by DDD on 1/1/26.
//

import Foundation

import AuthDomainInterface
import ProfileDomainInterface

public struct SignUpUser : Equatable {
  public let name: String
  public let email: String
  public let generation: String
  public let team: SelectTeams?
  public let managing: [StaffManaging]?
  public let selectPart: SelectParts

  public init(
    name: String,
    email: String,
    generation: String,
    team: SelectTeams?,
    managing: [StaffManaging]?,
    selectPart: SelectParts
  ) {
    self.name = name
    self.email = email
    self.generation = generation
    self.team = team
    self.managing = managing
    self.selectPart = selectPart
  }
}
