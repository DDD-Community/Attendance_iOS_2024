//
//  MyPageInterface.swift
//  DomainInterface
//
//  Created by DDD on 1/12/26.
//

import Foundation

import Dependencies

public protocol MyPageInterface: Sendable {
  func fetchAttendances() async throws(MyPageError) -> AttendanceSummaryResponse
  func fetchSchedules() async throws(MyPageError) -> [AttendanceMyScheduleResponse]
}

public enum MyPageRepositoryDependency: TestDependencyKey {
  public static var testValue: any MyPageInterface {
    MockMyPageRepository()
  }

  public static let previewValue: any MyPageInterface = testValue
}

public extension DependencyValues {
  var myPageRepository: any MyPageInterface {
    get { self[MyPageRepositoryDependency.self] }
    set { self[MyPageRepositoryDependency.self] = newValue }
  }
}
