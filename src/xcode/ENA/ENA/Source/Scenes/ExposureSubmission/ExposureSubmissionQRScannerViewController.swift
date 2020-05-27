//
//  ExposureSubmissionQRScannerViewController.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 21.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol ExposureSubmissionQRScannerDelegate: class {
	func qrScanner(_ viewController: ExposureSubmissionQRScannerViewController, didScan code: String)
}


class ExposureSubmissionQRScannerNavigationController: UINavigationController {
    var exposureSubmissionService: ExposureSubmissionService?
    
	weak var scannerViewController: ExposureSubmissionQRScannerViewController? {
		return viewControllers.first as? ExposureSubmissionQRScannerViewController
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		overrideUserInterfaceStyle = .dark
	}
}


class ExposureSubmissionQRScannerViewController: UIViewController {
	@IBOutlet weak var focusView: ExposureSubmissionQRScannerFocusView!
	@IBOutlet weak var flashButton: UIButton!
	
	weak var delegate: ExposureSubmissionQRScannerDelegate?
	
	private var captureSession: AVCaptureSession?
	private var captureDevice: AVCaptureDevice?
	private var caputureDeviceInput: AVCaptureDeviceInput?
	private var metadataOutput: AVCaptureMetadataOutput?
	private var previewLayer: AVCaptureVideoPreviewLayer?

	override func viewDidLoad() {
		super.viewDidLoad()
		
		captureSession = AVCaptureSession()
		captureDevice = AVCaptureDevice.default(for: .video)
		caputureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice!)
		metadataOutput = AVCaptureMetadataOutput()
		
		captureSession?.addInput(caputureDeviceInput!)
		captureSession?.addOutput(metadataOutput!)
		
		metadataOutput?.metadataObjectTypes = [.qr]
		metadataOutput?.setMetadataObjectsDelegate(self, queue: .main)
		
		previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
		previewLayer?.frame = self.view.bounds
		previewLayer?.videoGravity = .resizeAspectFill
		
		self.view.layer.insertSublayer(previewLayer!, at: 0)
		
		captureSession?.startRunning()
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		focusView.startAnimating()
	}
	
	
	@IBAction func toggleFlash() {
		guard let device = captureDevice else { return }
		guard device.hasTorch else { return }
		
		do {
			try device.lockForConfiguration()
			
			if device.torchMode == .on {
				device.torchMode = .off
				flashButton.isSelected = false
			} else {
				do {
					try device.setTorchModeOn(level: 1.0)
					flashButton.isSelected = true
				} catch {
					print(error)
				}
			}
			
			device.unlockForConfiguration()
		} catch {
			print(error)
		}
	}
	
	
	@IBAction func close() {
		dismiss(animated: true)
	}
}


extension ExposureSubmissionQRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
	func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
		print(metadataObjects)
		if let code = metadataObjects.first(ofType: AVMetadataMachineReadableCodeObject.self ), let stringValue = code.stringValue {
			delegate?.qrScanner(self, didScan: stringValue )
		}
	}
}


@IBDesignable
class ExposureSubmissionQRScannerFocusView: UIView {
	@IBInspectable var cornerRadius: CGFloat = 0
	@IBInspectable var borderWidth: CGFloat = 1

	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		awakeFromNib()
	}
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		layer.cornerRadius = cornerRadius
		layer.borderWidth = borderWidth
		layer.borderColor = tintColor.cgColor
	}

	
	func startAnimating() {
		UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: {
			self.transform = .init(scaleX: 0.9, y: 0.9)
		})
	}
}
