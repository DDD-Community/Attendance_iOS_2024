//
//  SelectManagingView.swift
//  Presentation
//
//  Created by DDD on 11/3/24.
//

import ComposableArchitecture
import DDDAccessibility
import DDDCoreUI
import DDDDesignKit
import DDDSharedUI
import SwiftUI

@ViewAction(for: SelectManagingFeature.self)
public struct SelectManagingView: View {
  @Bindable public var store: StoreOf<SelectManagingFeature>

  public init(store: StoreOf<SelectManagingFeature>) {
    self.store = store
  }

  public var body: some View {
    ZStack {
      Color.backGroundPrimary
        .edgesIgnoringSafeArea(.all)

      VStack {
        Spacer()
          .frame(height: 12)

        StepNavigationBar(activeStep: 3) {
          store.send(.delegate(.presentBack))
        }

        // 목록을 받아오는 동안 실제 화면과 같은 자리에서 스켈레톤을 보여준다.
        switch store.viewState {
        case .loading:
          OnBoardingSelectSkeletonView(
            content: "담당 업무를 선택해주세요",
            title: "프로젝트 참여하시는 직무를 선택해 주세요."
          )
          .dddAccessibilityID(OnBoardingAccessibilityID.SelectManaging.skeleton)

        case .loaded:
          signUpSelectManagingText()

          selectManagingList()

          signUpSelectManageButton()
        }
      }
      .alert($store.scope(state: \.alert, action: \.scope.alert))
      .onAppear {
        store.userSession.managing = []
        send(.onAppear)
      }
    }
    .accessibilityElement(children: .contain)
    .dddAccessibilityID(OnBoardingAccessibilityID.SelectManaging.root)
  }
}

extension SelectManagingView {
  @ViewBuilder
  private func signUpSelectManagingText() -> some View {
    SignUpPartText(
      content: "담당 업무를 선택해주세요",
      title: "프로젝트 참여하시는 직무를 선택해 주세요.",
      subtitle: ""
    )
  }

  @ViewBuilder
  private func selectManagingList() -> some View {
    VStack {
      Spacer()
        .frame(height: 40)

      ScrollView {
        VStack {
          ForEach(store.managers, id: \.managingKeys) { item in
            SelectPartItem(
              content: item.managing.desc,
              isActive: store.userSession.managing.contains(item.managing)
            ) {
              send(.selectManagingButton(selectManaging: item))
            }
            .dddAccessibilityID(OnBoardingAccessibilityID.SelectManaging.item(item.managingKeys))
          }
        }
        .accessibilityElement(children: .contain)
        .dddAccessibilityID(OnBoardingAccessibilityID.SelectManaging.list)
      }
      .scrollIndicators(.hidden)
      .frame(height: UIScreen.screenHeight * 0.6)
    }
  }

  @ViewBuilder
  private func signUpSelectManageButton() -> some View {
    VStack {
      Spacer()

      CustomButton(
        action: {
          if store.userSession.managing.contains(.teamManaging) || store.userSession.userRole == .manager {
            store.send(.delegate(.presentSelectTeam))
          } else {
            send(.signUp)
          }
        },
        title: (store.userSession.managing.contains(.teamManaging) || store.userSession.userRole == .manager) ? "다음" :
          "가입완료",
        config: CustomButtonConfig.create()
      )
      .isEnable(!store.userSession.managing.isEmpty)
      .dddAccessibilityID(OnBoardingAccessibilityID.SelectManaging.nextButton)

      Spacer()
    }
    .padding(.horizontal, 24)
  }
}
