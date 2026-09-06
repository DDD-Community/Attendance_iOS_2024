//
//  MockQRCodeRepository.swift
//  Repository
//
//  Created by DDD on 7/23/25.
//

import SwiftUI

import AttendanceDomainInterface


final public class MockQRCodeRepository: QRCodeInterface {
  
  public init() {}
  
  public func createQRCode(userID: Int) async throws(QRCodeError) -> String {
    return ""
  }
  
  public func generateQRCode(from string: String) async -> Image? {
    return nil
  }
  
  public func qrValidateCheck(
    from code: String
  ) async throws(QRCodeError) -> QRValidateEntity {
    return QRValidateEntity(
      isSuccess: true,
      code: code,
      message: "QR 인증 완료",
      detail: "출석 체크가 완료되었습니다."
    )
  }
}
