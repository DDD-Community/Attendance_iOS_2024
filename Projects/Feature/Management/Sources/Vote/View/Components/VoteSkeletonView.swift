//
//  VoteSkeletonView.swift
//  Management
//
//  Created by DDD on 6/11/26.
//

import SwiftUI

import DDDDesignKit

public struct VoteSkeletonView: View {
  public init() {}

  public var body: some View {
    ZStack {
      Color.basicBlack

      VStack(alignment: .leading, spacing: 20) {
        headerSkeleton
        cardSkeleton
        buttonSkeleton
        Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .padding(.top, 20)
      .padding(.horizontal, 24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var headerSkeleton: some View {
    VStack(alignment: .leading, spacing: 8) {
      SkeletonView(.round(cornerRadius: DDDSize.radiusMd))
        .frame(width: 120, height: 28)

      SkeletonView(.round(cornerRadius: DDDSize.radiusSm))
        .frame(width: 240, height: 16)
    }
  }

  private var cardSkeleton: some View {
    VStack(spacing: 0) {
      row
      DDDDivider(color: .gray80)
      row
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 4)
    .frame(maxWidth: .infinity)
    .background {
      RoundedRectangle(cornerRadius: DDDSize.radiusLg).fill(Color.gray90)
    }
  }

  private var row: some View {
    HStack {
      SkeletonView(.round(cornerRadius: DDDSize.radiusSm))
        .frame(width: 55, height: 16)

      Spacer()

      SkeletonView(.round(cornerRadius: DDDSize.radiusSm))
        .frame(width: 120, height: 18)
    }
    .padding(.vertical, 14)
  }

  private var buttonSkeleton: some View {
    // 10pt 는 반경 토큰에 없는 값이라 픽셀 유지를 위해 리터럴을 그대로 둔다.
    SkeletonView(.round(cornerRadius: 10))
      .frame(height: 52)
      .frame(maxWidth: .infinity)
  }
}

#Preview {
  VoteSkeletonView()
    .preferredColorScheme(.dark)
}
