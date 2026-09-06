//
//  AttendanceStatus+Color.swift
//  FeatureSharedUI
//
//  Created by DDD on 11/4/24.
//

import SwiftUI

import AttendanceDomainInterface
import DDDDesignKit


public extension AttendanceStatus {
    func backgroundColor(
        isBackground: Bool = false,
        isNameColor: Bool = false,
        isGenerationColor: Bool = false,
        isRoletTypeColor: Bool = false
    ) -> Color {
        switch self {
        case .attended:
            switch (isBackground, isNameColor, isGenerationColor, isRoletTypeColor) {
            case (true, _, _, _):
                return .staticWhite
            case (_, true, _, _):
                return .basicBlack
            case (_, _, true, _):
                return .gray600
            case (_, _, _, true):
                return .basicBlack
            default:
                return .gray800
            }

        case .late, .absent, .defaults:
            switch (isBackground, isNameColor, isGenerationColor, isRoletTypeColor) {
            case (true, _, _, _):
                return .gray800
            case (_, true, _, _):
                return .gray600
            case (_, _, true, _):
                return .gray600
            case (_, _, _, true):
                return .gray600
            default:
                return .gray800
            }
        }
    }
}
