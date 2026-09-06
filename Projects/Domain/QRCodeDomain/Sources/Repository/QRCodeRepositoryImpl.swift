//
//  QRCodeRepositoryImpl.swift
//  QRCodeDomain
//
//  Created by DDD on 7/23/25.
//

import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit

import APIEndpoint
import DDDNetworkInterface
import QRCodeDomainInterface

import Dependencies

final public class QRCodeRepositoryImpl: QRCodeInterface {
  
  @Dependency(\.networkClient) private var client

  public init() {}
  
  // MARK: - QRCode String 생성
  
  public func createQRCode(userID: Int) async throws(QRCodeError) -> String {
    do {
      let response = try await client.send(
        QRService.createQRCode(userID: userID),
        as: CreateQRCodeResponseDTO.self
      )
      return response.qrBase64
    } catch {
      throw .createFailed
    }
  }
  
  // MARK: - QRCode Image 생성
  
  public func generateQRCode(from string: String) async -> SwiftUI.Image? {
    if let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters),
       let uiImage = UIImage(data: data) {
      return Image(uiImage: uiImage)
    }
    return nil
  }
  
  public func qrValidateCheck(from code: String) async throws(QRCodeError) -> QRValidateEntity {
    let response: DDDHTTPResponse
    do {
      response = try await client.sendResponse(QRService.qrAttendanceCheck(qrCode: code))
    } catch {
      throw .validationFailed("QR 코드 검증 요청에 실패했습니다")
    }

    let decoder = JSONDecoder()

    if (200...299).contains(response.statusCode) {
      if response.data.isEmpty {
        return QRValidateEntity(isSuccess: true)
      }
      if let successDTO = try? decoder.decode(QRValidateDTO.self, from: response.data) {
        return successDTO.toDomain(isSuccess: true)
      }
      return QRValidateEntity(isSuccess: true)
    }

    // 400+ 에러는 exception으로 throw
    if let errorDTO = try? decoder.decode(QRValidateDTO.self, from: response.data) {
      // 서버에서 온 상세 메시지 우선 사용
      let userMessage = errorDTO.message ?? "알 수 없는 오류가 발생했습니다"

      switch response.statusCode {
      case 400...499:
        // 클라이언트 오류 - 서버 메시지를 사용자에게 표시
        throw .validationFailed(userMessage)
      case 500...599:
        // 서버 오류
        throw .validationFailed("서버 오류 (코드: \(response.statusCode))")
      default:
        throw .validationFailed(userMessage)
      }
    }

    // JSON 디코딩 실패 시
    throw .invalidPayload
  }
}
