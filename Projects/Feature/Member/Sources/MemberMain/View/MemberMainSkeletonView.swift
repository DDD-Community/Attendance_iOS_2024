//
//  MemberMainSkeletonView.swift
//  Member
//
//  Created by DDD on 9/4/26.
//

import SwiftUI

import DDDDesignKit

public struct MemberMainSkeletonView: View {
  public init() {}

  public var body: some View {
    VStack(alignment: .leading, spacing: .zero) {
      navigationSkeleton

      ScrollView {
        VStack(alignment: .leading, spacing: 56) {
          attendanceSkeleton
          scheduleSkeleton
        }
        .padding(.horizontal, 24)
      }
      .scrollIndicators(.hidden)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(.backGroundPrimary)
  }

  private var navigationSkeleton: some View {
    HStack(spacing: .zero) {
      HStack(spacing: 6) {
        SkeletonView(.round(cornerRadius: DDDSize.radiusSm))
          .frame(width: 48, height: 28)

        SkeletonView(.round(cornerRadius: DDDSize.radiusXs))
          .frame(width: 12, height: 8)
      }

      Spacer()

      HStack(spacing: 12) {
        SkeletonView(.circle)
          .frame(width: 36, height: 36)

        SkeletonView(.circle)
          .frame(width: 36, height: 36)
      }
    }
    .frame(height: 52)
    .padding(.horizontal, 24)
  }

  private var attendanceSkeleton: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("OOO님의 출석 현황")
        .pretendardFont(family: .Bold, size: 28)
        .hidden()
        .overlay {
          SkeletonView(.round(cornerRadius: DDDSize.radiusSm))
        }

      VStack(alignment: .leading, spacing: 8) {
        Text("활동 기간: 2026.9.2 - 2026.11.30")
          .pretendardFont(family: .Regular, size: 14)
          .hidden()
          .overlay {
            SkeletonView(.round(cornerRadius: DDDSize.radiusXs))
          }

        MemberAttendanceCardSkeletonView()
      }
    }
    .padding(.top, 20)
  }

  private var scheduleSkeleton: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("13기 일정표")
        .pretendardFont(family: .Medium, size: 24)
        .hidden()
        .overlay {
          SkeletonView(.round(cornerRadius: DDDSize.radiusSm))
        }

      LazyVStack(alignment: .leading, spacing: 12) {
        ForEach(0 ..< 6, id: \.self) { _ in
          scheduleCellSkeleton
        }
      }
    }
  }

  private var scheduleCellSkeleton: some View {
    HStack(alignment: .center, spacing: .zero) {
      SkeletonView(.round(cornerRadius: 12))
        .frame(width: 54, height: 54)

      VStack(alignment: .leading, spacing: .zero) {
        SkeletonView(.round(cornerRadius: DDDSize.radiusSm))
          .frame(width: 112, height: 22)

        SkeletonView(.round(cornerRadius: DDDSize.radiusXs))
          .frame(width: 160, height: 17)
      }
      .padding(.leading, 12)

      Spacer()
    }
    .padding(16)
    .background(.gray90)
    .clipShape(.rect(cornerRadius: 16))
  }
}

struct MemberAttendanceCardSkeletonView: View {
  var body: some View {
    HStack(spacing: .zero) {
      attendanceItemSkeleton

      Spacer()
      attendanceDivider
      Spacer()

      attendanceItemSkeleton

      Spacer()
      attendanceDivider
      Spacer()

      attendanceItemSkeleton
    }
    .padding(24)
    .background(.borderInverse)
    .clipShape(.rect(cornerRadius: 20))
  }

  private var attendanceItemSkeleton: some View {
    VStack(spacing: 4) {
      SkeletonView(.round(cornerRadius: DDDSize.radiusSm))
        .frame(width: 28, height: 32)

      SkeletonView(.round(cornerRadius: DDDSize.radiusXs))
        .frame(width: 32, height: 19)
    }
    .frame(width: 68, height: 64)
  }

  private var attendanceDivider: some View {
    DDDDivider(
      color: .borderDisabled,
      orientation: .vertical(height: 48)
    )
  }
}

#Preview {
  MemberMainSkeletonView()
}
