//
//  SelectMangerRoleDTO+.swift
//  OnBoardingDomain
//
//  Created by DDD on 1/1/26.
//

import Foundation

import OnBoardingDomainInterface

public extension SelectMangerRoleDTOResponse {
  func toDomain() -> SelectManaging {
    return SelectManaging(
      managingKeys: self.description,
      managing: StaffManaging(rawValue: self.key) ?? .attendanceCheck
    )
  }
}

public extension Array where Element == SelectMangerRoleDTOResponse {
  func toDomain() -> [SelectManaging] {
    return self.map { $0.toDomain() }
  }
}

public extension SelectMangerRoleDTO {
  func toDomain() -> [SelectManaging] {
    return self.data.toDomain()
  }
}
