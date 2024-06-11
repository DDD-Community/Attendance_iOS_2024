//
//  QrCodeRepositoryProtcool.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import Foundation
import SwiftUI

public protocol QrCodeRepositoryProtcool {
    func generateQRCode(from string: String) async -> Image?
}
