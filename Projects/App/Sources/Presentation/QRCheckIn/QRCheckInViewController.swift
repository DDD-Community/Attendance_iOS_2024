//
//  QRCheckInViewController.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/11/24.
//

import ReactorKit

import AVFoundation
import UIKit

final class QRCheckInViewController: UIViewController {
    // MARK: - UI properties
    private var mainView: QRCheckInView { view as! QRCheckInView }
    
    // MARK: - Properties
    var lastDetectionTime: Date?
    
    // MARK: - Lifecycles
    override func loadView() {
        view = QRCheckInView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainView.startCaptureSession(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mainView.stopCaptureSession()
    }
    
    // MARK: - Public helpers
    
    // MARK: - Private helpers
}

extension QRCheckInViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        let currentTime: Date = .init()

        guard self.lastDetectionTime == nil || currentTime.timeIntervalSince(self.lastDetectionTime!) >= 0.3 else {
            return
        }
        self.lastDetectionTime = currentTime
        
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else {
            return
        }
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        found(code: stringValue)
    }
    
    private func found(code: String) {
        print("Found code: \(code)")
    }
}
