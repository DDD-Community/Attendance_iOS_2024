//
//  CustomAlertModifiers.swift
//  DDDSharedUI
//
//  Created by DDD on 1/4/26.
//

import SwiftUI

import DDDDesignKit

import ComposableArchitecture

public extension View {
  func dddConfirmationPopup(
    item: AlertItem?
  ) -> some View {
    self.modifier(
      CustomConfirmationPopupItemModifier(item: item)
    )
  }

  func dddAlert(
    _ store: Binding<Store<CustomAlertState<CustomAlertAction>, CustomAlertAction>?>
  ) -> some View {
    self.overlay {
      if let alertStore = store.wrappedValue {
        let alertState = alertStore.withState { $0 }
        CustomConfirmationPopup(
          title: alertState.title,
          message: alertState.message,
          confirmTitle: alertState.confirmTitle,
          cancelTitle: alertState.cancelTitle,
          isDestructive: alertState.isDestructive,
          style: alertState.style,
          checkboxTitle: alertState.checkboxTitle,
          onConfirm: {
            alertStore.send(.confirmTapped)
          },
          onCancel: {
            alertStore.send(.cancelTapped)
          },
          onPolicyTap: {
            alertStore.send(.policyTapped)
          }
        )
        .transition(.opacity.animation(.appModal))
      }
    }
  }

  func dddConfirmationPopup(
    isPresented: Bool,
    title: String,
    message: String,
    confirmTitle: String = "확인",
    cancelTitle: String = "취소",
    isDestructive: Bool = false,
    onConfirm: @escaping () -> Void,
    onCancel: @escaping () -> Void,
    onPolicyTap: @escaping () -> Void = {}
  ) -> some View {
    self.modifier(
      CustomConfirmationPopupModifier(
        isPresented: isPresented,
        title: title,
        message: message,
        confirmTitle: confirmTitle,
        cancelTitle: cancelTitle,
        isDestructive: isDestructive,
        onConfirm: onConfirm,
        onCancel: onCancel,
        onPolicyTap: onPolicyTap
      )
    )
  }
}

struct CustomConfirmationPopupItemModifier: ViewModifier {
  private let item: AlertItem?

  init(item: AlertItem?) {
    self.item = item
  }

  func body(content: Content) -> some View {
    content
      .overlay {
        if let item = item {
          CustomConfirmationPopup(
            title: item.title,
            message: item.message,
            confirmTitle: item.confirmTitle,
            cancelTitle: item.cancelTitle,
            isDestructive: item.isDestructive,
            style: .confirmation,
            checkboxTitle: "",
            onConfirm: item.onConfirm,
            onCancel: item.onCancel,
            onPolicyTap: item.onPolicyTap
          )
          .transition(.opacity.animation(.appModal))
        }
      }
  }
}

struct CustomConfirmationPopupModifier: ViewModifier {
  private let isPresented: Bool
  private let title: String
  private let message: String
  private let confirmTitle: String
  private let cancelTitle: String
  private let isDestructive: Bool
  private let onConfirm: () -> Void
  private let onCancel: () -> Void
  private let onPolicyTap: () -> Void

  init(
    isPresented: Bool,
    title: String,
    message: String,
    confirmTitle: String,
    cancelTitle: String,
    isDestructive: Bool,
    onConfirm: @escaping () -> Void,
    onCancel: @escaping () -> Void,
    onPolicyTap: @escaping () -> Void
  ) {
    self.isPresented = isPresented
    self.title = title
    self.message = message
    self.confirmTitle = confirmTitle
    self.cancelTitle = cancelTitle
    self.isDestructive = isDestructive
    self.onConfirm = onConfirm
    self.onCancel = onCancel
    self.onPolicyTap = onPolicyTap
  }

  func body(content: Content) -> some View {
    content
      .overlay {
        if isPresented {
          CustomConfirmationPopup(
            title: title,
            message: message,
            confirmTitle: confirmTitle,
            cancelTitle: cancelTitle,
            isDestructive: isDestructive,
            style: .confirmation,
            checkboxTitle: "",
            onConfirm: onConfirm,
            onCancel: onCancel,
            onPolicyTap: onPolicyTap
          )
          .transition(.opacity.animation(.appModal))
        }
      }
  }
}
