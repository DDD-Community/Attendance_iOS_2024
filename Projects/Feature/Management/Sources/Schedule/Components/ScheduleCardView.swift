//
//  ScheduleCardView.swift
//  Presentation
//
//  Created by DDD on 1/10/26.
//

import SwiftUI

import DDDDesignKit

public struct ScheduleCardView: View {
  private let month: String
  private let day: String
  private let title: String
  private let description: String

  public init(
    month: String,
    day: String,
    title: String,
    description: String,
  ) {
    self.month = month
    self.day = day
    self.title = title
    self.description = description
  }

  public var body: some View {
    HStack(spacing: 16) {
      // 왼쪽 날짜 박스
      VStack(spacing: 2) {
        Text("\(month)월")
          .dddFont(.body2NormalMedium)
          .foregroundStyle(.staticBlack)

        Text(day)
          .dddFont(.title3NormalBold)
          .foregroundStyle(.staticBlack)
      }
      .frame(width: 60, height: 60)
      .background(.staticWhite)
      .clipShape(RoundedRectangle(cornerRadius: 12))

      // 오른쪽 콘텐츠
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .dddFont(.body1NormalBold)
          .foregroundStyle(.staticWhite)
          .lineLimit(1)

        Text(description)
          .dddFont(.body3NormalRegular)
          .foregroundStyle(.textSecondary)
          .lineLimit(2)
      }

      Spacer()
    }
    .padding(16)
    .background(.gray80)
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

#Preview {
  VStack(spacing: 16) {
    ScheduleCardView(
      month: "12월",
      day: "99",
      title: "오리엔테이션",
      description: "커리큘럼에 대한 설명 문구 작성"
    )

    ScheduleCardView(
      month: "12월",
      day: "99",
      title: "부스팅 데이 1",
      description: "커리큘럼에 대한 설명 문구 작성"
    )

    ScheduleCardView(
      month: "12월",
      day: "99",
      title: "직군 모임1",
      description: "12기 멤버들과 처음으로 만나는 날"
    )
  }
  .padding()
  .background(.staticBlack)
  .preferredColorScheme(.dark)
}
