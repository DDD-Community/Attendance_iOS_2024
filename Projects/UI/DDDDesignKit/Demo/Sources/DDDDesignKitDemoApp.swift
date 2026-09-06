//
//  DDDDesignKitDemoApp.swift
//  DDDDesignKitDemo
//
//  Created by DDD on 2026-09-02
//
//  DesignKit 컴포넌트를 앱 전체 빌드 없이 확인하기 위한 단독 실행 앱.
//

import SwiftUI

import DDDDesignKit

@main
struct DDDDesignKitDemoApp: App {
  init() {
    // 앱과 동일하게 런타임에 폰트를 등록한다. 등록하지 않으면 pretendardFont 가
    // 시스템 폰트로 대체돼 데모가 실제 화면과 달라진다.
    PretendardFontFamily.registerFonts()
  }

  var body: some Scene {
    WindowGroup {
      DDDDesignKitCatalogView()
    }
  }
}

struct DDDDesignKitCatalogView: View {
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          section("Button") {
            CustomButton(
              action: {},
              title: "기본 버튼 (활성)",
              config: CustomButtonConfig.create(),
              isEnable: true
            )
            CustomButton(
              action: {},
              title: "기본 버튼 (비활성)",
              config: CustomButtonConfig.create(),
              isEnable: false
            )
            CustomButton(
              action: {},
              title: "투표 버튼",
              config: CustomButtonConfig.createVoteButton(),
              isEnable: true
            )
            CustomButton(
              action: {},
              title: "투표 종료 버튼",
              config: CustomButtonConfig.createEndVoteButton(),
              isEnable: true
            )
            CustomButton(
              action: {},
              title: "날짜 버튼",
              config: CustomButtonConfig.createDateButton(),
              isEnable: true
            )
          }

          section("Loading") {
            LoadingView()
              .frame(height: 120)
          }
        }
        .padding(20)
      }
      .navigationTitle("DesignKit")
    }
  }

  @ViewBuilder
  private func section(
    _ title: String,
    @ViewBuilder content: () -> some View
  ) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.headline)
      content()
    }
  }
}
