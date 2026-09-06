//
//  MemberQRCodeView.swift
//  Presentation
//
//  Created by DDD on 5/18/25.
//

import SwiftUI

import DDDAccessibility
import DDDDesignKit

import ComposableArchitecture

public struct MemberQRCodeView: View {
  @Bindable private var store: StoreOf<MemberQRCodeFeature>

  public init(store: StoreOf<MemberQRCodeFeature>) {
    self.store = store
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: .zero) {
      navigationBar

      content

      Spacer()
    }
    .background(.backGroundPrimary)
    .accessibilityElement(children: .contain)
    .dddAccessibilityID(MemberAccessibilityID.QRCode.root)
    .onAppear {
      store.send(.view(.onAppear))
    }
  }

  private var navigationBar: some View {
    HStack {
      Button {
        store.send(.delegate(.presentBack))
      } label: {
        Image(asset: .arrowBackWhite)
          .resizable()
          .scaledToFit()
          .frame(width: 12, height: 20)
      }
      .frame(width: 28, height: 28)
      .dddAccessibilityID(MemberAccessibilityID.QRCode.backButton)

      Spacer()
    }
    .frame(height: 52)
    .padding(.leading, 16)
  }

  private var content: some View {
    VStack(alignment: .center, spacing: 32) {
      VStack(alignment: .center, spacing: 6) {
        Text("QR 코드를 스캔해 주세요.")
          .dddFont(.title2NormalBold)
          .foregroundStyle(.textPrimary)

        Text("스캔 시 자동으로 출석이 인정됩니다.")
          .dddFont(.body3NormalMedium)
          .foregroundStyle(.textSecondary)
      }

      if store.viewState == .loading {
        MemberQRCodeSkeletonView()
          .dddAccessibilityID(MemberAccessibilityID.QRCode.skeleton)
      } else if let image = store.qrCodeImage {
        image
          .interpolation(.none)
          .resizable()
          .scaledToFit()
          .frame(width: 270, height: 270)
          .padding(10)
          .background(.white)
          .cornerRadius(24)
          .dddAccessibilityID(MemberAccessibilityID.QRCode.image)
      } else {
        Text("QR 코드를 불러오지 못했어요.")
          .dddFont(.body2NormalMedium)
          .foregroundStyle(.textSecondary)
          .frame(width: 270, height: 270)
      }
    }
    .padding(.top, 64)
    .frame(maxWidth: .infinity)
  }
}
