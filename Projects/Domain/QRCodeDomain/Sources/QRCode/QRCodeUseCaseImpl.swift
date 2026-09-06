//
//  QRCodeUseCaseImpl.swift
//  QRCodeDomain
//
//  Created by DDD on 7/23/25.
//

import SwiftUI

import QRCodeDomainInterface

import Dependencies


public struct QRCodeUseCaseImpl: QRCodeUseCaseInterface {
  @Dependency(\.qrCodeRepository) var repository

  public init() { }

  public func createQRCode(userID: Int) async throws(QRCodeError) -> String {
    return try await repository.createQRCode(userID: userID)
  }

  public func generateQRCode(from string: String) async -> Image? {
    await repository.generateQRCode(from: string)
  }

  // MARK: - qrcode 출석체크
  public func qrValidateCheck(
    from code: String
  ) async throws(QRCodeError) -> QRValidateEntity {
    return try await repository.qrValidateCheck(from: code)
  }
}
