//
//  QRValidate.swift
//  QRCodeDomain
//
//  Created by DDD on 5/20/25.
//

import Foundation

import AttendanceDomainInterface
import DDDNetworkInterface
import OnBoardingDomainInterface

public typealias QRValidateModel = BaseResponseDTO<QRValidateResponseModel>

// MARK: - DataClass
public struct QRValidateResponseModel: Decodable, Sendable, Equatable {
  public let id: String?
  public let profileSummary: QRProfileSummary?
  public let scheduleSummary: QRScheduleSummary?
  public let updatedAt, method: String
  public let note: String?
  public let status: AttendanceType

  public init(
    id: String?,
    profileSummary: QRProfileSummary?,
    scheduleSummary: QRScheduleSummary?,
    updatedAt: String,
    method: String,
    note: String?,
    status: AttendanceType
  ) {
    self.id = id
    self.profileSummary = profileSummary
    self.scheduleSummary = scheduleSummary
    self.updatedAt = updatedAt
    self.method = method
    self.note = note
    self.status = status
  }
}

// MARK: - ProfileSummary
public struct QRProfileSummary: Decodable, Sendable, Equatable {
  public let id: String
  public let userID: Int
  public let name: String
  public let role: SelectPart?
  public let team: SelectTeam?
  public let cohort: String?

  public init(
    id: String,
    userID: Int,
    name: String,
    role: SelectPart?,
    team: SelectTeam?,
    cohort: String?,
  ) {
    self.id = id
    self.userID = userID
    self.name = name
    self.role = role
    self.team = team
    self.cohort = cohort
  }
}

// MARK: - ScheduleSummary
public struct QRScheduleSummary: Decodable, Sendable, Equatable  {
public let id, title, description: String
 public let startTime, endTime: String

  public init(
    id: String,
    title: String,
    description: String,
    startTime: String,
    endTime: String
  ) {
    self.id = id
    self.title = title
    self.description = description
    self.startTime = startTime
    self.endTime = endTime
  }
}
