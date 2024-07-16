//
//  CustomTriangleShape.swift
//  DesignSystem
//
//  Created by 서원지 on 7/14/24.
//

import Foundation
import SwiftUI

public struct TriangleDownShape: Shape {
    private var width: CGFloat
    private var height: CGFloat
    private var radius: CGFloat
    
    public init(width: CGFloat = 22, height: CGFloat = 20, radius: CGFloat = 1) {
        self.width = width
        self.height = height
        self.radius = radius
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX + width / 2, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX - width / 2, y: rect.minY))
        path.closeSubpath()
        
        return path
    }
}
