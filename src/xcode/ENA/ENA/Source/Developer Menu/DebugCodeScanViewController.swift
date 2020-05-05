//
//  DebugCodeScanViewController.swift
//  ENA
//
//  Created by Kienle, Christian on 05.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit
import AVFoundation
import ExposureNotification

protocol DebugCodeScanViewControllerDelegate: class {
    func debugCodeScanViewController(
        _ viewController: DebugCodeScanViewController,
        didScan diagnosisKey: CodableDiagnosisKey
    )
}

final class DebugCodeScanViewController: UIViewController {
    // MARK: Creating a Debug Code Scan View Controller
    init(delegate: DebugCodeScanViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Properties
    private let scanView = DebugCodeScanView()
    private weak var delegate: DebugCodeScanViewControllerDelegate?

    // MARK: UIViewController
    override func loadView() {
        view = scanView
    }

    override func viewDidLoad() {
        scanView.dataHandler = { data in
            if let diagnosisKey = try? JSONDecoder().decode(CodableDiagnosisKey.self, from: data) {
                if !Server.shared.diagnosisKeys.contains(diagnosisKey) {
                    Server.shared.diagnosisKeys.append(diagnosisKey)
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    @IBAction func tap() {
        dismiss(animated: true, completion: nil)
    }
}

final fileprivate class DebugCodeScanView: UIView {
    typealias DataHandler = (Data) -> Void

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    fileprivate var dataHandler: DataHandler = { _ in }

    init() {

        super.init(frame: .zero)
        let captureSession = AVCaptureSession()

        let captureDevice = AVCaptureDevice.default(for: .video)!
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return  }

        captureSession.addInput(captureDeviceInput)

        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        captureMetadataOutput.metadataObjectTypes = [.qr]
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: .main)

        captureSession.startRunning()

        guard let videoPreviewLayer = layer as? AVCaptureVideoPreviewLayer else { return  }
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.session = captureSession
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension DebugCodeScanView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let string = metadataObject.stringValue, let data = string.data(using: .utf8) {
            dataHandler(data)
        }
    }
}
