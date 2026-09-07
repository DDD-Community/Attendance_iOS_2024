//
//  ScheduleCacheModel.swift
//  ScheduleDomain
//
//  Created by DDD on 5/12/26.
//

import Foundation

import SQLiteData

@Table("scheduleCache")
struct ScheduleCacheRecord: Equatable, Sendable {
  let id: Int
  @Column(as: Date.UnixTimeRepresentation.self)
  let cachedAt: Date
  let name: String
  let scheduleDescription: String
  let month: Int
  let day: Int
  let year: Int

  init(
    id: Int,
    cachedAt: Date,
    name: String,
    scheduleDescription: String,
    month: Int,
    day: Int,
    year: Int
  ) {
    self.id = id
    self.cachedAt = cachedAt
    self.name = name
    self.scheduleDescription = scheduleDescription
    self.month = month
    self.day = day
    self.year = year
  }

  // 만료: 당일
  var isExpired: Bool {
    !Calendar.current.isDate(cachedAt, inSameDayAs: Date())
  }

  func toDomain() -> Schedule {
    Schedule(
      id: id,
      name: name,
      description: scheduleDescription,
      month: month,
      day: day,
      year: year
    )
  }
}

extension Schedule {
  func toCacheRecord(cachedAt: Date = Date()) -> ScheduleCacheRecord {
    ScheduleCacheRecord(
      id: id,
      cachedAt: cachedAt,
      name: name,
      scheduleDescription: description,
      month: month,
      day: day,
      year: year
    )
  }
}
