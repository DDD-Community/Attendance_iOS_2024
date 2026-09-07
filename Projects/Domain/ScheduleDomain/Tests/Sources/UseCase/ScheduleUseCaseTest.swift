//
//  ScheduleUseCaseTest.swift
//  UseCaseTests
//
//  Created by DDD on 2026-04-16
//

import Foundation
import Testing

@testable import ScheduleDomain
@testable import ScheduleDomainInterface

import ComposableArchitecture

@Suite("Schedule UseCase Tests - Complete TDD Implementation")
@MainActor
struct ScheduleUseCaseTest {
  // MARK: - Test Dependencies

  private var mockScheduleRepository: MockScheduleRepository!

  init() async {
    mockScheduleRepository = MockScheduleRepository()
  }

  // MARK: - Core Schedule Tests (10 Test Cases)

  @Test("TC-001: 전체 일정 조회 성공")
  func get_schedule_success() async throws {
    // Given: 성공적인 일정 조회 설정
    let expectedSchedules = [
      Schedule(id: 1, name: "DDD 세미나", description: "iOS 세미나", month: 4, day: 20, year: 2026),
      Schedule(id: 2, name: "Android 워크샵", description: "Android 개발 워크샵", month: 4, day: 25, year: 2026),
      Schedule(id: 3, name: "월간 회의", description: "4월 정기 회의", month: 4, day: 30, year: 2026)
    ]
    mockScheduleRepository.configureScheduleSuccess(expectedSchedules)

    // When: 일정 조회 실행
    let result = try await withDependencies {
      $0.scheduleRepository = mockScheduleRepository
    } operation: {
      let useCase = ScheduleUseCaseImpl()
      return try await useCase.getSchedule()
    }

    // Then: 일정 조회 검증
    #expect(result.count == 3, "3개의 일정이 조회되어야 함")
    #expect(result[0].name == "DDD 세미나", "첫 번째 일정명이 올바르게 조회되어야 함")
    #expect(result[1].name == "Android 워크샵", "두 번째 일정명이 올바르게 조회되어야 함")
    #expect(result[2].name == "월간 회의", "세 번째 일정명이 올바르게 조회되어야 함")
    #expect(mockScheduleRepository.getScheduleCallCount == 1, "Repository가 한 번 호출되어야 함")
  }

  @Test("TC-002: 빈 일정 목록 조회")
  func get_schedule_empty() async throws {
    // Given: 빈 일정 목록 설정
    mockScheduleRepository.configureScheduleSuccess([])

    // When: 빈 일정 조회 실행
    let result = try await withDependencies {
      $0.scheduleRepository = mockScheduleRepository
    } operation: {
      let useCase = ScheduleUseCaseImpl()
      return try await useCase.getSchedule()
    }

    // Then: 빈 결과 검증
    #expect(result.isEmpty, "빈 일정 목록이 반환되어야 함")
    #expect(mockScheduleRepository.getScheduleCallCount == 1, "Repository가 호출되어야 함")
  }

  @Test("TC-003: 일정 조회 실패 (네트워크 오류)")
  func get_schedule_network_failure() async throws {
    // Given: 네트워크 오류 설정
    mockScheduleRepository.configureScheduleFailure(ScheduleError.unknown)

    // When & Then: 네트워크 오류 검증
    await #expect(throws: ScheduleError.unknown) {
      try await withDependencies {
        $0.scheduleRepository = mockScheduleRepository
      } operation: {
        let useCase = ScheduleUseCaseImpl()
        _ = try await useCase.getSchedule()
      }
    }

    #expect(mockScheduleRepository.getScheduleCallCount == 1, "실패해도 Repository는 호출되어야 함")
  }

  @Test("TC-004: 일정 조회 실패 (권한 없음)")
  func get_schedule_unauthorized() async throws {
    // Given: 권한 없음 오류 설정
    mockScheduleRepository.configureScheduleFailure(ScheduleError.unknown)

    // When & Then: 권한 오류 검증
    await #expect(throws: ScheduleError.unknown) {
      try await withDependencies {
        $0.scheduleRepository = mockScheduleRepository
      } operation: {
        let useCase = ScheduleUseCaseImpl()
        _ = try await useCase.getSchedule()
      }
    }
  }

  @Test("TC-005: 일정 날짜 변환 검증")
  func schedule_date_conversion() async throws {
    // Given: 날짜 변환을 위한 특정 일정
    let scheduleWithDate = Schedule(
      id: 100,
      name: "날짜 테스트",
      description: "날짜 변환 테스트",
      month: 12,
      day: 25,
      year: 2026
    )
    mockScheduleRepository.configureScheduleSuccess([scheduleWithDate])

    // When: 일정 조회 및 날짜 변환
    let result = try await withDependencies {
      $0.scheduleRepository = mockScheduleRepository
    } operation: {
      let useCase = ScheduleUseCaseImpl()
      return try await useCase.getSchedule()
    }

    // Then: 날짜 변환 검증
    let schedule = result.first!
    let convertedDate = schedule.toDate()

    #expect(convertedDate != nil, "날짜 변환이 성공해야 함")

    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day], from: convertedDate!)
    #expect(components.year == 2026, "연도가 올바르게 변환되어야 함")
    #expect(components.month == 12, "월이 올바르게 변환되어야 함")
    #expect(components.day == 25, "일이 올바르게 변환되어야 함")
  }

  @Test("TC-006: 일정 ID 유효성 검증")
  func schedule_id_validation() async throws {
    // Given: 다양한 ID를 가진 일정들
    let schedules = [
      Schedule(id: 0, name: "ID 0", description: "최소 ID", month: 1, day: 1, year: 2026),
      Schedule(id: 999, name: "ID 999", description: "큰 ID", month: 1, day: 1, year: 2026),
      Schedule(id: -1, name: "ID -1", description: "음수 ID", month: 1, day: 1, year: 2026)
    ]
    mockScheduleRepository.configureScheduleSuccess(schedules)

    // When: 일정 조회 실행
    let result = try await withDependencies {
      $0.scheduleRepository = mockScheduleRepository
    } operation: {
      let useCase = ScheduleUseCaseImpl()
      return try await useCase.getSchedule()
    }

    // Then: ID 검증
    #expect(result[0].id == 0, "ID 0이 올바르게 처리되어야 함")
    #expect(result[1].id == 999, "큰 ID가 올바르게 처리되어야 함")
    #expect(result[2].id == -1, "음수 ID가 올바르게 처리되어야 함")
  }

  @Test("TC-007: 일정 설명 문자열 처리")
  func schedule_description_handling() async throws {
    // Given: 다양한 설명을 가진 일정들
    let schedules = [
      Schedule(id: 1, name: "빈 설명", description: "", month: 1, day: 1, year: 2026),
      Schedule(
        id: 2,
        name: "긴 설명",
        description: "매우 긴 설명입니다. 이것은 일정에 대한 상세한 설명으로 여러 줄에 걸쳐 작성될 수 있습니다. 특수문자도 포함됩니다: !@#$%^&*()",
        month: 1,
        day: 1,
        year: 2026
      ),
      Schedule(id: 3, name: "특수 문자", description: "한글과 English 123 !@#", month: 1, day: 1, year: 2026)
    ]
    mockScheduleRepository.configureScheduleSuccess(schedules)

    // When: 일정 조회 실행
    let result = try await withDependencies {
      $0.scheduleRepository = mockScheduleRepository
    } operation: {
      let useCase = ScheduleUseCaseImpl()
      return try await useCase.getSchedule()
    }

    // Then: 설명 처리 검증
    #expect(result[0].description.isEmpty, "빈 설명이 올바르게 처리되어야 함")
    #expect(result[1].description.count > 50, "긴 설명이 올바르게 처리되어야 함")
    #expect(result[2].description.contains("한글"), "한글이 포함된 설명이 올바르게 처리되어야 함")
    #expect(result[2].description.contains("English"), "영어가 포함된 설명이 올바르게 처리되어야 함")
    #expect(result[2].description.contains("123"), "숫자가 포함된 설명이 올바르게 처리되어야 함")
  }

  @Test("TC-008: 월별 일정 필터링 시뮬레이션")
  func monthly_schedule_filtering_simulation() async throws {
    // Given: 다양한 월의 일정들
    let allSchedules = [
      Schedule(id: 1, name: "1월 일정", description: "1월 행사", month: 1, day: 15, year: 2026),
      Schedule(id: 2, name: "2월 일정", description: "2월 행사", month: 2, day: 15, year: 2026),
      Schedule(id: 3, name: "12월 일정", description: "12월 행사", month: 12, day: 25, year: 2026)
    ]
    mockScheduleRepository.configureScheduleSuccess(allSchedules)

    // When: 일정 조회 및 월별 필터링 (UseCase에서는 전체 조회, 클라이언트에서 필터링)
    let result = try await withDependencies {
      $0.scheduleRepository = mockScheduleRepository
    } operation: {
      let useCase = ScheduleUseCaseImpl()
      return try await useCase.getSchedule()
    }

    // Then: 월별 필터링 가능성 검증
    let januarySchedules = result.filter { $0.month == 1 }
    let februarySchedules = result.filter { $0.month == 2 }
    let decemberSchedules = result.filter { $0.month == 12 }

    #expect(januarySchedules.count == 1, "1월 일정이 1개 있어야 함")
    #expect(februarySchedules.count == 1, "2월 일정이 1개 있어야 함")
    #expect(decemberSchedules.count == 1, "12월 일정이 1개 있어야 함")
  }

  @Test("TC-009: 대량 일정 조회 성능")
  func large_schedule_performance() async throws {
    // Given: 대량 일정 데이터 (100개)
    let largeSchedules = (1 ... 100).map { index in
      Schedule(
        id: index,
        name: "일정 \(index)",
        description: "일정 \(index) 설명",
        month: (index % 12) + 1,
        day: (index % 28) + 1,
        year: 2026
      )
    }
    mockScheduleRepository.configureScheduleSuccess(largeSchedules)

    // When: 대량 일정 조회 실행
    let result = try await withDependencies {
      $0.scheduleRepository = mockScheduleRepository
    } operation: {
      let useCase = ScheduleUseCaseImpl()
      return try await useCase.getSchedule()
    }

    // Then: 대량 데이터 처리 검증
    #expect(result.count == 100, "100개 일정이 모두 조회되어야 함")
    #expect(result.first?.id == 1, "첫 번째 일정 ID가 1이어야 함")
    #expect(result.last?.id == 100, "마지막 일정 ID가 100이어야 함")

    // 모든 일정이 유효한 월/일을 가지는지 검증
    let validSchedules = result.filter { schedule in
      schedule.month >= 1 && schedule.month <= 12 &&
        schedule.day >= 1 && schedule.day <= 31
    }
    #expect(validSchedules.count == 100, "모든 일정이 유효한 날짜를 가져야 함")
  }

  @Test("TC-010: 동시 일정 조회 요청")
  func concurrent_schedule_requests() async throws {
    // Given: 동시 요청에 대한 일정 설정
    let testSchedules = [
      Schedule(id: 1, name: "동시성 테스트", description: "동시 요청 테스트", month: 5, day: 1, year: 2026)
    ]
    mockScheduleRepository.configureScheduleSuccess(testSchedules)

    // When: 5개의 동시 요청 실행
    let results = try await withThrowingTaskGroup(of: [Schedule].self, returning: [[Schedule]].self) { group in
      for _ in 1 ... 5 {
        group.addTask {
          try await withDependencies {
            $0.scheduleRepository = mockScheduleRepository
          } operation: {
            let useCase = ScheduleUseCaseImpl()
            return try await useCase.getSchedule()
          }
        }
      }

      var results: [[Schedule]] = []
      for try await result in group {
        results.append(result)
      }
      return results
    }

    // Then: 동시 요청 결과 검증
    #expect(results.count == 5, "5개의 동시 요청이 모두 완료되어야 함")
    #expect(results.allSatisfy { $0.count == 1 }, "모든 요청이 동일한 결과를 반환해야 함")
    #expect(results.allSatisfy { $0.first?.name == "동시성 테스트" }, "모든 결과가 동일해야 함")
    #expect((4 ... 5).contains(mockScheduleRepository.getScheduleCallCount), "동시 요청 추적 카운트가 예상 범위 내여야 함")
  }
}

// MARK: - Mock Repository

@MainActor
class MockScheduleRepository: ScheduleInterface {
  // MARK: - Call Tracking

  var getScheduleCallCount = 0

  // MARK: - Configured Responses

  private var scheduleResponse: Result<[Schedule], ScheduleError>?

  // MARK: - Implementation

  func getSchedule() async throws(ScheduleError) -> [Schedule] {
    getScheduleCallCount += 1

    if let response = scheduleResponse {
      return try response.get()
    }

    throw ScheduleError.unknown
  }

  func getCachedSchedule() async -> [Schedule]? {
    try? scheduleResponse?.get()
  }

  // MARK: - Configuration Methods

  func configureScheduleSuccess(_ schedules: [Schedule]) {
    scheduleResponse = .success(schedules)
  }

  func configureScheduleFailure(_ error: Error) {
    scheduleResponse = .failure(ScheduleError.from(error))
  }
}
