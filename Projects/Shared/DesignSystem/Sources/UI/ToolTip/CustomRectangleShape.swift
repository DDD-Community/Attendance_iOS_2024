//
//  CustomRectangleShape.swift
//  DesignSystem
//
//  Created by 서원지 on 7/14/24.
//

import SwiftUI

struct TooltipBody: View {
    private var text: String
    
    public init(text: String) {
        self.text = text
    }
    
    var body: some View {
            VStack {
                Text(text)
                    .pretendardFont(family: .Regular, size: 14)
                    .foregroundStyle(Color.basicWhite)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray800)
                    )
            }
    }
}
