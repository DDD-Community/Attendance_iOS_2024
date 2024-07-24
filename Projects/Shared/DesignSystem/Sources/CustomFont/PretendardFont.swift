//
//  PretendardFont.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/9/24.
//

import UIKit
import SwiftUI

public struct PretendardFont: ViewModifier {
    public var family: PretendardFontFamily
    public var size: CGFloat
    
    public func body(content: Content) -> some View {
        return content.font(.custom("PretendardVariable-\(family)", fixedSize: size))
    }
}

public extension View {
    func pretendardFont(family: PretendardFontFamily, size: CGFloat) -> some View {
        return self.modifier(PretendardFont(family: family, size: size))
    }
}

public extension UIFont {
    static func pretendardFontFamily(family: PretendardFontFamily, size: CGFloat) -> UIFont {
        let fontName = "PretendardVariable-\(family)"
        return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }
}

public extension Font {
    static func pretendardFontFamily(family: PretendardFontFamily, size: CGFloat) -> Font{
        let font = Font.custom("PretendardVariable-\(family)", size: size)
        return font
    }
}


