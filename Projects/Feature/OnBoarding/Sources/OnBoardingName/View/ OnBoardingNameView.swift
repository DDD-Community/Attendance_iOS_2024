//
//   OnBoardingNameView.swift
//  Presentation
//
//  Created by DDD on 11/3/24.
//

import DDDAccessibility
import DDDSharedUI
import SwiftUI

import DDDDesignKit

import ComposableArchitecture


@ViewAction(for: OnBoardingNameFeature.self)
public struct  OnBoardingNameView: View {
  @Bindable public var store: StoreOf<OnBoardingNameFeature>

  public init(store: StoreOf<OnBoardingNameFeature>) {
    self.store = store
  }
  
  
  public var body: some View {
    DDDLazyView {
      ZStack {
        Color.backGroundPrimary
          .edgesIgnoringSafeArea(.all)
        
        VStack {
          
          Spacer()
            .frame(height: 12)
          
          StepNavigationBar(activeStep: 1) {
            store.send(.delegate(.presentBack))
          }
          
          ScrollView {
            signUpNameText()
            
            signUpNameTextField()
            
            errorNameText()
          }
          .scrollIndicators(.hidden)
          .scrollBounceBehavior(.basedOnSize)
          .onAppear {
            UIScrollView.appearance().bounces = false
          }
          
          signUpNameButton()
          
          Spacer()
            .frame(height: 20)
        }
        .onTapGesture {
          dismissKeyboard()
        }
      }
      .onAppear {
        send(.initSignUpName)
      }
    }
    .accessibilityElement(children: .contain)
    .dddAccessibilityID(OnBoardingAccessibilityID.Name.root)
  }
}

extension  OnBoardingNameView {
  
  @ViewBuilder
  private func signUpNameText() -> some View {
    SignUpPartText(
      content: "이름이 어떻게 되시나요?",
      title: "가입하실 때 사용할 이름을 입력해 주세요",
      subtitle: ""
    )
  }
  
  
  @ViewBuilder
  private func signUpNameTextField() -> some View {
    VStack {
      Spacer()
        .frame(height: 40)
      
      RoundedRectangle(cornerRadius: 16)
        .inset(by: 0.5)
        .stroke(store.isNotAvailableName ? .statusError : .borderInactive, lineWidth: 1)
        .frame(height: 56)
        .overlay {
          HStack {
            Spacer()
              .frame(width: 20)
            
            TextField(
              "",
              text: $store.userSession.name,
              prompt: Text("이름을 입력해주세요.")
                .font(.pretendardFontFamily(family: .Medium, size: 16))
                .foregroundColor(.white.opacity(0.6))   // placeholder 색
            )
            .dddAccessibilityID(OnBoardingAccessibilityID.Name.textField)
            .dddFont(.body2NormalMedium)  // 입력 글자 스타일
            .foregroundStyle(.staticWhite)                        // 입력 글자 색
            .frame(maxWidth: .infinity)
            .onChange(of: store.userSession.name) { new, _ in
              if new.count > 5 {
                store.userSession.name = String(new.prefix(5))
                store.isNotAvailableName = false
              }
            }
            
            Spacer()
            
            Image(asset: store.isNotAvailableName ? .errorClose : .close)
              .resizable()
              .scaledToFit()
              .frame(width: 20, height: 20)
              .onTapGesture {
                store.userSession.name = ""
              }
            
            Spacer()
              .frame(width: 20)
          }
        }
      
    }
    .padding(.horizontal, 24)
  }
  
  @ViewBuilder
  private func errorNameText() -> some View {
    if store.isNotAvailableName  {
      VStack {
        Spacer()
          .frame(height: 8)
        
        HStack {
          Label {
            Image(asset: .error)
              .resizable()
              .scaledToFit()
              .frame(width: 20, height: 20)
          } icon: {
            Text("5자 이내의 본명을 입력해주세요")
              .dddFont(.body3NormalMedium)
              .foregroundStyle(.statusError)
          }
        }
        
      }
      .padding(.horizontal, 24)
    }
  }
  
  
  @ViewBuilder
  private func signUpNameButton() -> some View {
    VStack {
      Spacer()
      
      CustomButton(
        action: {
          send(.checkIsAvailableName)
        },
        title: "다음",
        config: CustomButtonConfig.create()
      )
      .isEnable(store.enableButton)
      .dddAccessibilityID(OnBoardingAccessibilityID.Name.nextButton)
    }
    .padding(.horizontal, 24)
  }
  
}
