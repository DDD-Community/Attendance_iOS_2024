//
//  SelectTeamsDTO+.swift
//  OnBoardingDomain
//
//  Created by DDD on 12/31/25.
//

import Foundation

import OnBoardingDomainInterface

public extension SelectTeamsDTOResponse {
  func toDomain() -> SelectTeamEntity {
    return SelectTeamEntity(
      teamId: self.teamId,
      teams: SelectTeams(rawValue: self.name) ?? .unknown
    )
  }
}

public extension Array where Element == SelectTeamsDTOResponse {
  func toDomain() -> [SelectTeamEntity] {
    return self.map { $0.toDomain() }
  }
}

public extension SelectTeamsDTO {
  func toDomain() -> [SelectTeamEntity] {
    return self.data.toDomain()
  }
}
