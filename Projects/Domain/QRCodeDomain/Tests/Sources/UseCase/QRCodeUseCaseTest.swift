//
//  QRCodeUseCaseTest.swift
//  QRCodeDomainTests
//
//  Created by DDD on 9/4/26.
//

import SwiftUI
import Testing

import AttendanceDomainInterface
@testable import QRCodeDomain
import QRCodeDomainInterface

import Dependencies

@MainActor
@Suite("QRCode UseCase Tests - Complete TDD Implementation")
final class QRCodeUseCaseTest {
  private var mockQRCodeRepository: MockQRCodeRepository!

  init() async {
    mockQRCodeRepository = MockQRCodeRepository()
  }

  deinit {
    // reset은 @MainActor 메서드이므로 deinit에서 호출 제거
  }

  // MARK: - QR 코드 생성 테스트

  @Test("TC-001: QR 코드 생성 성공")
  func test_create_qr_code_success() async throws {
    // Given: QR 코드 생성 성공 설정
    mockQRCodeRepository.configureCreateSuccess(qrCode: "user_123_qrcode")

    // When: QR 코드 생성
    let qrCode = try await withDependencies {
      $0.qrCodeRepository = mockQRCodeRepository
    } operation: {
      let useCase = QRCodeUseCaseImpl()
      return try await useCase.createQRCode(userID: 123)
    }

    // Then: 결과 검증
    #expect(qrCode == "user_123_qrcode", "QR 코드가 생성되어야 함")
    #expect(mockQRCodeRepository.createQRCodeCallCount == 1, "createQRCode 1회 호출")
    #expect(mockQRCodeRepository.lastCreateUserID == 123, "올바른 사용자 ID 전달")
  }

  @Test("TC-002: QR 코드 생성 실패 (네트워크 오류)")
  func test_create_qr_code_network_failure() async throws {
    // Given: 네트워크 오류 설정
    mockQRCodeRepository.configureCreateFailure(QRCodeError.unknownError("네트워크 요청에 실패했습니다"))

    // When & Then: QR 코드 생성 실패
    await #expect(throws: QRCodeError.unknownError("네트워크 요청에 실패했습니다")) {
      try await withDependencies {
        $0.qrCodeRepository = mockQRCodeRepository
      } operation: {
        let useCase = QRCodeUseCaseImpl()
        return try await useCase.createQRCode(userID: 123)
      }
    }

    #expect(mockQRCodeRepository.createQRCodeCallCount == 1, "createQRCode 1회 호출")
  }

  @Test("TC-003: QR 코드 생성 실패 (사용자 없음)")
  func test_create_qr_code_user_not_found() async throws {
    // Given: 사용자 없음 오류 설정
    mockQRCodeRepository.configureCreateFailure(QRCodeError.userNotFound)

    // When & Then: QR 코드 생성 실패
    await #expect(throws: QRCodeError.userNotFound) {
      try await withDependencies {
        $0.qrCodeRepository = mockQRCodeRepository
      } operation: {
        let useCase = QRCodeUseCaseImpl()
        return try await useCase.createQRCode(userID: 999)
      }
    }
  }

  // MARK: - QR 코드 이미지 생성 테스트

  @Test("TC-004: QR 코드 이미지 생성 성공")
  func test_generate_qr_code_image_success() async throws {
    // Given: QR 코드 이미지 생성 성공 설정
    let mockImage = Image(systemName: "qrcode")
    mockQRCodeRepository.configureGenerateSuccess(image: mockImage)

    // When: QR 코드 이미지 생성
    let image = await withDependencies {
      $0.qrCodeRepository = mockQRCodeRepository
    } operation: {
      let useCase = QRCodeUseCaseImpl()
      return await useCase.generateQRCode(from: "test_string")
    }

    // Then: 결과 검증
    #expect(image != nil, "QR 코드 이미지가 생성되어야 함")
    #expect(mockQRCodeRepository.generateQRCodeCallCount == 1, "generateQRCode 1회 호출")
    #expect(mockQRCodeRepository.lastGenerateString == "test_string", "올바른 문자열 전달")
  }

  @Test("TC-005: QR 코드 이미지 생성 실패")
  func test_generate_qr_code_image_failure() async throws {
    // Given: QR 코드 이미지 생성 실패 설정 (nil 반환)
    mockQRCodeRepository.generateQRCodeResponse = nil

    // When: QR 코드 이미지 생성
    let image = await withDependencies {
      $0.qrCodeRepository = mockQRCodeRepository
    } operation: {
      let useCase = QRCodeUseCaseImpl()
      return await useCase.generateQRCode(from: "invalid_string")
    }

    // Then: 결과 검증
    #expect(image == nil, "QR 코드 이미지 생성에 실패해야 함")
    #expect(mockQRCodeRepository.generateQRCodeCallCount == 1, "generateQRCode 1회 호출")
  }

  @Test("TC-006: 빈 문자열로 QR 코드 이미지 생성")
  func test_generate_qr_code_empty_string() async throws {
    // Given: 빈 문자열로 QR 코드 생성
    mockQRCodeRepository.generateQRCodeResponse = nil

    // When: 빈 문자열로 QR 코드 이미지 생성
    let image = await withDependencies {
      $0.qrCodeRepository = mockQRCodeRepository
    } operation: {
      let useCase = QRCodeUseCaseImpl()
      return await useCase.generateQRCode(from: "")
    }

    // Then: 결과 검증
    #expect(image == nil, "빈 문자열로는 QR 코드 생성 실패")
    #expect(mockQRCodeRepository.lastGenerateString == "", "빈 문자열 전달 확인")
  }

  // MARK: - QR 코드 검증 테스트

  @Test("TC-007: QR 코드 검증 성공 (출석)")
  func test_qr_validate_success_attended() async throws {
    // Given: QR 코드 검증 성공 설정
    mockQRCodeRepository.configureValidateSuccess(
      status: AttendanceStatus.attended,
      message: "출석 완료"
    )

    // When: QR 코드 검증
    let result = try await withDependencies {
      $0.qrCodeRepository = mockQRCodeRepository
    } operation: {
      let useCase = QRCodeUseCaseImpl()
      return try await useCase.qrValidateCheck(from: "valid_qr_code")
    }

    // Then: 결과 검증
    #expect(result.isSuccess == true, "QR 검증 성공")
    #expect(result.status == AttendanceStatus.attended, "출석 상태 확인")
    #expect(result.message == "출석 완료", "성공 메시지 확인")
    #expect(mockQRCodeRepository.qrValidateCheckCallCount == 1, "qrValidateCheck 1회 호출")
    #expect(mockQRCodeRepository.lastValidateCode == "valid_qr_code", "올바른 QR 코드 전달")
  }

  @Test("TC-008: QR 코드 검증 성공 (지각)")
  func test_qr_validate_success_late() async throws {
    // Given: 지각 상태 QR 코드 검증 성공 설정
    mockQRCodeRepository.configureValidateSuccess(
      status: AttendanceStatus.late,
      message: "지각 처리됨"
    )

    // When: QR 코드 검증
    let result = try await withDependencies {
      $0.qrCodeRepository = mockQRCodeRepository
    } operation: {
      let useCase = QRCodeUseCaseImpl()
      return try await useCase.qrValidateCheck(from: "late_qr_code")
    }

    // Then: 결과 검증
    #expect(result.isSuccess == true, "QR 검증 성공")
    #expect(result.status == AttendanceStatus.late, "지각 상태 확인")
    #expect(result.message == "지각 처리됨", "지각 메시지 확인")
  }

  @Test("TC-009: QR 코드 검증 실패 (잘못된 코드)")
  func test_qr_validate_invalid_code() async throws {
    // Given: 잘못된 QR 코드 설정
    mockQRCodeRepository.configureValidateFailure(QRCodeError.invalidPayload)

    // When & Then: QR 코드 검증 실패
    await #expect(throws: QRCodeError.invalidPayload) {
      try await withDependencies {
        $0.qrCodeRepository = mockQRCodeRepository
      } operation: {
        let useCase = QRCodeUseCaseImpl()
        return try await useCase.qrValidateCheck(from: "invalid_code")
      }
    }

    #expect(mockQRCodeRepository.qrValidateCheckCallCount == 1, "qrValidateCheck 1회 호출")
  }

  @Test("TC-010: QR 코드 검증 실패 (네트워크 오류)")
  func test_qr_validate_network_error() async throws {
    // Given: 네트워크 오류 설정
    mockQRCodeRepository.configureValidateFailure(QRCodeError.unknownError("네트워크 요청에 실패했습니다"))

    // When & Then: QR 코드 검증 실패
    await #expect(throws: QRCodeError.unknownError("네트워크 요청에 실패했습니다")) {
      try await withDependencies {
        $0.qrCodeRepository = mockQRCodeRepository
      } operation: {
        let useCase = QRCodeUseCaseImpl()
        return try await useCase.qrValidateCheck(from: "network_fail_code")
      }
    }
  }

  @Test("TC-011: QR 코드 검증 실패 (권한 없음)")
  func test_qr_validate_unauthorized() async throws {
    // Given: 권한 없음 오류 설정
    mockQRCodeRepository.configureValidateFailure(QRCodeError.invalidSession)

    // When & Then: QR 코드 검증 실패
    await #expect(throws: QRCodeError.invalidSession) {
      try await withDependencies {
        $0.qrCodeRepository = mockQRCodeRepository
      } operation: {
        let useCase = QRCodeUseCaseImpl()
        return try await useCase.qrValidateCheck(from: "unauthorized_code")
      }
    }
  }

  // MARK: - 통합 플로우 테스트

  @Test("TC-012: 완전한 QR 코드 플로우 (생성 → 이미지 생성 → 검증)")
  func test_complete_qr_flow() async throws {
    // Given: 전체 플로우 성공 설정
    mockQRCodeRepository = MockQRCodeRepository.fullSuccess()

    // When: 전체 플로우 실행
    let (qrCode, image, validationResult) = try await withDependencies {
      $0.qrCodeRepository = mockQRCodeRepository
    } operation: {
      let useCase = QRCodeUseCaseImpl()

      // 1. QR 코드 생성
      let qrCode = try await useCase.createQRCode(userID: 123)

      // 2. QR 코드 이미지 생성
      let image = await useCase.generateQRCode(from: qrCode)

      // 3. QR 코드 검증
      let validation = try await useCase.qrValidateCheck(from: qrCode)

      return (qrCode, image, validation)
    }

    // Then: 전체 플로우 검증
    #expect(qrCode == "mock_qr_code_123", "QR 코드 생성 성공")
    #expect(image != nil, "QR 이미지 생성 성공")
    #expect(validationResult.isSuccess == true, "QR 검증 성공")
    #expect(validationResult.status == AttendanceStatus.attended, "출석 상태 확인")

    // 호출 횟수 검증
    #expect(mockQRCodeRepository.createQRCodeCallCount == 1, "createQRCode 1회 호출")
    #expect(mockQRCodeRepository.generateQRCodeCallCount == 1, "generateQRCode 1회 호출")
    #expect(mockQRCodeRepository.qrValidateCheckCallCount == 1, "qrValidateCheck 1회 호출")
  }

  @Test("TC-013: 동시 QR 코드 요청 처리")
  func test_concurrent_qr_operations() async throws {
    // Given: 동시성 테스트를 위한 설정
    mockQRCodeRepository = MockQRCodeRepository.concurrency()

    // When: 동시 QR 코드 요청
    await withDependencies {
      $0.qrCodeRepository = mockQRCodeRepository
    } operation: {
      let useCase = QRCodeUseCaseImpl()

      await withTaskGroup(of: Void.self) { group in
        // 동시에 5개의 QR 코드 생성 요청
        for i in 1...5 {
          group.addTask {
            do {
              _ = try await useCase.createQRCode(userID: i)
            } catch {
              // 동시성 테스트에서는 에러 무시
            }
          }
        }
      }
    }

    // Then: 모든 요청이 처리되었는지 확인
    #expect(mockQRCodeRepository.createQRCodeCallCount == 5, "5개의 동시 요청 모두 처리")
  }

  @Test("TC-014: QR 코드 경계값 테스트")
  func test_qr_code_boundary_values() async throws {
    // Given: 다양한 경계값 테스트
    mockQRCodeRepository.configureCreateSuccess()

    let testCases = [
      (userID: 1, description: "최소 사용자 ID"),
      (userID: Int.max, description: "최대 사용자 ID"),
      (userID: 0, description: "0 사용자 ID"),
      (userID: -1, description: "음수 사용자 ID")
    ]

    // When & Then: 각 경계값 테스트
    for testCase in testCases {
      let qrCode = try await withDependencies {
        $0.qrCodeRepository = mockQRCodeRepository
      } operation: {
        let useCase = QRCodeUseCaseImpl()
        return try await useCase.createQRCode(userID: testCase.userID)
      }

      #expect(!qrCode.isEmpty, "\(testCase.description): QR 코드가 생성되어야 함")
      #expect(mockQRCodeRepository.lastCreateUserID == testCase.userID, "\(testCase.description): 올바른 사용자 ID 전달")
    }
  }

  @Test("TC-015: QR 코드 성능 테스트 시뮬레이션")
  func test_qr_performance_simulation() async throws {
    // Given: 성능 테스트를 위한 대량 요청 시뮬레이션
    mockQRCodeRepository.configureCreateSuccess()

    // When: 100개의 QR 코드 생성 요청
    let startTime = ContinuousClock().now

    try await withDependencies {
      $0.qrCodeRepository = mockQRCodeRepository
    } operation: {
      let useCase = QRCodeUseCaseImpl()

      for i in 1...100 {
        _ = try await useCase.createQRCode(userID: i)
      }
    }

    let endTime = ContinuousClock().now
    let duration = endTime - startTime

    // Then: 성능 기대치 확인
    #expect(mockQRCodeRepository.createQRCodeCallCount == 100, "100개 요청 모두 처리")
    #expect(duration < .seconds(1), "1초 내에 100개 요청 처리 완료")
  }
}
