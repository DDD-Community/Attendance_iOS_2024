//
//  QrCodeUseCase.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import Foundation
import SwiftUI

import ComposableArchitecture

import DiContainer

public struct QrCodeUseCase: QrCodeUseCaseProtocool {
    private let repository: QrCodeRepositoryProtcool
    
    init(
        repository: QrCodeRepositoryProtcool
    ) {
        self.repository = repository
    }
    
    public func generateQRCode(from string: String) async -> Image? {
        await repository.generateQRCode(from: string)
    }
}


extension QrCodeUseCase: DependencyKey {
    public static var liveValue: QrCodeUseCase = {
        let qrCodeRepository = DependencyContainer.live.resolve(QrCodeRepositoryProtcool.self) ?? DefaultQrCodeRepository()
        return QrCodeUseCase(repository: qrCodeRepository)
    }()
}

public extension DependencyValues {
    var qrCodeUseCase: QrCodeUseCaseProtocool {
        get { self[QrCodeUseCase.self] }
        set { self[QrCodeUseCase.self] = newValue as! QrCodeUseCase}
    }
}
