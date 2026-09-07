//
//  ScheduleHeaderView.swift
//  Presentation
//
//  Created by DDD on 1/10/26.
//

import SwiftUI

import DDDDesignKit

public struct ScheduleHeaderView: View {
  @State private var selectedPeriod: String = "일정"

  public init() {}

  public var body: some View {
    HStack {
      // 왼쪽 제목 및 드롭다운
      HStack(spacing: 4) {
        Text(selectedPeriod)
          .dddFont(.tilte1NormalBold)
          .foregroundStyle(.staticWhite)

        Image(systemName: "chevron.down")
          .renderingMode(.template) // 시스템 이미지 렌더링 최적화
          .font(.system(size: 16, weight: .medium))
          .foregroundStyle(.staticWhite)
      }

      Spacer()

      // 오른쪽 아이콘들
      HStack(spacing: 16) {
        // QR 코드 아이콘
        Button {
          // QR 코드 액션
        } label: {
          Image(systemName: "qrcode")
            .renderingMode(.template)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(.staticWhite)
            .frame(width: 44, height: 44)
            .background(.blue50)
            .clipShape(Circle())
        }

        // 프로필 아이콘
        Button {
          // 프로필 액션
        } label: {
          Image(systemName: "person.circle.fill")
            .renderingMode(.template)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(.staticWhite)
            .frame(width: 44, height: 44)
            .background(.gray80)
            .clipShape(Circle())
        }
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
  }
}

#Preview {
  ScheduleHeaderView()
    .preferredColorScheme(.dark)
}
