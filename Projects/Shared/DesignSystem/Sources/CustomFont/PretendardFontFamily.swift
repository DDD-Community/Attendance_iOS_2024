//
//  PretendardFontFamily.swift
//  DesignSystem
//
//  Created by 서원지 on 7/13/24.
//

import Foundation

public enum PretendardFontFamily: CustomStringConvertible {
    case Black, Bold, ExtraBold, ExtraLight, Light, Medium, Regular, SemiBold, Thin
    
    public var description: String {
        switch self {
        case .Black:
            return "Black"
        case .Bold:
            return "Bold"
        case .ExtraBold:
            return "ExtraBold"
        case .ExtraLight:
            return "ExtraLight"
        case .Light:
            return "Light"
        case .Medium:
            return "Medium"
        case .Regular:
            return "Regular"
        case .SemiBold:
            return "SemiBold"
        case .Thin:
            return "Thin"
        }
    }
}
