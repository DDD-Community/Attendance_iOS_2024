//
//  SignUpPartText.swift
//  DDDSharedUI
//
//  Created by DDD on 11/3/24.
//

import SwiftUI

import DDDDesignKit

public struct SignUpPartText: View {
  private let content: String
  private let title: String
  private let subtitle: String
  
  public init(
    content: String,
    title: String,
    subtitle: String
  ) {
    self.content = content
    self.title = title
    self.subtitle = subtitle
  }
  
  public var body: some View {
    VStack(alignment: .center) {
      Spacer()
        .frame(height: 40)
      
      Text(content)
        .dddFont(.tilte1NormalBold)
        .foregroundStyle(.staticWhite)
      
      Spacer()
        .frame(height: 8)
      
      Text(title)
        .dddFont(.body3NormalMedium)
        .foregroundStyle(.staticWhite)
      
      if !subtitle.isEmpty {
        Text(subtitle)
          .dddFont(.body3NormalMedium)
          .foregroundStyle(.staticWhite)
      }
    }
  }
}
