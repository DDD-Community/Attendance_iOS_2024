//
//  LoginView.swift
//  Presentation
//
//  Created by DDD on 10/29/24.
//

import DDDCoreUI
import DDDAccessibility
import AuthenticationServices
import SwiftUI

import DDDDesignKit

import ComposableArchitecture
import AuthDomainInterface

@ViewAction(for: LoginFeature.self)
public struct LoginView: View {
  @Bindable public var store: StoreOf<LoginFeature>
  
  public init(store: StoreOf<LoginFeature>) {
    self.store = store
  }
  
  public var body: some View {
    ZStack {
      Color.backGroundPrimary
        .edgesIgnoringSafeArea(.all)
      
      VStack {
        Spacer()
          .frame(height: UIScreen.screenHeight * 0.3)
        
        logoImageView()
        
        socialLoginButton()
      }
    }
    .accessibilityElement(children: .contain)
    .dddAccessibilityID(AuthAccessibilityID.Login.root)
    .dddToast()
    .dddAlert($store.scope(state: \.customAlert, action: \.scope.customAlert))
  }
}

extension LoginView {
  @ViewBuilder
  private func logoImageView() -> some View {
    VStack {
      Image(asset: .appLogo)
        .resizable()
        .scaledToFit()
        .frame(width: 65, height: 72)
        .dddAccessibilityID(AuthAccessibilityID.Login.logo)
      
      Spacer()
    }
  }
  
  @ViewBuilder
  private func socialLoginButton() -> some View {
    VStack {
      HStack(alignment: .center, spacing: 24) {
        ForEach(SocialType.allCases) { type in
          SocialCircleButtonView(
            store: store,
            type: type
          ) {
            send(.signInWithSocial(social: type))
          }
        }
      }

      Spacer()
        .frame(height: 40)
      
    }
    .padding(.horizontal, 20)
  }
}


#Preview {
  LoginView(
    store: .init(
      initialState: LoginFeature.State(),
      reducer: {
        LoginFeature()
      })
  )
}
