//
//  KeychainStorage.swift
//  DDDStorage
//
//  Created by DDD on 9/1/26.
//

import Foundation
import Security

import DDDStorageInterface

struct KeychainStorage: SecureStorage {
  // 기존 앱 버전이 저장한 Keychain 항목을 업데이트 후에도 조회할 수 있어야 한다.
  static let defaultService = "io.dddstudy.attendance"

  private let service: String
  private let client: any KeychainClient

  init(
    service: String = Self.defaultService,
    client: any KeychainClient = SystemKeychainClient()
  ) {
    self.service = service
    self.client = client
  }

  func save(_ value: String, for key: SecureStorageKey) throws(SecureStorageError) {
    let data = Data(value.utf8)
    let status = client.update(data, service: service, account: key.rawValue)

    switch status {
    case errSecSuccess:
      return
    case errSecItemNotFound:
      let addStatus = client.add(data, service: service, account: key.rawValue)
      guard addStatus == errSecSuccess else {
        throw SecureStorageError.unexpectedStatus(addStatus)
      }
    default:
      throw SecureStorageError.unexpectedStatus(status)
    }
  }

  func load(_ key: SecureStorageKey) throws(SecureStorageError) -> String? {
    let result = client.load(service: service, account: key.rawValue)
    switch result.status {
    case errSecSuccess:
      guard let data = result.data else { return nil }
      guard let value = String(data: data, encoding: .utf8) else {
        throw SecureStorageError.invalidData
      }
      return value
    case errSecItemNotFound:
      return nil
    default:
      throw SecureStorageError.unexpectedStatus(result.status)
    }
  }

  func remove(_ key: SecureStorageKey) throws(SecureStorageError) {
    let status = client.delete(service: service, account: key.rawValue)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw SecureStorageError.unexpectedStatus(status)
    }
  }

  func removeAll() throws(SecureStorageError) {
    for key in SecureStorageKey.all {
      try remove(key)
    }
  }
}
