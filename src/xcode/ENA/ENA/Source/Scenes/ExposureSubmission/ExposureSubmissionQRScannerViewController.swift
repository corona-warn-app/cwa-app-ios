// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import AVFoundation
import Foundation
import UIKit

enum QRScannerError: Error {
	case cameraPermissionDenied
	case other
}

protocol ExposureSubmissionQRScannerDelegate: AnyObject {
	func qrScanner(_ viewController: ExposureSubmissionQRScannerViewController, didScan code: String)
	func qrScanner(_ viewController: ExposureSubmissionQRScannerViewController, error: QRScannerError)
}

final class ExposureSubmissionQRScannerNavigationController: UINavigationController {
	var exposureSubmissionService: ExposureSubmissionService?

	weak var scannerViewController: ExposureSubmissionQRScannerViewController? {
		viewControllers.first as? ExposureSubmissionQRScannerViewController
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		overrideUserInterfaceStyle = .dark
	}
}

final class ExposureSubmissionQRScannerViewController: UIViewController {
	@IBOutlet var focusView: ExposureSubmissionQRScannerFocusView!
	@IBOutlet var flashButton: UIButton!

	weak var delegate: ExposureSubmissionQRScannerDelegate?

	private var captureDevice: AVCaptureDevice?
	private var previewLayer: AVCaptureVideoPreviewLayer?

	override func viewDidLoad() {
		super.viewDidLoad()
		prepareScanning()
	}

	private func prepareScanning() {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
		case .authorized:
			startScanning()
		case .notDetermined:
			AVCaptureDevice.requestAccess(for: .video) { isAllowed in
				guard isAllowed else {
					self.delegate?.qrScanner(self, error: .cameraPermissionDenied)
					return
				}

				self.startScanning()
			}
		default:
			delegate?.qrScanner(self, error: .cameraPermissionDenied)
		}
	}

	// Make sure to get permission to use the camera before using this method.
	private func startScanning() {
		let captureSession = AVCaptureSession()

		captureDevice = AVCaptureDevice.default(for: .video)
		guard let captureDevice = captureDevice else {
			delegate?.qrScanner(self, error: .other)
			return
		}

		guard let caputureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
			delegate?.qrScanner(self, error: .other)
			return
		}

		let metadataOutput = AVCaptureMetadataOutput()

		captureSession.addInput(caputureDeviceInput)
		captureSession.addOutput(metadataOutput)

		metadataOutput.metadataObjectTypes = [.qr]
		metadataOutput.setMetadataObjectsDelegate(self, queue: .main)

		previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		guard let previewLayer = previewLayer else { return }

		DispatchQueue.main.async {
			self.previewLayer?.frame = self.view.bounds
			self.previewLayer?.videoGravity = .resizeAspectFill
			self.view.layer.insertSublayer(previewLayer, at: 0)
		}

		captureSession.startRunning()
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
					log(message: error.localizedDescription, level: .error)
				}
			}

			device.unlockForConfiguration()
		} catch {
			log(message: error.localizedDescription, level: .error)
		}
	}

	@IBAction func close() {
		dismiss(animated: true)
	}
}

extension ExposureSubmissionQRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
	func metadataOutput(
		_: AVCaptureMetadataOutput,
		didOutput metadataObjects: [AVMetadataObject],
		from _: AVCaptureConnection
	) {
		if
			let code = metadataObjects.first(ofType: AVMetadataMachineReadableCodeObject.self),
			let stringValue = code.stringValue {
			delegate?.qrScanner(self, didScan: stringValue)
		}
	}
}

@IBDesignable
final class ExposureSubmissionQRScannerFocusView: UIView {
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
		UIView.animate(
			withDuration: 0.5,
			delay: 0,
			options: [.repeat, .autoreverse],
			animations: {
				self.transform = .init(scaleX: 0.9, y: 0.9)
			}
		)
	}
}

private extension Array {
	public func first<T>(ofType _: T.Type) -> T? {
		first(where: { $0 is T }) as? T
	}
}
