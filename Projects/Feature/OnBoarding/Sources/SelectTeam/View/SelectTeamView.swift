//
//  SelectTeamView.swift
//  Presentation
//
//  Created by DDD on 11/4/24.
//

import DDDAccessibility
import DDDCoreUI
import DDDSharedUI
import SwiftUI

import DDDDesignKit

import ComposableArchitecture

@ViewAction(for: SelectTeamFeature.self)
public struct SelectTeamView: View {
  @Bindable public var store: StoreOf<SelectTeamFeature>

  public init(store: StoreOf<SelectTeamFeature>) {
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
            content: "팀을 선택해주세요",
            title: "프로젝트 참여하시는 팀을 선택해 주세요."
          )
          .dddAccessibilityID(OnBoardingAccessibilityID.SelectTeam.skeleton)

        case .loaded:
          signUpSelectTeamText()

          selectTeamList()

          signUpSelectTeamButton()
        }
      }
      .onAppear {
        store.userSession.selectTeam = .unknown
        send(.onAppear)
      }
      .alert($store.scope(state: \.alert, action: \.scope.alert))
    }
    .accessibilityElement(children: .contain)
    .dddAccessibilityID(OnBoardingAccessibilityID.SelectTeam.root)
  }
}

extension SelectTeamView {
  @ViewBuilder
  private func signUpSelectTeamText() -> some View {
    SignUpPartText(
      content: "팀을 선택해주세요",
      title: "프로젝트 참여하시는 팀을 선택해 주세요.",
      subtitle: ""
    )
  }

  @ViewBuilder
  private func selectTeamList() -> some View {
    VStack {
      Spacer()
        .frame(height: 40)

      ScrollView {
        VStack {
          ForEach(store.teams ?? [], id: \.teamId) { item in
            SelectTeamIteam(
              content: item.teams.selectTeamDescription,
              isActive: item.teams == store.userSession.selectTeam
            ) {
              send(.selectTeamButton(selectTeam: item))
            }
            .dddAccessibilityID(OnBoardingAccessibilityID.SelectTeam.item(item.teamId))
          }
        }
        .accessibilityElement(children: .contain)
        .dddAccessibilityID(OnBoardingAccessibilityID.SelectTeam.list)
      }
      .scrollIndicators(.hidden)
      .frame(height: UIScreen.screenHeight * 0.6)
    }
  }

  @ViewBuilder
  private func signUpSelectTeamButton() -> some View {
    VStack {
      Spacer()

      CustomButton(
        action: {
          send(.signUp)
        },
        title: "가입 완료",
        config: CustomButtonConfig.create()
      )
      .isEnable(store.activeButton)
      .dddAccessibilityID(OnBoardingAccessibilityID.SelectTeam.nextButton)

      Spacer()
    }
    .padding(.horizontal, 24)
  }
}
