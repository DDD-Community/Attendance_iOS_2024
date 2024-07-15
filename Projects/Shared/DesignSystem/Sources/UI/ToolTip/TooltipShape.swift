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
    ZStack {
        VStack {
            //      CustomTriangleShape()
            //        .fill(.green)
            //        .padding(.leading, 178)
                  
                  CustomRectangleShape(text: "Tooltip 입니다!")
            
        }
        
        CustomTriangleShape()
            .fill(Color.gray800)
            .padding(.leading, 50)
            .padding(.vertical, 30)
    }
    .frame(width: 152, height: 30)
  }
}
