//
//  ScheduleView.swift
//  Presentation
//
//  Created by DDD on 5/9/25.
//

import SwiftUI

import ComposableArchitecture
import DDDAccessibility
import DDDDesignKit

@ViewAction(for: ScheduleFeature.self)
struct ScheduleView: View {
  @Bindable var store: StoreOf<ScheduleFeature>

  init(
    store: StoreOf<ScheduleFeature>
  ) {
    self.store = store
  }

  var body: some View {
    content
      .animation(.easeInOut(duration: 0.2), value: store.viewState)
      // 스켈레톤 분기에서도 조회는 시작돼야 하므로 두 분기를 감싼 바깥에 둔다.
      .onAppear {
        send(.onAppear)
      }
  }

  // 스켈레톤과 본문 사이를 크로스페이드하려면 두 분기를 감싸는 공통 컨테이너가 필요하다.
  @ViewBuilder
  private var content: some View {
    if store.viewState == .loading {
      ScheduleSkeletonView()
        .dddAccessibilityID(ManagementAccessibilityID.Schedule.skeleton)
    } else {
      VStack(spacing: 0) {
        // 메인 콘텐츠
        VStack(alignment: .leading, spacing: 0) {
          // 타이틀
          HStack {
            Text("\(store.userSession.generation) 일정표")
              .dddFont(.title2NormalBold)
              .foregroundStyle(.staticWhite)

            Spacer()
          }
          .padding(.horizontal, 20)
          .padding(.top, 24)
          .padding(.bottom, 20)
          .dddAccessibilityID(ManagementAccessibilityID.Schedule.header)

          // 스케줄 리스트
          scheduleListView()
        }
      }
      .accessibilityElement(children: .contain)
      .dddAccessibilityID(ManagementAccessibilityID.Schedule.root)
    }
  }
}

private extension ScheduleView {
  @ViewBuilder
  func scheduleListView() -> some View {
    ScrollView(.vertical) {
      LazyVStack(spacing: 16) {
        ForEach(store.schedules, id: \.id) { item in
          ScheduleCardView(
            month: "\(item.month)",
            day: "\(item.day)",
            title: item.name,
            description: item.description
          )
          .dddAccessibilityID(ManagementAccessibilityID.Schedule.card(item.id))
        }
      }
      .padding(.horizontal, 20)
      .accessibilityElement(children: .contain)
      .dddAccessibilityID(ManagementAccessibilityID.Schedule.list)
    }
    .scrollIndicators(.hidden)
  }
}
