//
//  SelectJobsDTO+.swift
//  OnBoardingDomain
//
//  Created by DDD on 12/30/25.
//

import Foundation

import OnBoardingDomainInterface

public extension SelectJobsDTOResponse {
  func toDomain() -> SelectJob {
    return SelectJob(
      jobKeys: self.key,
      job: SelectParts.from(apiKey: self.key) ?? .all
    )
  }
}

public extension Array where Element == SelectJobsDTOResponse {
  func toDomain() -> [SelectJob] {
    return self.map { $0.toDomain() }
  }
}

public extension SelectJobsDTO {
  func toDomain() -> [SelectJob] {
    return self.data.toDomain()
  }
}
