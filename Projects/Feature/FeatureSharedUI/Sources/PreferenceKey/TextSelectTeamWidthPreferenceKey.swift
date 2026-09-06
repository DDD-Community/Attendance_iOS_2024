//
//  TextSelectTeamWidthPreferenceKey.swift
//  FeatureSharedUI
//
//  Created by DDD on 1/27/25.
//

import SwiftUI

import DDDDesignKit
import ProfileDomainInterface

public struct TextWidthPreferenceKey: PreferenceKey {
    public static var defaultValue: [SelectTeams: CGFloat] = [:]
    public static func reduce(value: inout [SelectTeams: CGFloat], nextValue: () -> [SelectTeams: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
