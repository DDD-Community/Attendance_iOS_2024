//
//  SelectJob.swift
//  Entity
//
//  Created by DDD on 12/30/25.
//

import Foundation

import AuthDomainInterface
import ProfileDomainInterface

public struct SelectJob: Equatable, Identifiable {
  public let id: String
  public let jobKeys: String
  public let job: SelectParts

  public init(
    jobKeys: String,
    job: SelectParts
  ) {
    self.id = jobKeys
    self.jobKeys = jobKeys
    self.job = job
  }
}
