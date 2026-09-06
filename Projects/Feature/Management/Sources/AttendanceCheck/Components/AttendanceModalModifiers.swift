//
//  AttendanceModalModifiers.swift
//  Management
//
//  Created by DDD on 1/13/26.
//

import SwiftUI
import DDDDesignKit
import ComposableArchitecture
import AttendanceDomainInterface

public extension View {
  /// TCA Store scope 기반 모달 (권장) - 예: .attendanceModal($store.scope(state: \.attendanceModal, action: \.scope.attendanceModal))
  func attendanceModal(
    _ store: Binding<Store<AttendanceModalState<AttendanceModalAction>, AttendanceModalAction>?>
  ) -> some View {
    self.modifier(
      AttendanceModalStoreModifier(store: store)
    )
  }

  /// AttendanceModalItem을 사용하는 모달
  func attendanceStatusModal(
    item: AttendanceModalItem?
  ) -> some View {
    self.modifier(
      AttendanceStatusModalItemModifier(item: item)
    )
  }

  /// 직접 파라미터를 사용하는 모달
  func attendanceStatusModal(
    isPresented: Bool,
    title: String = "출석 상태를 변경하시겠습니까?",
    initialStatus: AttendanceStatus = .attended,
    availableStatuses: [AttendanceStatus], // API에서 받은 배열 (필수)
    confirmTitle: String = "확인",
    onConfirm: @escaping (AttendanceStatus) -> Void, // AttendanceStatus 반환
    onCancel: @escaping () -> Void
  ) -> some View {
    self.modifier(
      AttendanceStatusModalModifier(
        isPresented: isPresented,
        title: title,
        initialStatus: initialStatus,
        availableStatuses: availableStatuses,
        confirmTitle: confirmTitle,
        onConfirm: onConfirm,
        onCancel: onCancel
      )
    )
  }
}

// MARK: - TCA Store Scope 기반 Modifier (권장)

struct AttendanceModalStoreModifier: ViewModifier {
  @Binding private var store: Store<AttendanceModalState<AttendanceModalAction>, AttendanceModalAction>?

  init(store: Binding<Store<AttendanceModalState<AttendanceModalAction>, AttendanceModalAction>?>) {
    self._store = store
  }

  func body(content: Content) -> some View {
    content
      .overlay {
        if let store = store {
          AttendanceModalView(store: store)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.appModal, value: self.store != nil)
        }
      }
  }
}

// MARK: - TCA 기반 AttendanceModalView

struct AttendanceModalView: View {
  @Bindable var store: StoreOf<AttendanceModalFeature>

  var body: some View {
    AttendanceStatusModal(
      title: store.title,
      initialStatus: store.initialStatus,
      availableStatuses: store.availableStatuses,
      confirmTitle: store.confirmTitle,
      onConfirm: { statusName in
        store.send(.confirmTapped(statusName))
      },
      onCancel: {
        store.send(.cancelTapped)
      }
    )
  }
}

// MARK: - AttendanceStatusModalItemModifier

struct AttendanceStatusModalItemModifier: ViewModifier {
  private let item: AttendanceModalItem?

  init(item: AttendanceModalItem?) {
    self.item = item
  }

  func body(content: Content) -> some View {
    content
      .overlay {
        if let item = item {
          AttendanceStatusModal(
            title: item.title,
            initialStatus: item.initialStatus,
            availableStatuses: item.availableStatuses,
            confirmTitle: item.confirmTitle,
            onConfirm: item.onConfirm,
            onCancel: item.onCancel
          )
          .transition(.move(edge: .bottom).combined(with: .opacity))
          .animation(.appModal, value: true)
        }
      }
  }
}

// MARK: - AttendanceStatusModalModifier

struct AttendanceStatusModalModifier: ViewModifier {
  private let isPresented: Bool
  private let title: String
  private let initialStatus: AttendanceStatus
  private let availableStatuses: [AttendanceStatus]
  private let confirmTitle: String
  private let onConfirm: (AttendanceStatus) -> Void // AttendanceStatus 반환
  private let onCancel: () -> Void

  init(
    isPresented: Bool,
    title: String,
    initialStatus: AttendanceStatus,
    availableStatuses: [AttendanceStatus],
    confirmTitle: String,
    onConfirm: @escaping (AttendanceStatus) -> Void, // AttendanceStatus 반환
    onCancel: @escaping () -> Void
  ) {
    self.isPresented = isPresented
    self.title = title
    self.initialStatus = initialStatus
    self.availableStatuses = availableStatuses
    self.confirmTitle = confirmTitle
    self.onConfirm = onConfirm
    self.onCancel = onCancel
  }

  func body(content: Content) -> some View {
    content
      .overlay {
        if isPresented {
          AttendanceStatusModal(
            title: title,
            initialStatus: initialStatus,
            availableStatuses: availableStatuses,
            confirmTitle: confirmTitle,
            onConfirm: onConfirm,
            onCancel: onCancel
          )
          .transition(.move(edge: .bottom).combined(with: .opacity))
          .animation(.appModal, value: isPresented)
        }
      }
  }
}
