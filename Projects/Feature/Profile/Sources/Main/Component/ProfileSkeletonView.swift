//
//  ProfileSkeletonView.swift
//  Profile
//
//  Created by DDD on 1/5/26.
//

import SwiftUI

import DDDCoreUI
import DDDDesignKit

public struct ProfileSkeletonView: View {
  public init() {}

  public var body: some View {
    VStack {
      skeletonProfileCard()

      Spacer()
        .frame(height: 36)

      skeletonLogoutButtons()

      Spacer()
        .frame(height: 12)

      skeletonAppInfo()

      Spacer()
    }
  }
}

extension ProfileSkeletonView {
  @ViewBuilder
  private func skeletonProfileCard() -> some View {
    LazyVStack {
      Spacer()
        .frame(height: 17)

      VStack(alignment: .leading, spacing: .zero) {
        // 매니저 케이스를 가정한 상단 여백
        Spacer()
          .frame(height: 24)

        HStack {
          // 역할 태그 (매니저/멤버)
          skeletonRoleTag()

          Spacer()

          // 기수 변경 버튼
          skeletonEditButton()
        }

        Spacer()
          .frame(height: 20)

        // 사용자 이름
        skeletonText(width: 120, height: 28)

        Spacer()
          .frame(height: 20)

        // 정보 섹션 (매니저 기준 4개 항목)
        VStack(alignment: .leading, spacing: 20) {
          skeletonInfoRow(titleWidth: 40, valueWidth: 80) // 직군
          skeletonInfoRow(titleWidth: 60, valueWidth: 120) // 담당 팀
          skeletonInfoRow(titleWidth: 60, valueWidth: 80) // 소속 기수
          skeletonInfoRow(titleWidth: 60, valueWidth: 140) // 담당 업무
        }

        Spacer()

        // 하단 DDD 텍스트
        HStack {
          Spacer()

          skeletonText(width: 180, height: 16)

          Spacer()
        }

        // 매니저 케이스를 가정한 하단 여백
        Spacer()
          .frame(height: 24)
      }
      .padding(24)
      .background(
        Image(asset: .profileBack)
          .resizable()
          .scaledToFit()
          .cornerRadius(20)
          .opacity(0.3) // skeleton이므로 약간 투명하게
          .padding(.horizontal, 10)
      )
      .frame(height: UIScreen.screenHeight * 0.65)
    }
    .padding(.horizontal, 24)
  }

  @ViewBuilder
  private func skeletonInfoRow(titleWidth: CGFloat, valueWidth: CGFloat) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      skeletonText(width: titleWidth, height: 14)
      skeletonText(width: valueWidth, height: 20)
    }
  }

  @ViewBuilder
  private func skeletonRoleTag() -> some View {
    skeletonText(width: 50, height: 24)
      .overlay(
        RoundedRectangle(cornerRadius: 20)
          .stroke(.statusFocus.opacity(0.3), lineWidth: 1)
          .background(.clear)
      )
  }

  @ViewBuilder
  private func skeletonEditButton() -> some View {
    HStack(spacing: 7) {
      skeletonText(width: 13, height: 15) // edit 아이콘
      skeletonText(width: 50, height: 16) // "기수 변경" 텍스트
    }
    .padding(.horizontal, 18)
    .padding(.vertical, 10)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(.dangerBlue.opacity(0.3))
    )
  }

  @ViewBuilder
  private func skeletonLogoutButtons() -> some View {
    HStack(alignment: .center) {
      skeletonText(width: 60, height: 16) // "탈퇴하기"

      Spacer()
        .frame(width: 64)

      skeletonText(width: 60, height: 16) // "로그아웃"
    }
    .padding(.horizontal, 24)
  }

  @ViewBuilder
  private func skeletonAppInfo() -> some View {
    VStack(spacing: 4) {
      skeletonText(width: 80, height: 14)
      skeletonText(width: 120, height: 14)
    }
  }

  @ViewBuilder
  private func skeletonText(width: CGFloat, height: CGFloat) -> some View {
    SkeletonView(.round(cornerRadius: DDDSize.radiusXs))
      .frame(width: width, height: height)
  }

  @ViewBuilder
  private func skeletonRoundedButton(width: CGFloat, height: CGFloat) -> some View {
    SkeletonView(.round(cornerRadius: DDDSize.radius2xl))
      .frame(width: width, height: height)
  }
}

#Preview {
  ProfileSkeletonView()
    .background(Color.basicBlack)
}
