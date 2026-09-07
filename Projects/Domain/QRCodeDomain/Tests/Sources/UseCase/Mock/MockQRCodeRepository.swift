//
//  MockQRCodeRepository.swift
//  QRCodeDomainTests
//
//  Created by DDD on 9/4/26.
//

import SwiftUI

import AttendanceDomainInterface
import QRCodeDomainInterface

@MainActor
final class MockQRCodeRepository: QRCodeInterface {
  private(set) var createQRCodeCallCount = 0
  private(set) var generateQRCodeCallCount = 0
  private(set) var qrValidateCheckCallCount = 0

  private(set) var lastCreateUserID: Int?
  private(set) var lastGenerateString: String?
  private(set) var lastValidateCode: String?

  var createQRCodeResponse: Result<String, QRCodeError> = .failure(.unknownError("네트워크 요청에 실패했습니다"))
  var generateQRCodeResponse: Image? = nil
  var qrValidateCheckResponse: Result<QRValidateEntity, QRCodeError> = .failure(.invalidPayload)

  var createQRCodeDelay: TimeInterval = 0
  var generateQRCodeDelay: TimeInterval = 0
  var qrValidateCheckDelay: TimeInterval = 0

  func createQRCode(userID: Int) async throws(QRCodeError) -> String {
    if createQRCodeDelay > 0 {
      try? await Task.sleep(nanoseconds: UInt64(createQRCodeDelay * 1_000_000_000))
    }
    createQRCodeCallCount += 1
    lastCreateUserID = userID
    return try createQRCodeResponse.get()
  }

  func generateQRCode(from string: String) async -> Image? {
    if generateQRCodeDelay > 0 {
      try? await Task.sleep(nanoseconds: UInt64(generateQRCodeDelay * 1_000_000_000))
    }
    generateQRCodeCallCount += 1
    lastGenerateString = string
    return generateQRCodeResponse
  }

  func qrValidateCheck(from code: String) async throws(QRCodeError) -> QRValidateEntity {
    if qrValidateCheckDelay > 0 {
      try? await Task.sleep(nanoseconds: UInt64(qrValidateCheckDelay * 1_000_000_000))
    }
    qrValidateCheckCallCount += 1
    lastValidateCode = code
    return try qrValidateCheckResponse.get()
  }

  func reset() {
    createQRCodeCallCount = 0
    generateQRCodeCallCount = 0
    qrValidateCheckCallCount = 0
    lastCreateUserID = nil
    lastGenerateString = nil
    lastValidateCode = nil
    createQRCodeResponse = .failure(.unknownError("네트워크 요청에 실패했습니다"))
    generateQRCodeResponse = nil
    qrValidateCheckResponse = .failure(.invalidPayload)
    createQRCodeDelay = 0
    generateQRCodeDelay = 0
    qrValidateCheckDelay = 0
  }

  func configureCreateSuccess(qrCode: String = "mock_qr_code_123") {
    createQRCodeResponse = .success(qrCode)
  }

  func configureGenerateSuccess(image: Image = Image(systemName: "qrcode")) {
    generateQRCodeResponse = image
  }

  func configureValidateSuccess(
    status: AttendanceStatus = AttendanceStatus.attended,
    message: String = "출석 완료"
  ) {
    qrValidateCheckResponse = .success(
      QRValidateEntity(
        isSuccess: true,
        code: "200",
        message: message,
        detail: "QR 코드 검증 성공",
        status: status
      )
    )
  }

  func configureCreateFailure(_ error: Error) {
    createQRCodeResponse = .failure(QRCodeError.from(error))
  }

  func configureValidateFailure(_ error: Error) {
    qrValidateCheckResponse = .failure(QRCodeError.from(error))
  }

  // Static factory methods
  @MainActor
  static func createSuccess() -> MockQRCodeRepository {
    let mock = MockQRCodeRepository()
    mock.configureCreateSuccess()
    return mock
  }

  @MainActor
  static func generateSuccess() -> MockQRCodeRepository {
    let mock = MockQRCodeRepository()
    mock.configureGenerateSuccess()
    return mock
  }

  @MainActor
  static func validateSuccess() -> MockQRCodeRepository {
    let mock = MockQRCodeRepository()
    mock.configureValidateSuccess()
    return mock
  }

  @MainActor
  static func fullSuccess() -> MockQRCodeRepository {
    let mock = MockQRCodeRepository()
    mock.configureCreateSuccess()
    mock.configureGenerateSuccess()
    mock.configureValidateSuccess()
    return mock
  }

  @MainActor
  static func networkError() -> MockQRCodeRepository {
    let mock = MockQRCodeRepository()
    mock.configureCreateFailure(QRCodeError.unknownError("네트워크 요청에 실패했습니다"))
    mock.configureValidateFailure(QRCodeError.unknownError("네트워크 요청에 실패했습니다"))
    return mock
  }

  @MainActor
  static func invalidCode() -> MockQRCodeRepository {
    let mock = MockQRCodeRepository()
    mock.configureValidateFailure(QRCodeError.invalidPayload)
    return mock
  }

  @MainActor
  static func concurrency() -> MockQRCodeRepository {
    let mock = MockQRCodeRepository.fullSuccess()
    mock.createQRCodeDelay = 0.01
    mock.qrValidateCheckDelay = 0.01
    return mock
  }
}
