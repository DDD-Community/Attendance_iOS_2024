//
//  ScheduleCellStyle.swift
//  DDDSharedUI
//
//  Created by DDD on 4/22/25.
//

import SwiftUI

import DDDDesignKit

public struct ScheduleCellStyle {
  public let backgroundColor: Color
  public let stampImage: Image?
  public let dashBorder: Bool
  public let monthDayOpacity: Double
  public let titleDescriptionOpacity: Double

  public init(
    backgroundColor: Color,
    stampImage: Image?,
    dashBorder: Bool,
    monthDayOpacity: Double,
    titleDescriptionOpacity: Double
  ) {
    self.backgroundColor = backgroundColor
    self.stampImage = stampImage
    self.dashBorder = dashBorder
    self.monthDayOpacity = monthDayOpacity
    self.titleDescriptionOpacity = titleDescriptionOpacity
  }
}
