//
//  CustomRectangleShape.swift
//  DesignSystem
//
//  Created by 서원지 on 7/14/24.
//

import SwiftUI

public struct CustomRectangleShape: View {
  private var text: String
  
    public init(text: String) {
    self.text = text
  }
  
    public var body: some View {
    VStack {
      Spacer()
      
      Text(text)
            .pretendardFont(family: .SemiBold, size: 16)
        .foregroundColor(.white)
        .background(
          RoundedRectangle(cornerRadius:20)
            .fill(Color.gray800)
            .frame(width: 152, height: 30)
        )
    }
  }
}
