//
//  TooltipShape.swift
//  DesignSystem
//
//  Created by 서원지 on 7/14/24.
//

import SwiftUI

public struct TooltipShape: View {
    var tooltipText: String
    
    public init(tooltipText: String) {
        self.tooltipText = tooltipText
        
    }
    
    public var body: some View {
        VStack {
            ZStack {
                TriangleDownShape()
                    .fill(Color.gray800)
                    .padding(.leading, 5)
                    .padding(.top, 40)
                
                TooltipBody(text: tooltipText)
            }
            .frame(width: 202, height: 50)
        }
    }
}
