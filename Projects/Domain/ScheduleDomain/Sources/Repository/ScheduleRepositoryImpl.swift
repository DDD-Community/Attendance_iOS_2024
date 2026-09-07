//
//  ScheduleRepositoryImpl.swift
//  ScheduleDomain
//
//  Created by DDD on 7/23/25.
//

import Foundation

import APIEndpoint
import DDDNetworkInterface
import ScheduleDomainInterface

import Dependencies

public final class ScheduleRepositoryImpl: ScheduleInterface, @unchecked Sendable {
  @Dependency(\.scheduleLocalDataSource) private var localDataSource

  @Dependency(\.networkClient) private var client

  public init() {}

  public func getCachedSchedule() async -> [Schedule]? {
    try? await localDataSource.loadAll()
  }

  public func getSchedule() async throws(ScheduleError) -> [Schedule] {
    // SWR: 캐시 hit이면 즉시 반환 + 백그라운드에서 fresh 갱신
    if let cached = try? await localDataSource.loadAll(), !cached.isEmpty {
      _Concurrency.Task.detached { [weak self] in
        _ = try? await self?.fetchAndCacheSchedule()
      }
      return cached
    }

    do {
      return try await fetchAndCacheSchedule()
    } catch {
      throw error
    }
  }

  private func fetchAndCacheSchedule() async throws(ScheduleError) -> [Schedule] {
    do {
      let dto = try await client.send(
        ScheduleRequest.getSchedule,
        as: ScheduleDTO.self
      )
      let schedules = dto.toDomain().sortedByDate()
      try? await localDataSource.saveAll(schedules)
      return schedules
    } catch {
      throw Self.mapError(error)
    }
  }

  /// 서버가 준 응답 코드만 도메인 케이스로 옮기고, 전송·디코딩 실패는 `.unknown` 으로 흡수한다.
  private static func mapError(_ error: DDDNetworkError) -> ScheduleError {
    guard case let .response(responseError) = error else {
      return .loadFailed
    }
    switch responseError.httpStatus {
    case 400:
      return .invalidDate
    default:
      return .loadFailed
    }
  }
}

private extension Array where Element == Schedule {
  func sortedByDate() -> [Schedule] {
    sorted { lhs, rhs in
      if lhs.year != rhs.year { return lhs.year < rhs.year }
      if lhs.month != rhs.month { return lhs.month < rhs.month }
      return lhs.day < rhs.day
    }
  }
}
