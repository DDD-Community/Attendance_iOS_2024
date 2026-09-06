//
//  StaffSkeletonView.swift
//  Presentation
//
//  Created by DDD on 1/11/26.
//

import SwiftUI

import DDDDesignKit

public struct StaffSkeletonView: View {
  public init() {}

  public var body: some View {
    ZStack {
      Color.basicBlack
        .ignoresSafeArea()

      ScrollView(.vertical) {
        VStack(alignment: .leading, spacing: 14) {
          headerSkeleton
          subtitleSkeleton
          largeCardSkeleton
          teamRowSkeleton
          listSkeleton
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .padding(.bottom, 28)
      }
      .scrollIndicators(.hidden)
    }
  }

  private var headerSkeleton: some View {
    HStack {
      SkeletonView(.round(cornerRadius: DDDSize.radiusLg))
        .frame(width: 56, height: 20)

      Spacer()

      SkeletonView(.circle)
        .frame(width: 28, height: 28)
    }
  }

  private var subtitleSkeleton: some View {
    // 10pt 는 반경 토큰에 없는 값이라 픽셀 유지를 위해 리터럴을 그대로 둔다.
    SkeletonView(.round(cornerRadius: 10))
      .frame(width: 180, height: 18)
  }

  private var largeCardSkeleton: some View {
    SkeletonView(.round(cornerRadius: DDDSize.radiusXl))
      .frame(height: 96)
  }

  private var teamRowSkeleton: some View {
    HStack(spacing: 12) {
      ForEach(0..<5, id: \.self) { _ in
        SkeletonView(.round(cornerRadius: DDDSize.radiusLg))
          .frame(width: 60, height: 20)
      }
    }
    .padding(.top, 2)
  }

  private var listSkeleton: some View {
    VStack(spacing: 12) {
      ForEach(0..<5, id: \.self) { _ in
        SkeletonView(.round(cornerRadius: DDDSize.radiusXl))
          .frame(height: 76)
      }
    }
  }
}

#Preview {
  StaffSkeletonView()
    .preferredColorScheme(.dark)
}
