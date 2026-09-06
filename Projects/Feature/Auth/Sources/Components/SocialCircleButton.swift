//
//  SocialCircleButton.swift
//  Auth
//
//  Created by DDD on 12/19/25.
//

import SwiftUI
import AuthenticationServices
import DDDAccessibility


import ComposableArchitecture
import AuthDomainInterface

struct SocialCircleButtonView: View {
  @State var store: StoreOf<LoginFeature>
  let type: SocialType
  let onTap: () -> Void
  @State private var isPressed = false

  private let circleSize: CGFloat = 44

  @ViewBuilder
  var body: some View {
    switch type {
    case .apple:
      ZStack {
        SignInWithAppleButton(.signIn) { request in
          store.send(.async(.prepareAppleRequest(request)))
        } onCompletion: { result in
          store.send(.async(.appleLogin(result, nonce: store.nonce)))
        }
        .frame(width: circleSize, height: circleSize)
        .clipShape(Circle())
        .allowsHitTesting(true)

        Circle()
          .fill(.black)
          .frame(width: circleSize, height: circleSize)
          .shadow(color: .gray40, radius: 5, x: 0, y: 0)
          .allowsHitTesting(false)

        Image(systemName: type.image)
          .renderingMode(.template) // 효율적인 시스템 이미지 렌더링
          .resizable()
          .scaledToFit()
          .frame(width: 18, height: 30)
          .foregroundColor(.white)
          .allowsHitTesting(false)
      }
      .scaleEffect(isPressed ? 0.95 : 1.0)
      .animation(.spring(response: 0.52, dampingFraction: 0.94, blendDuration: 0.14), value: isPressed)
      .dddAccessibilityID(AuthAccessibilityID.Login.socialButton(type))

    case .google:
      Button(action: onTap) {
        Circle()
          .fill(.white)
          .overlay(Circle().stroke(.gray40, lineWidth: 1))
          .frame(width: circleSize, height: circleSize)
          .shadow(color: .gray40, radius: 5, x: 0, y: 0)
          .overlay(
            Image(assetName: type.image)
              .renderingMode(.original) // 커스텀 이미지 원본 렌더링 최적화
              .resizable()
              .scaledToFit()
              .frame(width: 20, height: 20)
          )
      }
      .buttonStyle(.plain)
      .scaleEffect(isPressed ? 0.95 : 1.0)
      .animation(.spring(response: 0.52, dampingFraction: 0.94, blendDuration: 0.14), value: isPressed)
      .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
          isPressed = pressing
        }
      }, perform: {})
      .dddAccessibilityID(AuthAccessibilityID.Login.socialButton(type))

    }
  }
}
