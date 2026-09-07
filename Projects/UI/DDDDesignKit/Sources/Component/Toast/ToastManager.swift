//
//  ToastManager.swift
//  DDDDesignKit
//
//  Created by DDD on 12/29/25.
//

import Combine
import SwiftUI

@MainActor
public class ToastManager: ObservableObject {
  public static let shared = ToastManager()

  @Published public var currentToast: ToastType?
  @Published public var isVisible = false

  private var dismissTask: Task<Void, Never>?
  private var hideAnimationTask: Task<Void, Never>?

  // 🎯 PFW + 메모리 최적화: WeakSingleton 패턴 고려
  // TODO: SmartSingleton 프로토콜로 마이그레이션 예정
  // public class ToastManager: ObservableObject, SmartSingleton {
  //   required public init() {}

  private init() {}

  public func showToast(
    _ toast: ToastType,
    duration: TimeInterval? = 3.0
  ) {
    // 기존 작업 취소
    dismissTask?.cancel()
    hideAnimationTask?.cancel()

    // 새 토스트 표시
    currentToast = toast
    withAnimation(.easeOut(duration: 0.3)) {
      isVisible = true
    }

    // 자동 dismiss 설정
    guard let duration else {
      dismissTask = nil
      return
    }

    dismissTask = Task { [weak self] in
      try? await Task.sleep(for: .seconds(duration))
      guard !Task.isCancelled else { return }
      self?.hideToast()
    }
  }

  public func hideToast() {
    dismissTask?.cancel()
    dismissTask = nil

    withAnimation(.easeIn(duration: 0.3)) {
      isVisible = false
    }

    // 애니메이션 완료 후 토스트 제거
    hideAnimationTask?.cancel()
    hideAnimationTask = Task { [weak self] in
      try? await Task.sleep(for: .seconds(0.3))
      guard !Task.isCancelled else { return }
      self?.currentToast = nil
    }
  }

  // MARK: - 편의 메소드
  public func showSuccess(_ message: String) {
    showToast(.success(message))
  }

  public func showError(_ message: String) {
    showToast(.error(message))
  }

  public func showWarning(_ message: String) {
    showToast(.warning(message))
  }
  
  public func showInfo(_ message: String) {
    showToast(.info(message))
  }

  public func showLoading(_ message: String) {
    showToast(.loading(message), duration: nil)
  }

  deinit {
    dismissTask?.cancel()
    hideAnimationTask?.cancel()
  }
}
