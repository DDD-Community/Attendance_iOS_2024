//
//  ProfileResponseModel.swift
//  ProfileDomain
//
//  Created by DDD on 5/9/25.
//

import Foundation

import OnBoardingDomainInterface

public struct ProfileResponseModel: Equatable {
  public let id: String
  public let userID: Int
  public let name: String
  public let inviteCodeID: String
  public let role: SelectPart
  public let team: SelectTeam
  public let crew: SelectTeam
  public let responsibility: Managing
  public let cohort: String
  public let cohortID: String
  public let isStaff: Bool
  
}
