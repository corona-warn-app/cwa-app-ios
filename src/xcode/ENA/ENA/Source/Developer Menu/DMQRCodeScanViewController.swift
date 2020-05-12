//
//  DMQRCodeScanViewController.swift
//  ENA
//
//  Created by Kienle, Christian on 05.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit
import AVFoundation
import ExposureNotification

protocol DMQRCodeScanViewControllerDelegate: class {
    func debugCodeScanViewController(
        _ viewController: DMQRCodeScanViewController,
        didScan diagnosisKey: Key
    )
}

final class DMQRCodeScanViewController: UIViewController {
    // MARK: Creating a Debug Code Scan View Controller
    init(delegate: DMQRCodeScanViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Properties
    private let scanView = DMQRCodeScanView()
    private weak var delegate: DMQRCodeScanViewControllerDelegate?

    // MARK: UIViewController
    override func loadView() {
        view = scanView
    }

    override func viewDidLoad() {
        scanView.dataHandler = { data in
            do {
                let diagnosisKey = try Key(serializedData: data)
                self.delegate?.debugCodeScanViewController(self, didScan: diagnosisKey)
                self.dismiss(animated: true, completion: nil)
            } catch let error {
                logError(message: "Failed to deserialize qr to key: \(error.localizedDescription)")
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}

fileprivate final class DMQRCodeScanView: UIView {
    // MARK: Types
    typealias DataHandler = (Data) -> Void

    // MARK: UIView
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    // MARK: Properties
    fileprivate var dataHandler: DataHandler = { _ in }
    fileprivate var captureSession: AVCaptureSession

    // MARK: Creating a code scan view
    init() {
        captureSession = AVCaptureSession()

        super.init(frame: .zero)

        // swiftlint:disable:next force_unwrapping
        let captureDevice = AVCaptureDevice.default(for: .video)! // forcing is okay - developer feature only
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }

        captureSession.addInput(captureDeviceInput)

        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        captureMetadataOutput.metadataObjectTypes = [.qr]
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: .main)

        captureSession.startRunning()

        guard let videoPreviewLayer = layer as? AVCaptureVideoPreviewLayer else { return }
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.session = captureSession
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DMQRCodeScanView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let string = metadataObject.stringValue {
            self.captureSession.stopRunning()
            // swiftlint:disable:next force_unwrapping
            let data = Data(base64Encoded: string)! // using force is okay - developer feature only
            log(message: "\(data)")
            dataHandler(data)
        } else {
            logError(message: "Nope")
        }
    }
}
