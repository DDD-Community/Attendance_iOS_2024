//
//  ProfileDTO+.swift
//  ProfileDomain
//
//  Created by DDD on 1/4/26.
//

import Foundation

import ProfileDomainInterface

public extension ProfileDTO {
  func toDomain() -> ProfileEntity {
    return ProfileEntity(
      userID: self.userID,
      name: self.name,
      generation: self.generation,
      team: SelectTeams(rawValue: self.team ?? ""),
      jobRole: SelectParts.from(apiKey: self.jobRole) ?? .all,
      role: Staff.from(apiKey: self.role) ?? .member,
      manger: self.managerRoles?.compactMap { StaffManaging.from(apiKey: $0) },
    )
  }
}
