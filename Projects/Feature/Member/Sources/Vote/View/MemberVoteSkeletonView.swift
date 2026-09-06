//
//  MemberVoteSkeletonView.swift
//  Member
//
//  Created by DDD on 9/4/26.
//

import SwiftUI

import DDDAccessibility
import DDDDesignKit

/// 멤버 투표의 초기 로딩 화면. 첫 단계인 팀 선택 화면과 같은 구조를 유지한다.
struct MemberVoteSkeletonView: View {
  var body: some View {
    VStack(spacing: .zero) {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          progressSkeleton
          headerSkeleton
          categorySkeleton
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 24)
      }
      .scrollIndicators(.hidden)

      SkeletonView(.round(cornerRadius: 14))
        .frame(maxWidth: .infinity)
        .frame(height: 55)
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 24)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.backGroundPrimary)
    .dddAccessibilityID(MemberAccessibilityID.Vote.skeleton)
  }

  private var progressSkeleton: some View {
    VStack(alignment: .leading, spacing: 8) {
      SkeletonView(.round(cornerRadius: DDDSize.radiusXs))
        .frame(width: 72, height: 17)

      SkeletonView(.round(cornerRadius: 3))
        .frame(maxWidth: .infinity)
        .frame(height: 6)
    }
  }

  private var headerSkeleton: some View {
    VStack(alignment: .leading, spacing: 8) {
      SkeletonView(.round(cornerRadius: DDDSize.radiusSm))
        .frame(width: 260, height: 34)

      SkeletonView(.round(cornerRadius: DDDSize.radiusXs))
        .frame(maxWidth: .infinity)
        .frame(height: 20)

      SkeletonView(.round(cornerRadius: DDDSize.radiusXs))
        .frame(width: 216, height: 17)
    }
  }

  private var categorySkeleton: some View {
    VStack(alignment: .leading, spacing: 16) {
      questionHeaderSkeleton
      teamListSkeleton
      reasonEditorSkeleton
    }
  }

  private var questionHeaderSkeleton: some View {
    VStack(alignment: .leading, spacing: 8) {
      SkeletonView(.round(cornerRadius: DDDSize.radiusSm))
        .frame(width: 208, height: 24)

      HStack {
        SkeletonView(.round(cornerRadius: DDDSize.radiusXs))
          .frame(width: 128, height: 17)

        Spacer()

        SkeletonView(.round(cornerRadius: DDDSize.radiusXs))
          .frame(width: 32, height: 17)
      }
    }
  }

  private var teamListSkeleton: some View {
    VStack(spacing: .zero) {
      ForEach(0 ..< 4, id: \.self) { index in
        teamRowSkeleton

        if index < 3 {
          DDDDivider(color: .gray90)
        }
      }
    }
  }

  private var teamRowSkeleton: some View {
    HStack(spacing: 12) {
      VStack(alignment: .leading, spacing: 2) {
        SkeletonView(.round(cornerRadius: DDDSize.radiusSm))
          .frame(width: 72, height: 19)

        SkeletonView(.round(cornerRadius: DDDSize.radiusXs))
          .frame(width: 104, height: 16)
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      SkeletonView(.round(cornerRadius: 6))
        .frame(width: 22, height: 22)
    }
    .padding(.vertical, 16)
  }

  private var reasonEditorSkeleton: some View {
    VStack(alignment: .leading, spacing: 12) {
      SkeletonView(.round(cornerRadius: DDDSize.radiusSm))
        .frame(width: 144, height: 19)

      SkeletonView(.round(cornerRadius: 12))
        .frame(maxWidth: .infinity)
        .frame(height: 150)

      SkeletonView(.round(cornerRadius: DDDSize.radiusXs))
        .frame(width: 44, height: 16)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.top, 6)
    }
  }
}

#Preview {
  MemberVoteSkeletonView()
}
