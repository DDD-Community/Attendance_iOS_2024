//
//  ScheduleModalView.swift
//  Management
//
//  Created by DDD on 12/27/25.
//

import SwiftUI
import ComposableArchitecture
import DDDAccessibility
import DDDSharedUI
import ScheduleDomainInterface

@ViewAction(for: ScheduleModalFeature.self)
public struct ScheduleModalView: View {
  @Bindable public var store: StoreOf<ScheduleModalFeature>

  public init(store: StoreOf<ScheduleModalFeature>) {
    self.store = store
  }

  public var body: some View {
    ZStack {
      Color.staticWhite
        .edgesIgnoringSafeArea(.all)

      VStack {
        switch store.viewState {
        case .loading:
          ScheduleModalSkeletonView()
            .dddAccessibilityID(ManagementAccessibilityID.ScheduleModal.skeleton)

        case .loaded:
          VStack(spacing: 0) {
            scheduleHeader()

            Spacer()
              .frame(height: 20)

            ScrollView(.vertical) {
              scheduleList()
            }
            .scrollIndicators(.hidden)

            Spacer()
              .frame(height: 16)

            confirmButton()
              .padding(.horizontal, 24)
              .padding(.bottom, 16)
          }
        }
      }
      .animation(.easeInOut(duration: 0.2), value: store.viewState)
      .onAppear {
        store.send(.async(.fetchSchedule))
      }
      .dddAccessibilityID(ManagementAccessibilityID.ScheduleModal.root)
    }
  }
}

extension ScheduleModalView {

  @ViewBuilder
  private func scheduleHeader() -> some View {
    VStack(alignment: .center) {
      Spacer()
        .frame(height: 32)

      Text("일정 선택")
        .dddFont(.title2NormalBold)
        .foregroundStyle(.borderInverse)
    }
  }

  @ViewBuilder
  private func scheduleList() -> some View {
    let schedules = store.schedules

    LazyVStack(spacing: 8) {
      ForEach(schedules, id: \.id) { item in
        scheduleCardRow(item: item)
          .id(item.id) // SwiftUI 뷰 재사용 최적화
      }
    }
    .padding(.top, 8)
    .padding(.bottom, 8)
    .dddAccessibilityID(ManagementAccessibilityID.ScheduleModal.list)
  }

  @ViewBuilder
  private func scheduleCardRow(
    item: Schedule
  ) -> some View {
    let isSelected = store.selectedSchedule?.id == item.id

    scheduleCard(item: item, isSelected: isSelected)
      .onTapGesture {
        send(.selectSchedule(item: item))
      }
      .dddAccessibilityID(ManagementAccessibilityID.ScheduleModal.item(item.id))
  }

  @ViewBuilder
   private func scheduleCard(
     item: Schedule,
     isSelected: Bool
   ) -> some View {
     HStack(spacing: 12) {
       VStack(spacing: 2) {
         Text("\(item.month)월")
           .dddFont(.body2NormalMedium)
           .foregroundColor(.staticBlack)

         Text("\(item.day)")
           .dddFont(.title3NormalMedium)
           .foregroundColor(.staticBlack)
       }
       .frame(width: 54, height: 54)
       .background(.blue20)
       .cornerRadius(10)

       VStack(alignment: .leading, spacing: 4) {
         Text(item.name)
           .dddFont(.body1NormalBold)
           .foregroundStyle(.borderInverse)

         Text(item.description)
           .dddFont(.body3NormalRegular)
           .foregroundStyle(.textSecondary100)
       }

       Spacer()

     }
     .padding()
     .background(.backGroundSecondary)
     .cornerRadius(12)
     .background(
       RoundedRectangle(cornerRadius: 12)
         .stroke(isSelected ? .statusFocus : Color.clear, lineWidth: 3)
     )
     .padding(.horizontal, 24)
     .padding(.vertical, 2)
   }



@ViewBuilder
  private func confirmButton() -> some View {
    CustomButton(
      action: {
        send(.confirmSelection)
      },
      title: "확인",
      config: CustomButtonConfig.create()
    )
    .isEnable(store.isConfirmEnabled)
    .dddAccessibilityID(ManagementAccessibilityID.ScheduleModal.confirmButton)
  }
}
