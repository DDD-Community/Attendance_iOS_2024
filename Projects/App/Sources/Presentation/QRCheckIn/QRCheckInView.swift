//
//  QRCheckInView.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/11/24.
//

import FlexLayout
import PinLayout
import Then

import AVFoundation
import UIKit

final class QRCheckInView: BaseView {
    // MARK: - UI properties
    private let rootView: UIView = .init()
    
    private let messageLabel: UILabel = .init()
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private let qrCodeFrameView: UIView = .init()
    
    // MARK: - Properties
    private let captureSession: AVCaptureSession = .init()
    
    // MARK: - Lifecycles
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    override func configureViews() {
        backgroundColor = .black
        addSubview(rootView)
    }
    
    
    // MARK: - Public helpers
    func startCaptureSession(_ delegate: AVCaptureMetadataOutputObjectsDelegate) {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Your device does not support video capture.")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Error creating video input: \(error)")
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            print("Could not add video input to capture session.")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("Could not add metadata output to capture session.")
            return
        }
        
        let previewLayer: AVCaptureVideoPreviewLayer = .init(session: captureSession)
        self.previewLayer = previewLayer
        previewLayer.frame = self.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func stopCaptureSession() {
        guard captureSession.isRunning else { return }
        captureSession.stopRunning()
    }
    
    // MARK: - Private helpers
    private func layout() {
        rootView.pin.all()
        rootView.flex.layout()
    }
}
