//
//  OnBoardingInviteCodeView.swift
//  Presentation
//
//  Created by DDD on 11/2/24.
//

import DDDAccessibility
import DDDSharedUI
import SwiftUI

import DDDDesignKit

import ComposableArchitecture

@ViewAction(for: InviteCodeFeature.self)
public struct InviteCodeView : View {
  @Bindable public var store: StoreOf<InviteCodeFeature>
  @FocusState private var focusedField: InviteCodeFeature.FocusField?

  public init(store: StoreOf<InviteCodeFeature>) {
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
          
          NavigationBackButton {
            store.send(.delegate(.presentBack))
          }
          .dddAccessibilityID(OnBoardingAccessibilityID.InviteCode.backButton)
          
          ScrollView{
            inviteCodeInPutTextView()
            
            inviteCodeView()
            
            isNotValidateCodeErrorText()
            
          }
          .scrollIndicators(.hidden)
          .scrollBounceBehavior(.basedOnSize)
          
          checkInviteCodeButton()
          
          Spacer()
            .frame(height: 20)
          
        }
        .onTapGesture {
          dismissKeyboard()
          focusedField = nil
        }
        .onAppear {
          send(.initInviteCode)
        }
        .onChange(of: focusedField) { _, newValue in
          guard store.focusedField != newValue else { return }
          send(.focusChanged(newValue))
        }
        .onChange(of: store.focusedField) { _, newValue in
          guard focusedField != newValue else { return }
          focusedField = newValue
        }
        .alert($store.scope(state: \.alert, action: \.scope.alert))
      }
      
    }
    .accessibilityElement(children: .contain)
    .dddAccessibilityID(OnBoardingAccessibilityID.InviteCode.root)
  }
}


extension InviteCodeView {

  @ViewBuilder
  private func inviteCodeInPutTextView() -> some View {
    SignUpPartText(
      content: "초대 코드를 입력해 주세요",
      title: "가입을 위해 신규 기수 초대 코드가 필요합니다.",
      subtitle: "받으신 4자리 초대 코드를 입력해 주세요."
    )
  }
  
  
  @ViewBuilder
  private func checkInviteCodeButton() -> some View {
    VStack {
      Spacer()
      
      CustomButton(
        action: {
          store.send(.async(.verifyInviteCode(code: store.totalInviteCode)))
        },
        title: "다음",
        config: CustomButtonConfig.create()
      )
      .isEnable(store.enableButton)
      .dddAccessibilityID(OnBoardingAccessibilityID.InviteCode.confirmButton)
    }
    .padding(.horizontal, 24)
    .fixedSize(horizontal: false, vertical: true)
  }
  
  @ViewBuilder
  private func inviteCodeView() -> some View {
    VStack {
      Spacer()
        .frame(height: 40)
      
      HStack(spacing: 8) {
        Spacer()
        
        inputCodeText(
          text: $store.firstInviteCode,
          isErrorCode: store.isNotAvailableCode,
          field: .first) { moveBack in
            if moveBack {
              focusedField = .first
              store.isNotAvailableCode = false
            } else {
              focusedField = .second
            }
          }
        
        inputCodeText(
          text: $store.secondInviteCode,
          isErrorCode:  store.isNotAvailableCode,
          field: .second) { moveBack in
            if moveBack {
              focusedField = .first
              store.isNotAvailableCode = false
            } else {
              focusedField = .third
            }
          }
        
        inputCodeText(
          text: $store.thirdInviteCode,
          isErrorCode:  store.isNotAvailableCode,
          field: .third) { moveBack in
            if moveBack {
              focusedField = .second
              store.isNotAvailableCode = false
            } else {
              focusedField = .last
            }
          }
        
        inputCodeText(
          text: $store.lastInviteCode,
          isErrorCode: store.isNotAvailableCode,
          field: .last) { moveBack in
            if moveBack {
              focusedField = .third
              store.isNotAvailableCode = false
            }
          }
        
        Spacer()
      }
      .padding(.horizontal, 24)
    }
  }
  
  @ViewBuilder
  private func inputCodeText(
    text: Binding<String>,
    isErrorCode: Bool,
    field: InviteCodeFeature.FocusField,
    completion: @escaping (Bool) -> Void
  ) -> some View {
    RoundedRectangle(cornerRadius: 16)
      .stroke(
        text.wrappedValue.isEmpty ? .blue20 :
        isErrorCode ? .red40 : Color.clear,
        style: .init(lineWidth: text.wrappedValue.isEmpty ? 1.5 : 2)
      )
      .background(
        text.wrappedValue.isEmpty ? Color.clear :
        isErrorCode ? .red10 : .blue10
      )
      .cornerRadius(16)
      .frame(width: 64, height: 64)
      .overlay {
        TextField("", text: text)
          .dddAccessibilityID(OnBoardingAccessibilityID.InviteCode.textField(String(describing: field)))
          .dddFont(.headline7Semibold)
          .foregroundStyle(.gray90)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
          .keyboardType(.numberPad)
          .focused($focusedField, equals: field)
          .onChange(of: text.wrappedValue) { _, newValue in
            if newValue.count > 1 {
              text.wrappedValue = String(newValue.prefix(1))
            }

            if newValue.count == 1 {
              completion(false) // 다음 칸으로 이동 (SwiftUI 자동 메인 스레드)
            } else if newValue.isEmpty {
              completion(true) // 이전 칸으로 이동 (SwiftUI 자동 메인 스레드)
            }
          }
      }
  }

  @ViewBuilder
  private func isNotValidateCodeErrorText() -> some View {
    if store.isNotAvailableCode {
      VStack {
        Spacer()
          .frame(height: 16)
        
        HStack {
          Spacer()
          Image(asset: .error)
            .renderingMode(.template) // 에러 아이콘 템플릿 모드 최적화
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
          
          Spacer()
            .frame(width: 4)
          
          
          Text("코드가 유효하지 않습니다.")
            .dddFont(.body1NormalMedium)
            .foregroundStyle(Color.statusError)
          
          Spacer()
        }
      }
    }
  }
}
