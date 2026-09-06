//
//  QRCodeInterface.swift
//  DomainInterface
//
//  Created by DDD on 7/23/25.
//

import Foundation
import SwiftUI

import AttendanceDomainInterface

import Dependencies

/// QRCode 관련 비즈니스 로직을 위한 Interface 프로토콜
public protocol QRCodeInterface: Sendable {
  func createQRCode(userID: Int) async throws(QRCodeError) -> String
  func generateQRCode(from string: String) async -> Image?
  func qrValidateCheck(from code: String) async throws(QRCodeError) -> QRValidateEntity
}

/// QRCode Repository의 DependencyKey 구조체
public enum QRCodeRepositoryDependency: TestDependencyKey {

  public static var testValue: QRCodeInterface {
    MockQRCodeRepository()
  }

  public static var previewValue: QRCodeInterface = testValue
}

/// DependencyValues extension으로 간편한 접근 제공
public extension DependencyValues {
  var qrCodeRepository: QRCodeInterface {
    get { self[QRCodeRepositoryDependency.self] }
    set { self[QRCodeRepositoryDependency.self] = newValue }
  }
}
