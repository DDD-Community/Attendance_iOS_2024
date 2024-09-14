//
//  QRCheckInViewController.swift
//  DDDAttendance
//
//  Created by 고병학 on 6/11/24.
//

import ReactorKit

import AVFoundation
import UIKit

protocol QRCheckInViewControllerDelegate: AnyObject {
    func qrCheckInViewDismissed()
}

final class QRCheckInViewController: UIViewController {
    typealias Reactor = QRCheckInReactor
    
    // MARK: - UI properties
    private var mainView: QRCheckInView { view as! QRCheckInView }
    
    // MARK: - Properties
    weak var delegate: QRCheckInViewControllerDelegate?
    private var lastDetectionTime: Date?
    private var profile: Member
    var disposeBag: DisposeBag = .init()
    
    // MARK: - Lifecycles
    init(profile: Member) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = QRCheckInView()
        reactor = QRCheckInReactor(self.profile)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainView.startCaptureSession(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mainView.stopCaptureSession()
        delegate?.qrCheckInViewDismissed()
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
        found(code: stringValue)
    }
    
    private func found(code: String) {
        guard let isLoading: Bool = reactor?.currentState.isLoading,
              !isLoading else {
            return
        }
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        reactor?.action.onNext(.checkQR(code))
    }
    
    private func showCheckInSuccessAlert() {
        let alert: UIAlertController = .init(
            title: "출석 성공",
            message: "출석이 완료되었습니다.",
            preferredStyle: .alert
        )
        let action: UIAlertAction = .init(title: "확인", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func showCheckInFailAlert() {
        let alert: UIAlertController = .init(
            title: "출석 실패",
            message: "출석에 실패하였습니다.",
            preferredStyle: .alert
        )
        let action: UIAlertAction = .init(title: "확인", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension QRCheckInViewController: ReactorKit.View {
    func bind(reactor: QRCheckInReactor) {
        reactor.state.map { $0.isCheckInSuccess }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .compactMap { $0 }
            .bind { [weak self] isSuccess in
                self?.mainView.stopCaptureSession()
                if isSuccess {
                    self?.showCheckInSuccessAlert()
                } else {
                    self?.showCheckInFailAlert()
                }
            }.disposed(by: disposeBag)
    }
}
