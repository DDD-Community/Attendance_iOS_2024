//
//  QrCodeRepository.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

@Observable public class QrCodeRepository: QrCodeRepositoryProtcool {

    public init() {
        
    }
    
    //MARK: -  qrcode생성
    public func generateQRCode(from string: String) async -> Image? {
        await withCheckedContinuation { continuation in
            let context = CIContext()
            let filter = CIFilter.qrCodeGenerator()
            let data = Data(string.utf8)
            
            filter.setValue(data, forKey: "inputMessage")

            if let outputImage = filter.outputImage {
                if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                    let swiftUIImage = Image(decorative: cgimg, scale: 1.0)
                    continuation.resume(returning: swiftUIImage)
                    return
                }
            }

            continuation.resume(returning: nil)
        }
    }
    
}
