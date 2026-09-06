//
//  OnBoardingSelectSkeletonView.swift
//  OnBoarding
//
//  Created by DDD on 9/4/26.
//

import SwiftUI

import DDDCoreUI
import DDDDesignKit

/// 온보딩 선택 화면들이 목록을 불러오는 동안 제목과 목록 자리를 대신 채운다.
/// `SignUpPartText` / `SelectPartItem` / `SelectTeamIteam` 과 높이·여백을 맞춰서
/// 로딩이 끝나도 콘텐츠가 제자리에서 그대로 바뀌게 한다.
struct OnBoardingSelectSkeletonView: View {
  enum BottomSpacing {
    case flexible
    case fixed(CGFloat)
  }

  private let content: String
  private let title: String
  private let rowCount: Int
  private let bottomSpacing: BottomSpacing

  init(
    content: String,
    title: String,
    rowCount: Int = 6,
    bottomSpacing: BottomSpacing = .flexible
  ) {
    self.content = content
    self.title = title
    self.rowCount = rowCount
    self.bottomSpacing = bottomSpacing
  }

  var body: some View {
    VStack {
      titleSkeleton

      listSkeleton

      buttonSkeleton
    }
  }
}

extension OnBoardingSelectSkeletonView {
  private var titleSkeleton: some View {
    VStack(alignment: .center) {
      Spacer()
        .frame(height: 40)

      Text(content)
        .dddFont(.tilte1NormalBold)
        .hidden()
        .overlay {
          SkeletonView(.round(cornerRadius: DDDSize.radiusSm))
        }

      Spacer()
        .frame(height: 8)

      Text(title)
        .dddFont(.body3NormalMedium)
        .hidden()
        .overlay {
          SkeletonView(.round(cornerRadius: DDDSize.radiusSm))
        }
    }
  }

  private var listSkeleton: some View {
    VStack {
      Spacer()
        .frame(height: 40)

      VStack {
        ForEach(0 ..< rowCount, id: \.self) { _ in
          HStack {
            SkeletonView(.round(cornerRadius: DDDSize.radiusSm))
              .frame(width: 120, height: 18)

            Spacer()

            SkeletonView(.circle)
              .frame(width: 20, height: 20)
          }
          .padding(.horizontal, 20)
          .frame(height: 58)
          .background(Color.gray90)
          .clipShape(.rect(cornerRadius: 16))
          .padding(.horizontal, 24)
        }

        Spacer()
      }
      .frame(height: UIScreen.screenHeight * 0.6)
    }
  }

  private var buttonSkeleton: some View {
    VStack {
      Spacer()

      SkeletonView(.round(cornerRadius: 30))
        .frame(height: 48)

      switch bottomSpacing {
      case .flexible:
        Spacer()

      case let .fixed(height):
        Spacer()
          .frame(height: height)
      }
    }
    .padding(.horizontal, 24)
  }
}

#Preview {
  ZStack {
    Color.backGroundPrimary
      .edgesIgnoringSafeArea(.all)

    OnBoardingSelectSkeletonView(
      content: "직무를 선택해 주세요",
      title: "프로젝트 참여하시는 직무을 선택해 주세요.",
      bottomSpacing: .fixed(20)
    )
  }
}
