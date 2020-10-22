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

final class ExposureSubmissionQRScannerViewController: UIViewController {

	// MARK: - Init

	init(
		onSuccess: @escaping (DeviceRegistrationKey) -> Void,
		onError: @escaping (QRScannerError, _ reactivateScanning: @escaping () -> Void) -> Void,
		onCancel: @escaping () -> Void
	) {
		viewModel = ExposureSubmissionQRScannerViewModel(
			onSuccess: onSuccess,
			onError: onError
		)
		self.onCancelScannerView = onCancel
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
		viewModel.startCaptureSession()
		setupNavigationBar()
		updateToggleFlashAccessibility()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		setNeedsPreviewMaskUpdate()
		updatePreviewMaskIfNeeded()
	}
	
	// MARK: - Private

	@IBOutlet private var focusView: ExposureSubmissionQRScannerFocusView!
	@IBOutlet private var instructionLabel: DynamicTypeLabel!

	private let viewModel: ExposureSubmissionQRScannerViewModel
	private let onCancelScannerView: () -> Void

//	private let flashButton = UIButton(type: .custom)

	private var previewLayer: AVCaptureVideoPreviewLayer? { didSet { setNeedsPreviewMaskUpdate() } }

	private var needsPreviewMaskUpdate: Bool = true

	private func setupView() {
		navigationItem.title = AppStrings.ExposureSubmissionQRScanner.title
		instructionLabel.text = AppStrings.ExposureSubmissionQRScanner.instruction

		instructionLabel.layer.shadowColor = UIColor.enaColor(for: .textPrimary1Contrast).cgColor
		instructionLabel.layer.shadowOpacity = 1
		instructionLabel.layer.shadowRadius = 3
		instructionLabel.layer.shadowOffset = .init(width: 0, height: 0)

/*
		flashButton.addTarget(self, action: #selector(didToggleFlash), for: .touchUpInside)
		flashButton.setImage(UIImage(systemName: "bolt"), for: .normal)
		flashButton.setImage(UIImage(systemName: "bolt.fill"), for: .selected)

		let flashBarButtonItem = UIBarButtonItem(customView: flashButton)
		navigationItem.rightBarButtonItem = flashBarButtonItem

		let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
		navigationItem.leftBarButtonItem = cancelBarButtonItem
*/
		// setup video capture layer
		let captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: viewModel.captureSession)
		captureVideoPreviewLayer.frame = view.bounds
		captureVideoPreviewLayer.videoGravity = .resizeAspectFill
		view.layer.insertSublayer(captureVideoPreviewLayer, at: 0)
		self.previewLayer = captureVideoPreviewLayer
	}

	private func setupNavigationBar() {
		navigationController?.overrideUserInterfaceStyle = .dark
		navigationController?.navigationBar.tintColor = .enaColor(for: .textContrast)
		navigationController?.navigationBar.shadowImage = UIImage()
		if let image = UIImage.with(color: UIColor(white: 0, alpha: 0.5)) {
			navigationController?.navigationBar.setBackgroundImage(image, for: .default)
		}

		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))

		let flashButton = UIButton(type: .custom)
		flashButton.addTarget(self, action: #selector(didToggleFlash), for: .touchUpInside)
		flashButton.setImage(UIImage(systemName: "bolt"), for: .normal)
		flashButton.setImage(UIImage(systemName: "bolt.fill"), for: .selected)
		flashButton.accessibilityLabel = AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityLabel
		flashButton.accessibilityTraits = [.button]
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: flashButton)
	}

	private func updateToggleFlashAccessibility() {
		guard let flashButton = navigationItem.rightBarButtonItem?.customView as? UIButton else {
			return
		}

		flashButton.accessibilityCustomActions?.removeAll()

		switch viewModel.torchMode {
		case .notAvailable:
			flashButton.isEnabled = false
			flashButton.isSelected = false
			flashButton.accessibilityValue = nil
		case .lightOn:
			flashButton.isEnabled = true
			flashButton.isSelected = true
			flashButton.accessibilityValue = AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityOnValue
			flashButton.accessibilityCustomActions = [UIAccessibilityCustomAction(name: AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityDisableAction, target: self, selector: #selector(didToggleFlash))]
		case .ligthOff:
			flashButton.isEnabled = true
			flashButton.isSelected = false
			flashButton.accessibilityValue = AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityOffValue
			flashButton.accessibilityCustomActions = [UIAccessibilityCustomAction(name: AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityEnableAction, target: self, selector: #selector(didToggleFlash))]
		}
	}

	@objc
	private func didToggleFlash() {
		viewModel.toggleFlash(completion: { [weak self] in
			DispatchQueue.main.async {
				self?.updateToggleFlashAccessibility()
			}
		})
	}

	@objc
	private func didTapCancel() {
		viewModel.stop()
		onCancelScannerView()
	}

	private func setNeedsPreviewMaskUpdate() {
		guard needsPreviewMaskUpdate else { return }
		needsPreviewMaskUpdate = true

		DispatchQueue.main.async(execute: updatePreviewMaskIfNeeded)
	}

	private func updatePreviewMaskIfNeeded() {
		guard needsPreviewMaskUpdate,
			  let previewLayer = previewLayer,
			  focusView.backdropOpacity > 0 else {
			needsPreviewMaskUpdate = false
			self.previewLayer?.mask = nil
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
