//
//  SelectPartView.swift
//  Presentation
//
//  Created by DDD on 11/3/24.
//

import DDDAccessibility
import DDDCoreUI
import DDDSharedUI
import SwiftUI

import DDDDesignKit

import ComposableArchitecture

@ViewAction(for: SelectPartFeature.self)
public struct SelectPartView: View {
  @Bindable public var store: StoreOf<SelectPartFeature>

  public init(store: StoreOf<SelectPartFeature>) {
    self.store = store
  }

  public var body: some View {
    ZStack {
      Color.backGroundPrimary
        .edgesIgnoringSafeArea(.all)

      VStack {
        Spacer()
          .frame(height: 12)

        StepNavigationBar(activeStep: 2) {
          store.send(.delegate(.presentBack))
        }

        // 목록을 받아오는 동안 실제 화면과 같은 자리에서 스켈레톤을 보여준다.
        switch store.viewState {
        case .loading:
          OnBoardingSelectSkeletonView(
            content: "직무를 선택해 주세요",
            title: "프로젝트 참여하시는 직무을 선택해 주세요.",
            bottomSpacing: .fixed(20)
          )
          .dddAccessibilityID(OnBoardingAccessibilityID.SelectPart.skeleton)

        case .loaded:
          signUpPartText()

          selectPartList()

          signUpPartButton()
        }
      }
      .task {
        send(.onAppear)
      }
    }
    .accessibilityElement(children: .contain)
    .dddAccessibilityID(OnBoardingAccessibilityID.SelectPart.root)
  }
}

extension SelectPartView {
  @ViewBuilder
  private func signUpPartText() -> some View {
    SignUpPartText(
      content: "직무를 선택해 주세요",
      title: "프로젝트 참여하시는 직무을 선택해 주세요.",
      subtitle: ""
    )
  }

  @ViewBuilder
  private func selectPartList() -> some View {
    VStack {
      Spacer()
        .frame(height: 40)

      ScrollView {
        LazyVStack {
          ForEach(
            (store.selectJobs ?? []).sorted {
              $0.job.desc.localizedCaseInsensitiveCompare($1.job.desc) == .orderedAscending
            },
            id: \.jobKeys
          ) { item in
            SelectPartItem(
              content: item.job.desc,
              isActive: item.job == store.selectPart
            ) {
              send(.selectPartButton(selectPart: item))
            }
            .dddAccessibilityID(OnBoardingAccessibilityID.SelectPart.item(item.jobKeys))
          }
        }
        .accessibilityElement(children: .contain)
        .dddAccessibilityID(OnBoardingAccessibilityID.SelectPart.list)
      }
      .scrollIndicators(.hidden)
      .frame(height: UIScreen.screenHeight * 0.6)
    }
  }

  @ViewBuilder
  private func signUpPartButton() -> some View {
    VStack {
      Spacer()

      CustomButton(
        action: {
          store.send(.delegate(.presentNextStep))
        },
        title: "다음",
        config: CustomButtonConfig.create()
      )
      .isEnable(store.activeSelectPart)
      .dddAccessibilityID(OnBoardingAccessibilityID.SelectPart.nextButton)

      Spacer()
        .frame(height: 20)
    }
    .padding(.horizontal, 24)
  }
}
