//
//  MyPageRepositoryImpl.swift
//  MyPageDomain
//
//  Created by DDD on 1/12/26.
//

import Foundation

import APIEndpoint
import DDDNetworkInterface
import MyPageDomainInterface

import Dependencies

final public class MyPageRepositoryImpl: MyPageInterface {
  @Dependency(\.networkClient) private var client

  public init() {}
  
  /// 출석 현황 요약 조회
  public func fetchAttendances() async throws(MyPageError) -> AttendanceSummaryResponse {
    do {
      let response = try await client.send(
        MyPageService.fetchAttendances,
        as: AttendanceSummaryResponseDTO.self
      )
      return response.toDomain()
    } catch {
      throw .loadFailed
    }
  }
  
  /// 내 스케줄/출석 현황 조회
  public func fetchSchedules() async throws(MyPageError) -> [AttendanceMyScheduleResponse] {
    do {
      let response = try await client.send(
        MyPageService.fetchSchedules,
        as: [AttendanceMyScheduleResponseDTO].self
      )
      return response.map { $0.toDomain() }
    } catch {
      throw .loadFailed
    }
  }
}
