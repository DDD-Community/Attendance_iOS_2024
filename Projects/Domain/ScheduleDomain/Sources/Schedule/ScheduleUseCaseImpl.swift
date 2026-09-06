//
//  ScheduleUseCaseImpl.swift
//  ScheduleDomain
//
//  Created by DDD on 7/23/25.
//

import ScheduleDomainInterface

import Dependencies

public struct ScheduleUseCaseImpl: ScheduleUseCaseInterface {
  @Dependency(\.scheduleRepository) var repository

  public init() {}

  // MARK: - 캐시 즉시 조회 (만료 시 nil)

  public func getCachedSchedule() async -> [Schedule]? {
    await repository.getCachedSchedule()
  }

  // MARK: - 스케줄 조회

  public func getSchedule() async throws(ScheduleError) -> [Schedule] {
    return try await repository.getSchedule()
  }
}
