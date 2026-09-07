//
//  SelectTeamIteam.swift
//  DDDSharedUI
//
//  Created by DDD on 11/4/24.
//

import SwiftUI

import DDDDesignKit

public struct SelectTeamIteam: View {
  private let content: String
  private let isActive: Bool
  private let completion: () -> Void
  
  public init(
    content: String,
    isActive: Bool,
    completion: @escaping () -> Void
  ) {
    self.content = content
    self.isActive = isActive
    self.completion = completion
  }
  
  public var body: some View {
    VStack {
      RoundedRectangle(cornerRadius: 16)
        .stroke(isActive ? .statusFocus : Color.clear, style: .init(lineWidth: 2))
        .frame(height: 58)
        .background(.gray90)
        .cornerRadius(16)
        .overlay {
          HStack {
            Text(content)
              .dddFont(.body1NormalMedium)
              .foregroundStyle(isActive ? Color.textPrimary : Color.grayWhite)
            
            Spacer()
            
            Image(asset: isActive ? .activeSelectPart : .disableSelectPart)
              .resizable()
              .scaledToFit()
              .frame(width: 20, height: 20)
          }
          .padding(.horizontal, 20)
          .onTapGesture {
            completion()
          }
        }
        .onTapGesture {
          completion()
        }
    }
    .padding(.horizontal, 24)
  }
}
