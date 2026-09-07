//
//  QRCodeUseCaseInterface.swift
//  QRCodeDomainInterface
//
//  Created by DDD on 9/3/26.
//

import SwiftUI

import Dependencies

public protocol QRCodeUseCaseInterface: Sendable {
  func createQRCode(userID: Int) async throws(QRCodeError) -> String
  func generateQRCode(from string: String) async -> Image?
  func qrValidateCheck(from code: String) async throws(QRCodeError) -> QRValidateEntity
}

extension MockQRCodeRepository: QRCodeUseCaseInterface {}

public enum QRCodeUseCaseDependency: TestDependencyKey {
  public static let testValue: any QRCodeUseCaseInterface = MockQRCodeRepository()
  public static let previewValue: any QRCodeUseCaseInterface = testValue
}

public extension DependencyValues {
  var qrCodeUseCase: any QRCodeUseCaseInterface {
    get { self[QRCodeUseCaseDependency.self] }
    set { self[QRCodeUseCaseDependency.self] = newValue }
  }
}
