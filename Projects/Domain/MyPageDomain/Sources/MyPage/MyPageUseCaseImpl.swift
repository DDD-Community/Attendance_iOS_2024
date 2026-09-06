//
//  MyPageUseCaseImpl.swift
//  MyPageDomain
//

import MyPageDomainInterface

import Dependencies

public struct MyPageUseCaseImpl: MyPageUseCaseInterface {
  private let repository: any MyPageInterface

  public init(repository: any MyPageInterface) {
    self.repository = repository
  }

  public func fetchAttendances() async throws(MyPageError) -> AttendanceSummaryResponse {
    try await repository.fetchAttendances()
  }

  public func fetchSchedules() async throws(MyPageError) -> [AttendanceMyScheduleResponse] {
    try await repository.fetchSchedules()
  }
}
