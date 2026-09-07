//
//  GuardedCredentialStore.swift
//  DDDAuth
//
//  Created by DDD on 9/1/26.
//

import Foundation
import os

import DDDCoreLogger
import DDDNetworkInterface

/// 로그아웃 뒤 이미 진행 중이던 refresh가 완료되어 죽은 세션을 되살리는 race를 차단한다.
final class GuardedCredentialStore: CredentialStore {
  /// 실제 credential 영속화를 담당하는 저장소다.
  private let base: any CredentialStore
  /// 로그아웃 후 늦게 도착한 refresh 저장 허용 여부를 원자적으로 관리한다.
  private let isBarred: OSAllocatedUnfairLock<Bool>

  /// 기존 credential 유무를 기준으로 최초 저장 허용 상태를 결정한다.
  init(base: any CredentialStore) {
    self.base = base
    self.isBarred = OSAllocatedUnfairLock(initialState: base.load() == nil)
  }

  /// 다른 저장 연산과 직렬화하여 현재 credential을 읽는다.
  func load() -> DDDCredential? {
    return isBarred.withLock { _ in
      return base.load()
    }
  }

  /// 저장이 허용된 세션에서만 새 credential을 영속화한다.
  func save(_ credential: DDDCredential) {
    let didSave = isBarred.withLock { isBarred in
      guard isBarred == false else {
        return false
      }
      base.save(credential)
      return true
    }

    guard didSave else {
      DDDLogger.notice("signOut 이후 도착한 credential save 무시", category: .auth)
      return
    }
  }

  /// credential을 제거하고 명시적인 새 로그인 전까지 후속 저장을 차단한다.
  func clear() {
    isBarred.withLock { isBarred in
      isBarred = true
      base.clear()
    }
  }

  /// 새 로그인 시작 시 credential 저장 차단을 해제한다.
  func allowSaves() {
    isBarred.withLock { isBarred in
      isBarred = false
    }
  }
}
