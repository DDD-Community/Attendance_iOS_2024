//
//  TooltipShape.swift
//  DesignSystem
//
//  Created by 서원지 on 7/14/24.
//

import SwiftUI

public struct TooltipShape: View {
    
    public init() {
        
    }
    
    public var body: some View {
        VStack {
            TriangleDownShape()
                .fill(Color.gray800)
                .padding(.leading, 30)
                .padding(.top, 40)
            
            TooltipBody(text: "사용할 수 있는 쿠폰이 있어요!")
        }
        .frame(width: 202, height: 50)
    }
}
