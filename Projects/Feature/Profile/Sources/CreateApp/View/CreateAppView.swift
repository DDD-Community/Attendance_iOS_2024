//
//  CreateAppView.swift
//  Presentation
//
//  Created by DDD on 4/6/25.
//

import SwiftUI

import ComposableArchitecture
import DDDAccessibility
import DDDDesignKit
import ProfileDomainInterface

struct CreateAppView: View {
  @Bindable private var store: StoreOf<CreateAppFeature>

  init(store: StoreOf<CreateAppFeature>) {
    self.store = store
  }

  var body: some View {
    ZStack {
      Color.basicBlack
        .edgesIgnoringSafeArea(.all)

      VStack {
        createAppHeaderView()

        createAppFooterView()

        closeButton()
      }
    }
    .accessibilityElement(children: .contain)
    .dddAccessibilityID(ProfileAccessibilityID.CreateApp.root)
  }
}

private extension CreateAppView {
  @ViewBuilder
  func createAppHeaderView() -> some View {
    VStack(alignment: .center) {
      Spacer()
        .frame(height: 16)

      Text("만든 사람들")
        .dddFont(.title2NormalBold)
        .foregroundStyle(.staticWhite)
    }
  }

  @ViewBuilder
  func createAppFooterView() -> some View {
    VStack(spacing: .zero) {
      createAppPartItem(
        selectPart: .pm,
        creators: "이경서, 최현희"
      )

      createAppPartItem(
        selectPart: .designer,
        creators: "강동길, 이지윤, 조재인"
      )

      createAppPartItem(
        selectPart: .ios,
        creators: "서원지, 홍은표"
      )

      createAppPartItem(
        selectPart: .android,
        creators: "심은석, 오세민, 이상훈"
      )

      createAppPartItem(
        selectPart: .backend,
        creators: "조승준, 조지원, 이준석"
      )
    }
  }

  @ViewBuilder
  func createAppPartItem(
    selectPart: SelectParts,
    creators: String
  ) -> some View {
    VStack(alignment: .center) {
      Spacer()
        .frame(height: 24)

      Text(selectPart.desc)
        .dddFont(.body3NormalRegular)
        .foregroundStyle(.staticWhite)

      Spacer()
        .frame(height: 2)

      Text(creators)
        .dddFont(.title3NormalMedium)
        .foregroundStyle(.staticWhite)
    }
  }

  @ViewBuilder
  func closeButton() -> some View {
    VStack {
      Spacer()
        .frame(height: 36)

      DDDOutlinedButton(title: "앱 피드백 남기기") {
        store.send(.delegate(.presentWeb))
      }
      .dddAccessibilityID(ProfileAccessibilityID.CreateApp.feedbackButton)

      Spacer()
        .frame(height: 8)

      CustomButton(
        action: { store.send(.delegate(.presentBack)) },
        title: "닫기",
        config: CustomButtonConfig.createDateButton()
      )
      .isEnable(true)
      .dddAccessibilityID(ProfileAccessibilityID.CreateApp.closeButton)
    }
    .padding(.horizontal, 24)
  }
}
