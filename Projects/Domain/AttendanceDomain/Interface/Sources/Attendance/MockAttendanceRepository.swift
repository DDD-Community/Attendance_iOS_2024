//
//  MockAttendanceRepository.swift
//  DomainInterface
//
//  Created by DDD on 2026-04-16
//

import Foundation

import OnBoardingDomainInterface
import ProfileDomainInterface

public actor MockAttendanceRepository: AttendanceInterface {
    // MARK: - Configuration
    public enum Configuration {
        case adminCountSuccess
        case teamsSuccess
        case sessionAttendanceSuccess
        case statusSuccess
        case editSuccess
        case permissionDenied
        case invalidData
        case statisticsSuccess
        case teamFiltering
        case statusChangeFlow
        case consistencyValidation
        case permissionValidation
        case historyTracking
        case networkError
    }

    // MARK: - State
    private var configuration: Configuration = .adminCountSuccess
    private var adminCountCallCount = 0
    private var teamsCallCount = 0
    private var sessionAttendanceCallCount = 0
    private var editCallCount = 0
    private var lastSessionAttendanceParams: (scheduleId: Int, teamId: Int)?

    // MARK: - Public Configuration Methods
    public init(configuration: Configuration = .adminCountSuccess) {
        self.configuration = configuration
    }

    public static func adminCountSuccess() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .adminCountSuccess)
    }

    public static func teamsSuccess() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .teamsSuccess)
    }

    public static func sessionAttendanceSuccess() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .sessionAttendanceSuccess)
    }

    public static func statusSuccess() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .statusSuccess)
    }

    public static func editSuccess() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .editSuccess)
    }

    public static func permissionDenied() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .permissionDenied)
    }

    public static func invalidData() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .invalidData)
    }

    public static func statisticsSuccess() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .statisticsSuccess)
    }

    public static func teamFiltering() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .teamFiltering)
    }

    public static func statusChangeFlow() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .statusChangeFlow)
    }

    public static func consistencyValidation() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .consistencyValidation)
    }

    public static func permissionValidation() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .permissionValidation)
    }

    public static func historyTracking() -> MockAttendanceRepository {
        MockAttendanceRepository(configuration: .historyTracking)
    }

    // MARK: - Call Count Getters
    public func getAdminCountCallCount() -> Int { adminCountCallCount }
    public func getTeamsCallCount() -> Int { teamsCallCount }
    public func getSessionAttendanceCallCount() -> Int { sessionAttendanceCallCount }
    public func getEditCallCount() -> Int { editCallCount }
    public func getLastSessionAttendanceParams() -> (scheduleId: Int, teamId: Int)? { lastSessionAttendanceParams }

    // MARK: - AttendanceInterface Implementation

    public func adminAttendanceCount(scheduleId: Int) async throws(AttendanceError) -> AttendanceCount {
        adminCountCallCount += 1

        try? await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .adminCountSuccess:
            return AttendanceCount(
                attendanceCount: 40,
                lateCount: 7,
                absentCount: 3
            )
        case .networkError:
            throw AttendanceError.unknown
        default:
            return AttendanceCount(attendanceCount: 0, lateCount: 0, absentCount: 0)
        }
    }

    public func fetchAttendanceTeams() async throws(AttendanceError) -> [SelectTeamEntity] {
        teamsCallCount += 1

        try? await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .teamsSuccess:
            return [
                SelectTeamEntity(teamId: 1, teams: .ios1),
                SelectTeamEntity(teamId: 2, teams: .and1),
                SelectTeamEntity(teamId: 3, teams: .web1)
            ]
        case .networkError:
            throw AttendanceError.unknown
        default:
            return []
        }
    }

    public func sessionAttendance(scheduleId: Int, teamId: Int) async throws(AttendanceError) -> [Attendance] {
        sessionAttendanceCallCount += 1
        lastSessionAttendanceParams = (scheduleId: scheduleId, teamId: teamId)

        try? await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .sessionAttendanceSuccess:
            return [
                Attendance(id: 1, userID: "101", userName: "김개발", userInfo: "iOS1팀/개발자", status: .attended),
                Attendance(id: 2, userID: "102", userName: "박코딩", userInfo: "iOS1팀/개발자", status: .attended),
                Attendance(id: 3, userID: "103", userName: "이프로그래머", userInfo: "iOS1팀/개발자", status: .attended),
                Attendance(id: 4, userID: "104", userName: "최개발자", userInfo: "iOS1팀/개발자", status: .late),
                Attendance(id: 5, userID: "105", userName: "정엔지니어", userInfo: "iOS1팀/개발자", status: .absent)
            ]
        case .networkError:
            throw AttendanceError.unknown
        default:
            return []
        }
    }

    public func fetchStatus() async throws(AttendanceError) -> [AttendanceStatus] {
        try? await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .statusSuccess:
            return [.attended, .late, .absent]
        case .networkError:
            throw AttendanceError.unknown
        default:
            return []
        }
    }

    public func editAttendance(input: EditAttendanceInput) async throws(AttendanceError) -> EditAttendance {
        editCallCount += 1

        try? await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .editSuccess, .statusChangeFlow, .permissionValidation, .historyTracking:
            return EditAttendance(
                isSuccess: true,
                code: "SUCCESS",
                message: "출석 상태가 성공적으로 변경되었습니다.",
                detail: "attendanceId: \(input.attendanceId), userId: \(input.userId)"
            )
        case .permissionDenied:
            throw AttendanceError.unknown
        case .invalidData:
            throw AttendanceError.unknown
        case .networkError:
            throw AttendanceError.unknown
        default:
            throw AttendanceError.unknown
        }
    }

    public func calculateAttendanceStatistics(startDate: Date, endDate: Date) async throws(AttendanceError) -> AttendanceStatistics {
        try? await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .statisticsSuccess:
            let totalSessions = 5
            let presentCount = 3
            let lateCount = 1
            let absentCount = 1
            let attendanceRate = Double(presentCount) / Double(totalSessions) * 100

            return AttendanceStatistics(
                totalSessions: totalSessions,
                presentCount: presentCount,
                lateCount: lateCount,
                absentCount: absentCount,
                attendanceRate: attendanceRate
            )
        case .networkError:
            throw AttendanceError.unknown
        default:
            return AttendanceStatistics(totalSessions: 0, presentCount: 0, lateCount: 0, absentCount: 0, attendanceRate: 0.0)
        }
    }

    public func fetchTeamAttendance(teamType: SelectTeams) async throws(AttendanceError) -> [SessionAttendance] {
        try? await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .teamFiltering:
            switch teamType {
            case .ios1:
                return Array(repeating: SessionAttendance(id: 1, userId: 1, userName: "iOS1 Member", status: .attended, team: .ios1), count: 8)
            case .ios2:
                return Array(repeating: SessionAttendance(id: 1, userId: 1, userName: "iOS2 Member", status: .attended, team: .ios2), count: 6)
            case .and1:
                return Array(repeating: SessionAttendance(id: 1, userId: 1, userName: "Android1 Member", status: .attended, team: .and1), count: 6)
            case .and2:
                return Array(repeating: SessionAttendance(id: 1, userId: 1, userName: "Android2 Member", status: .attended, team: .and2), count: 5)
            case .web1:
                return Array(repeating: SessionAttendance(id: 1, userId: 1, userName: "Web1 Member", status: .attended, team: .web1), count: 4)
            case .web2:
                return Array(repeating: SessionAttendance(id: 1, userId: 1, userName: "Web2 Member", status: .attended, team: .web2), count: 3)
            case .unknown:
                return []
            }
        case .networkError:
            throw AttendanceError.unknown
        default:
            return []
        }
    }

    public func validateAttendanceConsistency(scheduleId: Int, userId: Int) async throws(AttendanceError) -> AttendanceValidationResult {
        try? await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .consistencyValidation:
            if scheduleId > 0 && userId > 0 {
                return AttendanceValidationResult(
                    isValid: true,
                    scheduleExists: true,
                    userExists: true,
                    attendanceRecordExists: true
                )
            } else {
                return AttendanceValidationResult(
                    isValid: false,
                    scheduleExists: false,
                    userExists: false,
                    attendanceRecordExists: false
                )
            }
        case .networkError:
            throw AttendanceError.unknown
        default:
            return AttendanceValidationResult(isValid: false, scheduleExists: false, userExists: false, attendanceRecordExists: false)
        }
    }

    public func getAttendanceHistory(attendanceId: Int) async throws(AttendanceError) -> AttendanceHistory {
        try? await Task.sleep(for: .milliseconds(10))

        switch configuration {
        case .historyTracking:
            // 수정 전 상태
            if editCallCount == 0 {
                return AttendanceHistory(
                    currentStatus: .absent,
                    previousStatus: nil,
                    modificationCount: 0,
                    lastModifiedDate: Date().addingTimeInterval(-3600) // 1시간 전
                )
            } else {
                // 수정 후 상태
                return AttendanceHistory(
                    currentStatus: .late,
                    previousStatus: .absent,
                    modificationCount: 1,
                    lastModifiedDate: Date() // 현재 시간
                )
            }
        case .networkError:
            throw AttendanceError.unknown
        default:
            return AttendanceHistory(currentStatus: .attended, previousStatus: nil, modificationCount: 0, lastModifiedDate: Date())
        }
    }
}

// MARK: - Mock Data Types

public struct AdminAttendanceCount {
    public let totalSchedules: Int
    public let totalAttendees: Int
    public let presentCount: Int
    public let lateCount: Int
    public let absentCount: Int

    public init(totalSchedules: Int, totalAttendees: Int, presentCount: Int, lateCount: Int, absentCount: Int) {
        self.totalSchedules = totalSchedules
        self.totalAttendees = totalAttendees
        self.presentCount = presentCount
        self.lateCount = lateCount
        self.absentCount = absentCount
    }
}

public struct AttendanceTeam {
    public let id: Int
    public let name: String
    public let canManage: Bool

    public init(id: Int, name: String, canManage: Bool) {
        self.id = id
        self.name = name
        self.canManage = canManage
    }
}

public struct SessionAttendance {
    public let id: Int
    public let userId: Int
    public let userName: String
    public let status: AttendanceStatus
    public let team: SelectTeams

    public init(id: Int, userId: Int, userName: String, status: AttendanceStatus, team: SelectTeams) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.status = status
        self.team = team
    }
}

public struct AttendanceEditRequest {
    public let attendanceId: Int
    public let newStatus: AttendanceStatus
    public let scheduleId: Int
    public let userId: Int

    public init(attendanceId: Int, newStatus: AttendanceStatus, scheduleId: Int, userId: Int) {
        self.attendanceId = attendanceId
        self.newStatus = newStatus
        self.scheduleId = scheduleId
        self.userId = userId
    }
}

public struct AttendanceEditResult {
    public let isSuccess: Bool
    public let updatedAttendance: Attendance

    public init(isSuccess: Bool, updatedAttendance: Attendance) {
        self.isSuccess = isSuccess
        self.updatedAttendance = updatedAttendance
    }
}


public struct AttendanceStatistics {
    public let totalSessions: Int
    public let presentCount: Int
    public let lateCount: Int
    public let absentCount: Int
    public let attendanceRate: Double

    public init(totalSessions: Int, presentCount: Int, lateCount: Int, absentCount: Int, attendanceRate: Double) {
        self.totalSessions = totalSessions
        self.presentCount = presentCount
        self.lateCount = lateCount
        self.absentCount = absentCount
        self.attendanceRate = attendanceRate
    }
}

public struct AttendanceValidationResult {
    public let isValid: Bool
    public let scheduleExists: Bool
    public let userExists: Bool
    public let attendanceRecordExists: Bool

    public init(isValid: Bool, scheduleExists: Bool, userExists: Bool, attendanceRecordExists: Bool) {
        self.isValid = isValid
        self.scheduleExists = scheduleExists
        self.userExists = userExists
        self.attendanceRecordExists = attendanceRecordExists
    }
}

public struct AttendanceHistory {
    public let currentStatus: AttendanceStatus
    public let previousStatus: AttendanceStatus?
    public let modificationCount: Int
    public let lastModifiedDate: Date

    public init(currentStatus: AttendanceStatus, previousStatus: AttendanceStatus?, modificationCount: Int, lastModifiedDate: Date) {
        self.currentStatus = currentStatus
        self.previousStatus = previousStatus
        self.modificationCount = modificationCount
        self.lastModifiedDate = lastModifiedDate
    }
}

// MARK: - Mock Errors
public enum MockAttendanceError: Error, LocalizedError {
    case permissionDenied
    case invalidData
    case networkError
    case unknownError

    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Permission denied for attendance operation"
        case .invalidData:
            return "Invalid attendance data provided"
        case .networkError:
            return "Network error during attendance operation"
        case .unknownError:
            return "Unknown attendance error occurred"
        }
    }
}
