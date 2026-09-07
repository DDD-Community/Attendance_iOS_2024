//
//  ScheduleCell.swift
//  DDDSharedUI
//
//  Created by DDD on 4/22/25.
//

import SwiftUI

import DDDDesignKit

public struct ScheduleCell: View {
  private let month: Int
  private let day: Int
  private let title: String
  private let description: String
  private let style: ScheduleCellStyle

  public init(
    month: Int,
    day: Int,
    title: String,
    description: String,
    style: ScheduleCellStyle
  ) {
    self.month = month
    self.day = day
    self.title = title
    self.description = description
    self.style = style
  }

  public var body: some View {
    HStack(alignment: .center, spacing: .zero) {
      VStack(alignment: .center, spacing: 4) {
        Text("\(month)월")
          .pretendardFont(family: .Medium, size: 14)
          .foregroundStyle(.staticBlack)

        Text("\(day)")
          .pretendardFont(family: .Medium, size: 20)
          .foregroundStyle(.staticBlack)
      }
      .frame(width: 54, height: 54)
      .background(.blue20)
      .opacity(style.monthDayOpacity)
      .clipShape(.rect(cornerRadius: 12))

      VStack(alignment: .leading, spacing: .zero) {
        Text(title)
          .pretendardFont(family: .Bold, size: 18)
          .foregroundStyle(.backgroundInverse)

        Text(description)
          .pretendardFont(family: .Regular, size: 14)
          .foregroundStyle(.textSecondary)
      }
      .padding(.leading, 12)
      .opacity(style.titleDescriptionOpacity)

      Spacer()
    }
    .overlay {
      if let stampImage = style.stampImage {
        GeometryReader { proxy in
          let xPosition = proxy.size.width * 0.82205128
          let yPosition = proxy.size.height * 0.92953488

          stampImage
            .resizable()
            .scaledToFit()
            .rotationEffect(.degrees(-15))
            .position(x: xPosition, y: yPosition)
            .frame(width: 120, height: 120)
            .opacity(0.8)
        }
      }
    }
    .padding(16)
    .background(style.backgroundColor)
    .clipShape(.rect(cornerRadius: 16))
    .overlay {
      if style.dashBorder {
        RoundedRectangle(cornerRadius: 16)
          .stroke(.gray60, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
      }
    }
  }
}
