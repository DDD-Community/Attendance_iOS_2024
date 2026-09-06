//
//  ProfileView.swift
//  DDDAttendance
//
//  Created by DDD on 7/17/24.
//

import DDDCoreUI
import DDDAccessibility
import Foundation
import SwiftUI

import ComposableArchitecture
import DDDDesignKit

@ViewAction(for: ProfileFeature.self)
public struct ProfileView: View {
  @Bindable public var store: StoreOf<ProfileFeature>

  public init(store: StoreOf<ProfileFeature>) {
    self.store = store
  }

  public var body: some View {
    ZStack {
      Color.basicBlack
        .edgesIgnoringSafeArea(.all)

      VStack {
        mangerProfileLoadingData()
      }
      .alert($store.scope(state: \.alert, action: \.scope.alert))
      .dddAlert($store.scope(state: \.customAlert, action: \.scope.customAlert))
      .onAppear {
        store.send(.async(.fetchUser))
      }

      if store.destination?.createApp != nil {
        VisualEffectBlur(blurStyle: .systemChromeMaterialDark)
          .edgesIgnoringSafeArea(.top)
          .transition(.opacity)
          .animation(.easeInOut(duration: 0.25), value: store.destination?.createApp != nil)
      }
    }

    .sheet(item: $store.scope(state: \.destination?.createApp, action: \.destination.createApp)) { crateAppStore in
      CreateAppView(store: crateAppStore)
      .presentationDetents([.height(UIScreen.screenHeight * 0.65)])
      .presentationCornerRadius(20)
      .presentationDragIndicator(.visible)
    }
  }
}

extension ProfileView {
  @ViewBuilder
  fileprivate func mangerProfileLoadingData() -> some View {
    mangerProfileLoadingContent()
      .animation(.easeInOut(duration: 0.2), value: store.viewState)
  }

  // 스켈레톤과 본문 사이를 크로스페이드하려면 두 분기를 감싸는 공통 컨테이너가 필요하다.
  @ViewBuilder
  fileprivate func mangerProfileLoadingContent() -> some View {
    if store.viewState == .loading {
      VStack {
        Spacer()
          .frame(height: 12)

        CustomNavigationBar(backAction: { store.send(.delegate(.presentBack)) }, addAction: {
          send(.appearModal)
        }, image: .info)
        .backButtonAccessibilityIdentifier(ProfileAccessibilityID.Main.backButton)
        .actionButtonAccessibilityIdentifier(ProfileAccessibilityID.Main.infoButton)

        ProfileSkeletonView()
          .dddAccessibilityID(ProfileAccessibilityID.Main.skeleton)
      }
      .dddAccessibilityID(ProfileAccessibilityID.Main.root)
    } else {
      mangerProfileData()
    }
  }

  @ViewBuilder
  fileprivate func mangerProfileData() -> some View {
    VStack {
      Spacer()
        .frame(height: 12)

      CustomNavigationBar(backAction: { store.send(.delegate(.presentBack)) }, addAction: {
        send(.appearModal)
      }, image: .info)
      .backButtonAccessibilityIdentifier(ProfileAccessibilityID.Main.backButton)
      .actionButtonAccessibilityIdentifier(ProfileAccessibilityID.Main.infoButton)

      mangerCardImage()
        .dddAccessibilityID(ProfileAccessibilityID.Main.card)

      logoutButton()

      appInfoView()

      Spacer()
    }
    .dddAccessibilityID(ProfileAccessibilityID.Main.root)
  }

  @ViewBuilder
  fileprivate func mangerCardImage() -> some View {
    LazyVStack {
      Spacer()
        .frame(height: 17)

      profileCardContent
        .padding(24)
        .background(profileCardBackground)
        .frame(height: UIScreen.screenHeight * 0.65)
    }
    .padding(.horizontal, 24)
  }

  private var profileCardContent: some View {
    VStack(alignment: .leading, spacing: .zero) {
      if store.displayedProfile?.role == .manager {
        Spacer()
          .frame(height: 24)
      }

      profileHeader
      profileName
      profileSpacingAfterName
      profileInfoContent
      profileBottomSpacer
      profileFooter

      if store.displayedProfile?.role == .manager {
        Spacer()
          .frame(height: 24)
      }
    }
  }

  private var profileHeader: some View {
    HStack {
      profileRoleBadge
      Spacer()
      generationEditButton
    }
  }

  private var profileRoleBadge: some View {
    Text(store.displayedProfile?.role == .manager ? "매니저" : "멤버")
      .dddFont(.body3NormalBold)
      .foregroundStyle(.statusFocus)
      .padding(.horizontal, 14)
      .padding(.vertical, 5)
      .overlay {
        RoundedRectangle(cornerRadius: 20)
          .stroke(.statusFocus, lineWidth: 1)
          .background(.clear)
      }
  }

  private var generationEditButton: some View {
    HStack {
      Image(asset: .edit)
        .renderingMode(.template)
        .resizable()
        .scaledToFit()
        .frame(width: 13, height: 15)

      Spacer()
        .frame(width: 7)

      Text("기수 변경")
        .dddFont(.body3NormalMedium)
        .foregroundStyle(.staticWhite)
    }
    .dddAccessibilityID(ProfileAccessibilityID.Main.generationEditButton)
    .padding(.horizontal, 18)
    .padding(.vertical, 10)
    .background {
      RoundedRectangle(cornerRadius: 20)
        .fill(.dangerBlue.opacity(0.7))
    }
    .onTapGesture {
      store.send(.delegate(.presentEditGeneration))
    }
  }

  private var profileName: some View {
    Text("\(store.displayedProfile?.name ?? "")님")
      .dddFont(.headline5Bold)
      .foregroundStyle(.borderInverse)
  }

  private var profileSpacingAfterName: some View {
    Group {
      if store.displayedProfile?.role == .manager {
        Spacer()
          .frame(height: 20)
      } else {
        Spacer()
      }
    }
  }

  private var profileInfoContent: some View {
    VStack(alignment: .leading, spacing: 20) {
      jobRoleComponent

      if store.displayedProfile?.role == .manager {
        managerSpecificComponents
      } else if store.displayedProfile?.role == .member {
        memberSpecificComponents
      }
    }
  }

  private var jobRoleComponent: some View {
    managerTextComponent(
      title: "직군",
      subTitle: store.displayedProfile?.jobRole.desc ?? "",
      managingTeam: "",
      isManaging: false,
      isGeneration: false
    )
  }

  private var managerSpecificComponents: some View {
    let team = store.displayedProfile?.team ?? .unknown

    return Group {
      managerTextComponent(
        title: "소속 팀",
        subTitle: "매니징",
        managingTeam: team.attendanceListDescription,
        isManaging: true,
        isGeneration: false
      )

      managerTextComponent(
        title: "소속 기수",
        subTitle: store.displayedProfile?.generation ?? "",
        managingTeam: "",
        isManaging: false,
        isGeneration: true
      )

      if let managerRoles = store.displayedProfile?.manger, !managerRoles.isEmpty {
        managerTextComponent(
          title: "담당 업무",
          subTitle: managerRoles.map { $0.desc }.joined(separator: " / "),
          managingTeam: "",
          isManaging: false,
          isGeneration: false
        )
      }
    }
  }

  private var memberSpecificComponents: some View {
    let team = store.displayedProfile?.team ?? .unknown

    return Group {
      managerTextComponent(
        title: "소속 팀",
        subTitle: team.attendanceListDescription,
        managingTeam: "",
        isManaging: false,
        isGeneration: false
      )

      managerTextComponent(
        title: "소속 기수",
        subTitle: store.displayedProfile?.generation ?? "",
        managingTeam: "",
        isManaging: false,
        isGeneration: true
      )
    }
  }

  private var profileBottomSpacer: some View {
    Group {
      if store.displayedProfile?.role == .manager {
        Spacer()
      } else {
        Spacer()
          .frame(height: 40)
      }
    }
  }

  private var profileFooter: some View {
    HStack {
      Spacer()
      Text("Dynamic Developer Designers")
        .dddFont(.body3NormalMedium)
        .foregroundStyle(.textSecondary100)
      Spacer()
    }
  }

  private var profileCardBackground: some View {
    Image(asset: .profileBack)
      .resizable()
      .cornerRadius(20)
      .padding(.horizontal, 10)
  }

  @ViewBuilder
  private func managerTextComponent(
    title: String,
    subTitle: String,
    managingTeam: String,
    isManaging: Bool,
    isGeneration: Bool
  ) -> some View {
    LazyVStack(spacing: .zero) {
      HStack {
        Text(title)
          .dddFont(.body2NormalMedium)
          .foregroundStyle(.textSecondary100)

        Spacer()
      }

      Spacer()
        .frame(height: 2)

      if isManaging {
        HStack {
          Text("\(subTitle) / \(managingTeam)")
            .dddFont(.title2NormalMedium)
            .foregroundStyle(.borderInverse)

          Spacer()
        }
      } else if isGeneration {
        HStack {
          Text("\(subTitle)")
            .dddFont(.title2NormalMedium)
            .foregroundStyle(.borderInverse)

          Spacer()
        }
      } else {
        HStack {
          if title == "담당 업무" {
            Text(subTitle)
              .pretendardFont(family: .Regular, size: 16)
              .foregroundStyle(.textSecondary100)

          } else {
            Text(subTitle)
              .dddFont(.title2NormalMedium)
              .foregroundStyle(.borderInverse)
          }

          Spacer()
        }
      }
    }
  }


  @ViewBuilder
  private func logoutButton() -> some View {
    VStack {
      Spacer()
        .frame(height: 36)

      HStack(alignment: .center) {

        DDDUnderlinedTextButton(
          title: "탈퇴하기",
          font: .body2NormalMedium,
          foregroundColor: .mediumGray,
          underlineColor: .mediumGray,
          action: { send(.showWithdrawAlert) }
        )
          .dddAccessibilityID(ProfileAccessibilityID.Main.withdrawButton)

      Spacer()
          .frame(width: 64)

        DDDUnderlinedTextButton(
          title: "로그아웃",
          font: .body2NormalMedium,
          foregroundColor: .staticWhite,
          underlineColor: .staticWhite,
          action: { send(.showLogoutAlert) }
        )
      }
    }
    .padding(.horizontal, 24)
  }

  @ViewBuilder
  private func appInfoView() -> some View {
    VStack {
      Spacer()
        .frame(height: 12)


      Text("Version \(appVersion)")
        .dddFont(.body3NormalRegular)
        .foregroundStyle(.mediumGray100)
        .dddAccessibilityID(ProfileAccessibilityID.Main.version)

      Spacer()
        .frame(height: 4)

      DDDUnderlinedTextButton(
        title: "개인정보처리방침 보기",
        font: .body3NormalRegular,
        foregroundColor: .mediumGray,
        underlineColor: .mediumGray,
        action: { store.send(.delegate(.presentPrivacyPolicy)) }
      )
        .dddAccessibilityID(ProfileAccessibilityID.Main.privacyPolicyButton)

      Spacer()
        .frame(height: 20)
    }
  }

  private var appVersion: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
  }
}
