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

final class ExposureSubmissionQRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

	// MARK: - Init

	init(
		onSuccess: @escaping (DeviceRegistrationKey) -> Void,
		onError: @escaping (QRScannerError) -> Void,
		onCancel: @escaping () -> Void
	) {
		self.onSuccess = onSuccess
		self.onError = onError
		self.onCancel = onCancel

		super.init(nibName: "ExposureSubmissionQRScannerViewController", bundle: .main)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupView()
		updateToggleFlashAccessibility()
		prepareScanning()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		setNeedsPreviewMaskUpdate()
		updatePreviewMaskIfNeeded()
	}

	// MARK: - Protocol AVCaptureMetadataOutputObjectsDelegate

	func metadataOutput(
		_: AVCaptureMetadataOutput,
		didOutput metadataObjects: [AVMetadataObject],
		from _: AVCaptureConnection
	) {
		if let code = metadataObjects.first(where: { $0 is AVMetadataMachineReadableCodeObject }) as? AVMetadataMachineReadableCodeObject, let stringValue = code.stringValue {
			guard let extractedGuid = viewModel.extractGuid(from: stringValue) else {
				onError(.codeNotFound)
				return
			}

			onSuccess(.guid(extractedGuid))
		}
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let onSuccess: (DeviceRegistrationKey) -> Void
	private let onError: (QRScannerError) -> Void
	private let onCancel: () -> Void

	private let viewModel = ExposureSubmissionQRScannerViewModel()

	@IBOutlet private var focusView: ExposureSubmissionQRScannerFocusView!
	@IBOutlet private var instructionLabel: DynamicTypeLabel!

	private let flashButton = UIButton(type: .custom)

	private var captureDevice: AVCaptureDevice?
	private var previewLayer: AVCaptureVideoPreviewLayer? { didSet { setNeedsPreviewMaskUpdate() } }

	private var needsPreviewMaskUpdate: Bool = true

	private func setupView() {
		navigationItem.title = AppStrings.ExposureSubmissionQRScanner.title
		instructionLabel.text = AppStrings.ExposureSubmissionQRScanner.instruction

		instructionLabel.layer.shadowColor = UIColor.enaColor(for: .textPrimary1Contrast).cgColor
		instructionLabel.layer.shadowOpacity = 1
		instructionLabel.layer.shadowRadius = 3
		instructionLabel.layer.shadowOffset = .init(width: 0, height: 0)

		navigationController?.overrideUserInterfaceStyle = .dark

		navigationController?.navigationBar.tintColor = .enaColor(for: .textContrast)
		navigationController?.navigationBar.shadowImage = UIImage()
		if let image = UIImage.with(color: UIColor(white: 0, alpha: 0.5)) {
			navigationController?.navigationBar.setBackgroundImage(image, for: .default)
		}

		flashButton.addTarget(self, action: #selector(didToggleFlash), for: .touchUpInside)
		flashButton.setImage(UIImage(systemName: "bolt"), for: .normal)
		flashButton.setImage(UIImage(systemName: "bolt.fill"), for: .selected)

		let flashBarButtonItem = UIBarButtonItem(customView: flashButton)
		navigationItem.rightBarButtonItem = flashBarButtonItem

		let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
		navigationItem.leftBarButtonItem = cancelBarButtonItem
	}

	private func updateToggleFlashAccessibility() {
		flashButton.accessibilityLabel = AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityLabel
		flashButton.accessibilityCustomActions?.removeAll()
		flashButton.accessibilityTraits = [.button]

		if flashButton.isSelected {
			flashButton.accessibilityValue = AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityOnValue
			flashButton.accessibilityCustomActions = [UIAccessibilityCustomAction(name: AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityDisableAction, target: self, selector: #selector(didToggleFlash))]
		} else {
			flashButton.accessibilityValue = AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityOffValue
			flashButton.accessibilityCustomActions = [UIAccessibilityCustomAction(name: AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityEnableAction, target: self, selector: #selector(didToggleFlash))]
		}
	}

	private func prepareScanning() {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
		case .authorized:
			startScanning()
		case .notDetermined:
			AVCaptureDevice.requestAccess(for: .video) { isAllowed in
				guard isAllowed else {
					self.onError(.cameraPermissionDenied)
					return
				}

				self.startScanning()
			}
		default:
			onError(.cameraPermissionDenied)
		}
	}

	// Make sure to get permission to use the camera before using this method.
	private func startScanning() {
		let captureSession = AVCaptureSession()

		captureDevice = AVCaptureDevice.default(for: .video)
		guard let captureDevice = captureDevice else {
			onError(.other)
			return
		}

		guard let caputureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
			onError(.other)
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

	@objc
	private func didToggleFlash() {
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

			updateToggleFlashAccessibility()
		} catch {
			log(message: error.localizedDescription, level: .error)
		}
	}

	@objc
	private func didTapCancel() {
		onCancel()
	}

	private func setNeedsPreviewMaskUpdate() {
		guard needsPreviewMaskUpdate else { return }
		needsPreviewMaskUpdate = true

		DispatchQueue.main.async(execute: updatePreviewMaskIfNeeded)
	}

	private func updatePreviewMaskIfNeeded() {
		guard needsPreviewMaskUpdate else { return }
		needsPreviewMaskUpdate = false

		guard let previewLayer = previewLayer else { return }
		guard focusView.backdropOpacity > 0 else {
			previewLayer.mask = nil
			return
		}
		let backdropColor = UIColor(white: 0, alpha: 1 - max(0, min(focusView.backdropOpacity, 1)))

		let focusPath = UIBezierPath(roundedRect: focusView.frame, cornerRadius: focusView.layer.cornerRadius)

		let backdropPath = UIBezierPath(cgPath: focusPath.cgPath)
		backdropPath.append(UIBezierPath(rect: view.bounds))

		let backdropLayer = CAShapeLayer()
		backdropLayer.path = UIBezierPath(rect: view.bounds).cgPath
		backdropLayer.fillColor = backdropColor.cgColor

		let backdropLayerMask = CAShapeLayer()
		backdropLayerMask.fillRule = .evenOdd
		backdropLayerMask.path = backdropPath.cgPath
		backdropLayer.mask = backdropLayerMask

		let throughHoleLayer = CAShapeLayer()
		throughHoleLayer.path = UIBezierPath(cgPath: focusPath.cgPath).cgPath

		previewLayer.mask = CALayer()
		previewLayer.mask?.addSublayer(throughHoleLayer)
		previewLayer.mask?.addSublayer(backdropLayer)
	}

}
