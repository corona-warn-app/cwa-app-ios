//
// 🦠 Corona-Warn-App
//

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

	@IBOutlet private var focusView: QRScannerFocusView!
	@IBOutlet private var instructionLabel: DynamicTypeLabel!

	private let viewModel: ExposureSubmissionQRScannerViewModel
	private let onCancelScannerView: () -> Void

	private var needsPreviewMaskUpdate: Bool = true
	private var previewLayer: AVCaptureVideoPreviewLayer? { didSet { setNeedsPreviewMaskUpdate() } }

	private func setupView() {
		navigationItem.title = AppStrings.ExposureSubmissionQRScanner.title
		instructionLabel.text = AppStrings.ExposureSubmissionQRScanner.instruction

		instructionLabel.layer.shadowColor = UIColor.enaColor(for: .textPrimary1Contrast).cgColor
		instructionLabel.layer.shadowOpacity = 1
		instructionLabel.layer.shadowRadius = 3
		instructionLabel.layer.shadowOffset = .init(width: 0, height: 0)

		// setup video capture layer
		let captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: viewModel.captureSession)
		captureVideoPreviewLayer.frame = view.bounds
		captureVideoPreviewLayer.videoGravity = .resizeAspectFill
		view.layer.insertSublayer(captureVideoPreviewLayer, at: 0)
		previewLayer = captureVideoPreviewLayer
	}

	private func setupNavigationBar() {
		if #available(iOS 13.0, *) {
			navigationController?.overrideUserInterfaceStyle = .dark
		}
		navigationController?.navigationBar.tintColor = .enaColor(for: .textContrast)
		navigationController?.navigationBar.shadowImage = UIImage()
		if let image = UIImage.with(color: UIColor(white: 0, alpha: 0.5)) {
			navigationController?.navigationBar.setBackgroundImage(image, for: .default)
		}

		let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
		cancelItem.accessibilityIdentifier = AccessibilityIdentifiers.General.cancelButton
		navigationItem.leftBarButtonItem = cancelItem

		let flashButton = UIButton(type: .custom)
		flashButton.imageView?.contentMode = .center
		flashButton.addTarget(self, action: #selector(didToggleFlash), for: .touchUpInside)
		flashButton.setImage(UIImage(named: "bolt"), for: .normal)
		flashButton.setImage(UIImage(named: "bolt.fill"), for: .selected)
		flashButton.accessibilityLabel = AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityLabel
		flashButton.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmissionQRScanner.flash
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
		viewModel.stopCaptureSession()
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
