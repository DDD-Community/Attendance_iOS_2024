//
//  ScheduleDTO+.swift
//  ScheduleDomain
//
//  Created by DDD on 1/10/26.
//

import Foundation

import ScheduleDomainInterface


public extension ScheduleDTOResponse {
  func toDomain() -> Schedule {
    return Schedule(
      id: self.id,
      name: self.name,
      description: self.desc,
      month: self.month,
      day: self.day,
      year: self.year
    )
  }
}


public extension Array where Element == ScheduleDTOResponse {
  func toDomain() -> [Schedule] {
    return self.map { $0.toDomain() }
  }
}

public extension ScheduleDTO {
  func toDomain() -> [Schedule] {
    return self.data.toDomain()
  }
}
