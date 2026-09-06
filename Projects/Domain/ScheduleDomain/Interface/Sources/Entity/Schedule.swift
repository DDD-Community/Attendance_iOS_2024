//
//  Schedule.swift
//  Entity
//
//  Created by DDD on 1/10/26.
//

import DDDCoreUtility
import Foundation

public struct Schedule: Equatable, Identifiable {
  public let id: Int
  public let name: String
  public let description: String
  public let month, day, year: Int

  public init(
    id: Int,
    name: String,
    description: String,
    month: Int,
    day: Int,
    year: Int
  ) {
    self.id = id
    self.name = name
    self.description = description
    self.month = month
    self.day = day
    self.year = year
  }
}

public extension Schedule {
  func toDate(timeZone: TimeZone = .init(identifier: "Asia/Seoul")!) -> Date? {
    String(format: "%04d-%02d-%02d", year, month, day)
      .date(as: .yearMonthDay, timeZone: timeZone)
  }
}
