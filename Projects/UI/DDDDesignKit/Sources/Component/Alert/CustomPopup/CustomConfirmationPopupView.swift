//
//  CustomConfirmationPopupView.swift
//  DDDDesignKit
//
//  Created by DDD on 1/4/26.
//

import SwiftUI

struct CustomConfirmationPopup: View {
  private let title: String
  private let message: String
  private let confirmTitle: String
  private let cancelTitle: String
  private let isDestructive: Bool
  private let style: CustomAlertStyle
  private let checkboxTitle: String
  private let onConfirm: () -> Void
  private let onCancel: () -> Void
  private let onPolicyTap: () -> Void
  @State private var isChecked = false
  @State private var isContentVisible = false

  init(
    title: String,
    message: String,
    confirmTitle: String,
    cancelTitle: String,
    isDestructive: Bool,
    style: CustomAlertStyle,
    checkboxTitle: String,
    onConfirm: @escaping () -> Void,
    onCancel: @escaping () -> Void,
    onPolicyTap: @escaping () -> Void
  ) {
    self.title = title
    self.message = message
    self.confirmTitle = confirmTitle
    self.cancelTitle = cancelTitle
    self.isDestructive = isDestructive
    self.style = style
    self.checkboxTitle = checkboxTitle
    self.onConfirm = onConfirm
    self.onCancel = onCancel
    self.onPolicyTap = onPolicyTap
  }

  var body: some View {
    ZStack {
      Color.black
        .opacity(isContentVisible ? 0.6 : 0)
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
          switch style {
          case .consent:
            break
          case .startConfirmation, .endConfirmation:
            // 우측 accent 버튼(onCancel)이 실행 액션이므로 dim 탭은 닫기(onConfirm)로 처리
            onConfirm()
          case .confirmation:
            onCancel()
          }
        }

      Group {
        switch style {
        case .consent:
          consentContent
        case .startConfirmation:
          accentConfirmContent(accent: .blue45)
        case .endConfirmation:
          accentConfirmContent(accent: .statusErrorText)
        case .confirmation:
          confirmationContent
        }
      }
      .offset(y: isContentVisible ? 0 : 120)
      .opacity(isContentVisible ? 1 : 0)
    }
    .onAppear {
      withAnimation(.appModal) {
        isContentVisible = true
      }
    }
  }

  private var confirmationContent: some View {
    VStack(alignment: .center, spacing: 24) {
      VStack(alignment: .center, spacing: 8) {
        Text(title)
          .dddFont(.title3NormalBold)
          .foregroundStyle(.staticWhite)
          .multilineTextAlignment(.center)

        if !message.isEmpty {
          Text(message)
            .dddFont(.body3NormalRegular)
            .foregroundStyle(.textSecondary)
            .multilineTextAlignment(.center)
        }
      }

      HStack(spacing: 12) {
        Button {
          onConfirm()
        } label: {
          Text(confirmTitle)
            .pretendardFont(family: .Medium, size: 16)
            .foregroundStyle(.staticWhite)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
        }
        .background(.gray80)
        .clipShape(.rect(cornerRadius: 20))
        .contentShape(.rect(cornerRadius: 20))

        Button {
          onCancel()
        } label: {
          Text(cancelTitle)
            .pretendardFont(family: .Medium, size: 16)
            .foregroundStyle(.staticWhite)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
        }
        .background(.blue40)
        .clipShape(.rect(cornerRadius: 20))
        .contentShape(.rect(cornerRadius: 20))
      }
    }
    .padding(.vertical, 32)
    .padding(.horizontal, 24)
    .frame(width: 320)
    .background(.gray90)
    .clipShape(.rect(cornerRadius: 20))
    .onTapGesture {}
    .padding(.horizontal, 10)
  }

  /// 운영진 투표 시작/종료 확인 전용 스타일 (Figma: 시작확인/종료확인 모달).
  /// 다른 확인 팝업과 분리된 디자인 — 좌측 회색 confirm, 우측 accent cancel.
  /// - Parameter accent: 우측 강조 버튼 배경색 (시작=파랑, 종료=빨강)
  private func accentConfirmContent(accent: Color) -> some View {
    VStack(alignment: .center, spacing: 0) {
      Text(title)
        .pretendardFont(family: .Bold, size: 18)
        .foregroundStyle(.staticWhite)
        .multilineTextAlignment(.center)

      if !message.isEmpty {
        Color.clear.frame(height: 10)

        Text(message)
          .pretendardFont(family: .Medium, size: 14)
          .foregroundStyle(.textCaption)
          .multilineTextAlignment(.center)
          .lineSpacing(4)
      }

      Color.clear.frame(height: 22)

      HStack(spacing: 8) {
        Button {
          onConfirm()
        } label: {
          Text(confirmTitle)
            .pretendardFont(family: .Bold, size: 16)
            .foregroundStyle(.staticWhite)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
        }
        .background(.gray80)
        .clipShape(.rect(cornerRadius: 10))
        .contentShape(.rect(cornerRadius: 10))

        Button {
          onCancel()
        } label: {
          Text(cancelTitle)
            .pretendardFont(family: .Bold, size: 16)
            .foregroundStyle(.staticWhite)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
        }
        .background(accent)
        .clipShape(.rect(cornerRadius: 10))
        .contentShape(.rect(cornerRadius: 10))
      }
    }
    .padding(.top, 26)
    .padding(.bottom, 16)
    .padding(.horizontal, 20)
    .frame(maxWidth: .infinity)
    .background(.gray90)
    .clipShape(.rect(cornerRadius: 16))
    .onTapGesture {}
    .padding(.horizontal, 48) // 화면 양옆 48 (Figma: 375 기준 너비 280)
  }

  private var consentContent: some View {
    VStack(alignment: .center, spacing: 16) {
      Text(title)
        .dddFont(.title3NormalBold)
        .foregroundStyle(.staticWhite)
        .multilineTextAlignment(.center)

      if !message.isEmpty {
        Text(message)
          .dddFont(.body3NormalRegular)
          .foregroundStyle(.textSecondary)
          .multilineTextAlignment(.center)
      }

      HStack(spacing: 8) {
        Button {
          isChecked.toggle()
          if isChecked {
            onConfirm()
          }
        } label: {
          RoundedRectangle(cornerRadius: 4)
            .stroke(.gray60, lineWidth: 1)
            .frame(width: 15, height: 15)
            .overlay {
              if isChecked {
                Image(systemName: "checkmark")
                  .font(.system(size: 12, weight: .bold))
                  .foregroundStyle(.staticWhite)
              }
            }
            .padding(6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)

        DDDUnderlinedTextButton(
          title: checkboxTitle,
          font: .body3NormalRegular,
          foregroundColor: .staticWhite,
          underlineColor: .mediumGray,
          action: onPolicyTap
        )
      }
      .padding(.top, 4)
    }
    .padding(.vertical, 24)
    .padding(.horizontal, 20)
    .frame(width: 300)
    .background(.gray90)
    .clipShape(.rect(cornerRadius: 20))
    .onTapGesture {}
    .padding(.horizontal, 10)
  }
}

#Preview("Item Based") {
  VStack {
    Text("Background Content")
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.gray.opacity(0.2))
  }
  .dddConfirmationPopup(
    item: .withdrawAccount(
      onConfirm: {
      },
      onCancel: {
      }
    )
  )
}

#Preview("Parameter Based") {
  VStack {
    Text("Background Content")
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.gray.opacity(0.2))
  }
  .dddConfirmationPopup(
    isPresented: true,
    title: "정말 탈퇴하시겠습니까?",
    message: "탈퇴 시, 등록된 모든 출석 데이터가 삭제됩니다.",
    confirmTitle: "탈퇴하기",
    cancelTitle: "취소",
    isDestructive: true,
    onConfirm: {
    },
    onCancel: {
    }
  )
}
