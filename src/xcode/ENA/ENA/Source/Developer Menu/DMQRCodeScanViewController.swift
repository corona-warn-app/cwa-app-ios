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

#if !RELEASE

import AVFoundation
import ExposureNotification
import UIKit

protocol DMQRCodeScanViewControllerDelegate: AnyObject {
	func debugCodeScanViewController(
		_ viewController: DMQRCodeScanViewController,
		didScan diagnosisKey: SAP_TemporaryExposureKey
	)
}

final class DMQRCodeScanViewController: UIViewController {
	// MARK: Creating a Debug Code Scan View Controller

	init(delegate: DMQRCodeScanViewControllerDelegate) {
		self.delegate = delegate
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
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
				let diagnosisKey = try SAP_TemporaryExposureKey(serializedData: data)
				self.delegate?.debugCodeScanViewController(self, didScan: diagnosisKey)
				self.dismiss(animated: true, completion: nil)
			} catch {
				logError(message: "Failed to deserialize qr to key: \(error.localizedDescription)")
			}
		}
	}

	override var prefersStatusBarHidden: Bool {
		true
	}
}

private final class DMQRCodeScanView: UIView {
	// MARK: Types

	typealias DataHandler = (Data) -> Void

	// MARK: UIView

	override class var layerClass: AnyClass {
		AVCaptureVideoPreviewLayer.self
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

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension DMQRCodeScanView: AVCaptureMetadataOutputObjectsDelegate {
	func metadataOutput(_: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from _: AVCaptureConnection) {
		if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let string = metadataObject.stringValue {
			captureSession.stopRunning()
			// swiftlint:disable:next force_unwrapping
			let data = Data(base64Encoded: string.trimmingCharacters(in: .whitespacesAndNewlines))! // using force is okay - developer feature only
			log(message: "\(data)")
			dataHandler(data)
		} else {
			logError(message: "Nope")
		}
	}
}

#endif
