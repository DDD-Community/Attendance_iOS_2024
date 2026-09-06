//
//  MemberMainView.swift
//  Presentation
//
//  Created by DDD on 1/2/25.
//

import DDDAccessibility
import DDDSharedUI
import SwiftUI

import DDDDesignKit

import ComposableArchitecture

@ViewAction(for: MemberMainFeature.self)
public struct MemberMainView: View {
  @Bindable public var store: StoreOf<MemberMainFeature>
  @State private var isDropDownClosing = false

  public init(store: StoreOf<MemberMainFeature>) {
    self.store = store
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: .zero) {
      topNavigationBar

      switch store.selectedHomeTab {
      case .attendance:
        ScrollView {
          VStack(alignment: .leading, spacing: 56) {
            attendanceStatus

            generationScheduleListView
          }
          .padding(.horizontal, 24)
        }
        .scrollIndicators(.hidden)

      case .vote:
        MemberVoteView(store: store.scope(state: \.vote, action: \.vote))
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(.backGroundPrimary)
    .dddAccessibilityID(MemberAccessibilityID.root)
    .overlay {
      dropDownOverlay()
    }
    .overlay {
      dropDownInteractionBlocker
    }
    .overlay {
      if store.viewState == .loading {
        MemberMainSkeletonView()
          .transition(.opacity)
          .dddAccessibilityID(MemberAccessibilityID.skeleton)
      }
    }
    .animation(.easeInOut(duration: 0.2), value: store.viewState)
    .allowsHitTesting(store.viewState == .loaded)
    .dddAlert(
      isPresented: store.isAttendanceWarningAlertPresented,
      title: "주의해주세요!",
      message: "2번 지각 시 노쇼비를 돌려받을 수 없습니다.",
      onConfirm: {
        send(.didTapDismissAlertButton)
      }
    )
    .dddAlert($store.scope(state: \.vote.exitAlert, action: \.vote.scope.exitAlert))
    .onAppear {
      send(.onAppear)
    }
    .onDisappear {
      send(.onDisappear)
    }
  }

  @ViewBuilder
  private var topNavigationBar: some View {
    if store.usesVoteWritingNavigationBar {
      voteWritingNavigationBar
    } else {
      navigationBar
    }
  }

  private var navigationBar: some View {
    HStack(spacing: .zero) {
      Button {
        if store.isExpandedDropDown {
          closeDropDown()
        } else {
          openDropDown()
        }
      } label: {
        HStack(spacing: 6) {
          Text(store.selectedHomeTab.title)
            .pretendardFont(family: .Bold, size: 24)
            .foregroundStyle(.staticWhite)

          Image(systemName: store.isExpandedDropDown ? "chevron.up" : "chevron.down")
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.staticWhite)
        }
      }
      .buttonStyle(.plain)
      .dddAccessibilityID(MemberAccessibilityID.sectionButton)

      Spacer()

      HStack(spacing: 12) {
        DDDHomeIconButton(
          image: .qrCode,
          foregroundColor: .staticWhite,
          backgroundColor: .blue70,
          borderColor: .blue30,
          action: {
            store.send(.delegate(.routeToQRCode))
          }
        )
        .dddAccessibilityID(MemberAccessibilityID.qrButton)

        DDDHomeIconButton(
          image: .managementProfile,
          foregroundColor: .staticWhite,
          backgroundColor: .gray80,
          action: {
            store.send(.delegate(.routeToProfile))
          }
        )
        .dddAccessibilityID(MemberAccessibilityID.profileButton)
      }
    }
    .frame(height: 52)
    .padding(.horizontal, 24)
  }

  private var voteWritingNavigationBar: some View {
    HStack(spacing: .zero) {
      Button {
        send(.didTapVoteBackButton)
      } label: {
        Image(asset: .backButton)
          .resizable()
          .scaledToFit()
          .frame(width: 12, height: 20)
          .foregroundStyle(Color.gray400)
      }
      .frame(width: 40, height: 44)
      .buttonStyle(.plain)

      Spacer()
    }
    .frame(height: 52)
    .padding(.horizontal, 16)
  }

  @ViewBuilder
  private func dropDownOverlay() -> some View {
    if store.isExpandedDropDown {
      ZStack(alignment: .topLeading) {
        Rectangle()
          .fill(Color.black.opacity(0.6))
          .ignoresSafeArea()
          .onTapGesture {
            closeDropDown()
          }

        HomeDropdownMenu(
          entries: MemberMainFeature.HomeTab.allCases
            .filter { tab in
              tab != .vote || store.isVoteMenuAvailable
            }
            .map { tab in
              HomeDropdownMenu.Entry(
                id: tab.rawValue,
                title: tab.title,
                isSelected: tab == store.selectedHomeTab,
                showsNewBadge: tab == .vote
              )
            },
          onSelect: { entry in
            if let tab = MemberMainFeature.HomeTab(rawValue: entry.id) {
              closeDropDown(.selectHomeTab(tab))
            }
          }
        )
        .accessibilityIdentifier { entry in
          MemberAccessibilityID.dropdownItem(entry.id)
        }
        .padding(.leading, 24)
        .padding(.top, 52)
        .accessibilityElement(children: .contain)
        .dddAccessibilityID(MemberAccessibilityID.dropdown)
      }
      .transition(.opacity)
      .zIndex(1)
    }
  }

  @ViewBuilder
  private var dropDownInteractionBlocker: some View {
    if isDropDownClosing {
      Color.clear
        .contentShape(Rectangle())
        .ignoresSafeArea()
        .zIndex(2)
    }
  }

  private var attendanceStatus: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("\(store.state.member?.name ?? "")님의 출석 현황")
        .pretendardFont(family: .Bold, size: 28)
        .foregroundStyle(.textPrimary)

      VStack(alignment: .leading, spacing: 8) {
        Text("활동 기간: \(store.startDate) - \(store.endDate)")
          .pretendardFont(family: .Regular, size: 14)
          .foregroundStyle(.textSecondary)

        switch store.attendanceViewState {
        case .loading:
          MemberAttendanceCardSkeletonView()
            .transition(.opacity)
            .dddAccessibilityID(MemberAccessibilityID.attendanceSummarySkeleton)

        case .loaded:
          AttendanceCard(
            attendanceCount: store.presentCount,
            lateCount: store.lateCount,
            absentCount: store.absentCount,
            showWarning: store.showsAttendanceWarningIcon,
            onTapAbsentButton: {
              send(.didTapAbesentButton)
            }
          )
          .transition(.opacity)
          .dddAccessibilityID(MemberAccessibilityID.attendanceSummary)
        }
      }
    }
    .padding(.top, 20)
    .animation(.easeInOut(duration: 0.2), value: store.attendanceViewState)
  }

  private var generationScheduleListView: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("\(store.member?.generation ?? "") 일정표")
        .pretendardFont(family: .Medium, size: 24)
        .foregroundStyle(.textPrimary)

      if store.schedules.isEmpty {
        emptyScheduleView
      } else {
        scheduleList
      }
    }
  }

  private var emptyScheduleView: some View {
    LazyVStack(spacing: 16) {
      Image(asset: .stamp)
        .renderingMode(.template)
        .resizable()
        .scaledToFit()
        .frame(width: 100, height: 100)

      Text("아직 일정이 없어요.")
        .dddFont(.body1NormalMedium)
        .foregroundStyle(.textSecondary)
    }
    .padding(.vertical, 64)
  }

  private var scheduleList: some View {
    LazyVStack(alignment: .leading, spacing: 12) {
      ForEach(store.schedules, id: \.id) { schedule in
        ScheduleCell(
          month: schedule.month,
          day: schedule.day,
          title: schedule.title,
          description: schedule.description,
          style: schedule.status.toScheduleCellStyle
        )
        .id(schedule.id) // SwiftUI 뷰 재사용 최적화
        .dddAccessibilityID(MemberAccessibilityID.schedule(schedule.id))
      }
    }
    .dddAccessibilityID(MemberAccessibilityID.scheduleList)
  }
}

private extension MemberMainView {
  func openDropDown() {
    guard !isDropDownClosing else { return }
    withAnimation(.appQuick) {
      send(.toggleDropDown)
    }
  }

  func closeDropDown(_ action: MemberMainFeature.View = .closeDropDown) {
    guard store.isExpandedDropDown, !isDropDownClosing else { return }
    isDropDownClosing = true

    withAnimation(.appQuick) {
      send(action)
    } completion: {
      isDropDownClosing = false
    }
  }
}

private extension ScheduleModel.AttendanceStatus {
  var toScheduleCellStyle: ScheduleCellStyle {
    switch self {
    case .attended:
      return .init(
        backgroundColor: .blue40,
        stampImage: Image(asset: .present_stamp),
        dashBorder: false,
        monthDayOpacity: 0.2,
        titleDescriptionOpacity: 0.4
      )

    case .late:
      return .init(
        backgroundColor: .statusCautionary,
        stampImage: Image(asset: .late_stamp),
        dashBorder: false,
        monthDayOpacity: 0.2,
        titleDescriptionOpacity: 0.4
      )

    case .absent:
      return .init(
        backgroundColor: .clear,
        stampImage: nil,
        dashBorder: true,
        monthDayOpacity: 0.2,
        titleDescriptionOpacity: 0.3
      )

    case .none:
      return .init(
        backgroundColor: .gray90,
        stampImage: nil,
        dashBorder: false,
        monthDayOpacity: 1.0,
        titleDescriptionOpacity: 1.0
      )
    }
  }
}
