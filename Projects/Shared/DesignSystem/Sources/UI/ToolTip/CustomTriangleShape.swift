//
//  CustomTriangleShape.swift
//  DesignSystem
//
//  Created by 서원지 on 7/14/24.
//

import Foundation
import SwiftUI

public struct CustomTriangleShape: Shape {
    private var width: CGFloat
    private var height: CGFloat
    private var radius: CGFloat

    public init(
        width: CGFloat = 24,
        height: CGFloat = 24,
        radius: CGFloat = 1
    ) {
        self.width = width
        self.height = height
        self.radius = radius
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + width, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + width / 2 + radius, y: rect.minY + height))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + width / 2 - radius, y: rect.minY + height),
            control: CGPoint(x: rect.minX + width / 2, y: rect.minY + height - radius)
        )

        path.closeSubpath()

        return path
    }
}
