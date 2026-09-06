//
//  AttendanceRepositoryImpl.swift
//  AttendanceDomain
//
//  Created by DDD on 7/23/25.
//

import Foundation

import APIEndpoint
import AttendanceDomainInterface
import DDDNetworkInterface
import OnBoardingDomainInterface

import Dependencies

final public class AttendanceRepositoryImpl: AttendanceInterface, Sendable {
  @Dependency(\.networkClient) private var client

  public init() {}

  // MARK: - 운영진  출석 데이터 api
  public func adminAttendanceCount(scheduleId: Int) async throws(AttendanceError) -> AttendanceCount {
    do {
      let dto = try await client.send(
        AttendanceRequest.adminAttendanceCount(scheduleId: scheduleId),
        as: AttendanceCountDTO.self
      )
      return dto.toDomain()
    } catch {
      throw .loadFailed
    }
  }

  // MARK: - 출석할 팀 조회
  public func fetchAttendanceTeams() async throws(AttendanceError) -> [SelectTeamEntity] {
    do {
      let dto = try await client.send(
        AttendanceRequest.fetchTeams,
        as: [AttendanceTeamDTO].self
      )
      return dto.toDomain()
    } catch {
      throw .loadFailed
    }
  }

  // MARK: - 출석 조회
  public func sessionAttendance(
    scheduleId: Int,
    teamId: Int
  ) async throws(AttendanceError) -> [Attendance] {
    do {
      let body = AttendanceRequestDTO(scheduleId: scheduleId, teamId: teamId)
      let dto = try await client.send(
        AttendanceRequest.sessionAttendance(body: body),
        as: AttendanceDTOModel.self
      )
      return dto.toDomain()
    } catch {
      throw .loadFailed
    }
  }

  // MARK: - 출석 status 조회
  public func fetchStatus() async throws(AttendanceError) -> [AttendanceStatus] {
    do {
      let dto = try await client.send(
        AttendanceRequest.status,
        as: AttendanceStatusDTO.self
      )
      return dto.toDomain()
    } catch {
      throw .loadFailed
    }
  }

  // MARK: - 출석변경
  public func editAttendance(
    input: EditAttendanceInput
  ) async throws(AttendanceError) -> EditAttendance {
    let request = EditAttendanceRequestDTO(
      attendanceId: input.attendanceId.map(String.init),
      status: input.status.rawValue,
      userId: input.userId,
      scheduleId: "\(input.scheduleId)"
    )
    let response: DDDHTTPResponse
    do {
      response = try await client.sendResponse(AttendanceRequest.editAttendance(body: request))
    } catch {
      throw .updateFailed
    }

    let decoder = JSONDecoder()
    if (200...299).contains(response.statusCode) {
      if response.data.isEmpty {
        return EditAttendance(isSuccess: true)
      }
      if let successDTO = try? decoder.decode(EditAttendanceDTO.self, from: response.data) {
        return successDTO.toDomain(isSuccess: true)
      }
      return EditAttendance(isSuccess: true)
    }

    // 서버 응답 메시지가 있으면 거절 사유로 옮기고, 나머지는 변경 실패로 좁힌다.
    let errorDTO = try? decoder.decode(EditAttendanceDTO.self, from: response.data)
    throw Self.mapResponseError(
      statusCode: response.statusCode,
      message: errorDTO?.message
    )
  }

  private static func mapResponseError(statusCode: Int, message: String?) -> AttendanceError {
    if (400 ..< 500).contains(statusCode), let message, !message.isEmpty {
      return .rejected(message)
    }
    return .updateFailed
  }
}
