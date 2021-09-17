//
// 🦠 Corona-Warn-App
//

import UIKit
import AVFoundation

class QRScannerViewController: UIViewController {

	// MARK: - Init

	init(
		healthCertificateService: HealthCertificateService,
		verificationHelper: QRCodeVerificationHelper,
		appConfiguration: AppConfigurationProviding,
		didScan: @escaping (Result<QRCodeResult, QRCodeParserError>) -> Void,
		dismiss: @escaping () -> Void
	) {
		self.dismiss = dismiss
		
		super.init(nibName: nil, bundle: nil)
		
		viewModel = QRScannerViewModel(
			healthCertificateService: healthCertificateService,
			verificationHelper: verificationHelper,
			appConfiguration: appConfiguration,
			completion: { [weak self] result in
				switch result {
				case let .success(qrCodeResult):
					AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
					self?.viewModel?.deactivateScanning()
					didScan(.success(qrCodeResult))
				case let .failure(error):
					if error == .scanningError(.cameraPermissionDenied) {
						self?.showCameraPermissionErrorAlert(error: error)
					} else {
						didScan(.failure(error))
//						self?.showErrorAlert(error: error)
					}
				}
			}
		)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		setupViewModel()
		setupNavigationBar()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updatePreviewMask()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewModel?.activateScanning()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		viewModel?.deactivateScanning()
	}

	// MARK: - Private

	private let focusView = QRScannerFocusView()
	private let dismiss: () -> Void
	private let flashButtonTag = 12
	
	private var viewModel: QRScannerViewModel?
	private var previewLayer: AVCaptureVideoPreviewLayer! { didSet { updatePreviewMask() } }

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)

		focusView.backdropOpacity = 0.2
		focusView.tintColor = .enaColor(for: .textContrast)
		focusView.translatesAutoresizingMaskIntoConstraints = false
		focusView.configure(cornerRadius: 8, borderWidth: 1)

		let scannerTitle = ENALabel()
		scannerTitle.style = .title1
		scannerTitle.numberOfLines = 0
		scannerTitle.textAlignment = .left
		scannerTitle.textColor = .enaColor(for: .textPrimary1)
		scannerTitle.font = .enaFont(for: .body)
		scannerTitle.text = AppStrings.UniversalQRScanner.scannerTitle
		scannerTitle.translatesAutoresizingMaskIntoConstraints = false
		
		let instructionTitle = ENALabel()
		instructionTitle.style = .title2
		instructionTitle.numberOfLines = 0
		instructionTitle.textAlignment = .center
		instructionTitle.textColor = .enaColor(for: .textPrimary1)
		instructionTitle.font = .enaFont(for: .body)
		instructionTitle.text = AppStrings.UniversalQRScanner.instructionTitle
		instructionTitle.translatesAutoresizingMaskIntoConstraints = false
		
		let instructionDescription = ENALabel()
		instructionDescription.style = .subheadline
		instructionDescription.numberOfLines = 0
		instructionDescription.textAlignment = .center
		instructionDescription.textColor = .enaColor(for: .textPrimary1)
		instructionDescription.font = .enaFont(for: .body)
		instructionDescription.text = AppStrings.UniversalQRScanner.instructionDescription
		instructionDescription.translatesAutoresizingMaskIntoConstraints = false

		let flashButton = UIButton(type: .custom)
		flashButton.imageView?.contentMode = .center
		flashButton.addTarget(self, action: #selector(didToggleFlash), for: .touchUpInside)
		flashButton.setImage(UIImage(named: "flash_disabled"), for: .normal)
		flashButton.setImage(UIImage(named: "bolt.fill"), for: .selected)
		flashButton.accessibilityLabel = AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityLabel
		flashButton.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmissionQRScanner.flash
		flashButton.accessibilityTraits = [.button]
		flashButton.tag = flashButtonTag
		flashButton.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(scannerTitle)
		view.addSubview(focusView)
		view.addSubview(instructionTitle)
		view.addSubview(instructionDescription)
		view.addSubview(flashButton)

		NSLayoutConstraint.activate(
			[
				scannerTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
				scannerTitle.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
				scannerTitle.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9, constant: 0),

				focusView.topAnchor.constraint(equalTo: scannerTitle.bottomAnchor, constant: 25),
				focusView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
				focusView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9, constant: 0),
				focusView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.45, constant: 0),
				
				instructionTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
				instructionTitle.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75, constant: 0),
				instructionTitle.topAnchor.constraint(greaterThanOrEqualTo: focusView.bottomAnchor, constant: 30),
				
				instructionDescription.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
				instructionDescription.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75, constant: 0),
				instructionDescription.topAnchor.constraint(greaterThanOrEqualTo: instructionTitle.bottomAnchor, constant: 15),
				
				flashButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
				flashButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
				flashButton.heightAnchor.constraint(equalTo: flashButton.heightAnchor, constant: 0),
				flashButton.widthAnchor.constraint(equalTo: flashButton.widthAnchor, constant: 0)
			]
		)
	}

	private func setupNavigationBar() {
		navigationController?.navigationBar.tintColor = .enaColor(for: .tint)
		
		let emptyImage = UIImage()
		navigationController?.navigationBar.setBackgroundImage(emptyImage, for: .default)
		navigationController?.navigationBar.shadowImage = emptyImage
		navigationController?.navigationBar.isTranslucent = true
		navigationController?.view.backgroundColor = .enaColor(for: .background).withAlphaComponent(0.2)

		let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapDismiss))
		cancelItem.accessibilityIdentifier = AccessibilityIdentifiers.General.cancelButton
		navigationItem.leftBarButtonItem = cancelItem
	}

	@objc
	private func didTapDismiss() {
		dismiss()
	}
	
	@objc
	private func didToggleFlash() {
		viewModel?.toggleFlash()
		updateToggleFlashAccessibility()
	}
	
	private func updateToggleFlashAccessibility() {
		guard let flashButton = self.view.viewWithTag(flashButtonTag) as? UIButton else {
			return
		}

		flashButton.accessibilityCustomActions?.removeAll()
		
		switch viewModel?.torchMode {
		case .notAvailable:
			flashButton.isEnabled = false
			flashButton.isSelected = false
			flashButton.accessibilityValue = nil
		case .lightOn:
			flashButton.isEnabled = true
			flashButton.isSelected = true
			flashButton.accessibilityValue = AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityOnValue
			flashButton.accessibilityCustomActions = [UIAccessibilityCustomAction(name: AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityDisableAction, target: self, selector: #selector(didToggleFlash))]
		case .lightOff:
			flashButton.isEnabled = true
			flashButton.isSelected = false
			flashButton.accessibilityValue = AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityOffValue
			flashButton.accessibilityCustomActions = [UIAccessibilityCustomAction(name: AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityEnableAction, target: self, selector: #selector(didToggleFlash))]
		case .none:
			break
		}
	}

	private func setupViewModel() {
		guard let captureSession = viewModel?.captureSession else {
			Log.debug("Failed to setup captureSession", log: .checkin)
			// Add dummy layer because the simulator doesn't support the camera
			previewLayer = AVCaptureVideoPreviewLayer()
			return
		}
		viewModel?.startCaptureSession()

		previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		previewLayer.frame = view.layer.bounds
		previewLayer.videoGravity = .resizeAspectFill
		view.layer.insertSublayer(previewLayer, at: 0)
	}

	private func showErrorAlert(error: Error) {
		viewModel?.deactivateScanning()

		var alertTitle = AppStrings.HealthCertificate.Error.title
		var errorMessage = error.localizedDescription + AppStrings.HealthCertificate.Error.faqDescription
		var faqAlertAction = UIAlertAction(
			title: AppStrings.HealthCertificate.Error.faqButtonTitle,
			style: .default,
			handler: { [weak self] _ in
				if LinkHelper.open(urlString: AppStrings.Links.healthCertificateErrorFAQ) {
					self?.viewModel?.activateScanning()
				}
			}
		)

		// invalid signature error needs a different title, errorMessage and FAQ action
		if case let QRScannerError.other(wrappedError) = error,
		   case HealthCertificateServiceError.RegistrationError.invalidSignature = wrappedError {
			alertTitle = AppStrings.HealthCertificate.Error.invalidSignatureTitle
			errorMessage = wrappedError.localizedDescription
			faqAlertAction = UIAlertAction(
				title: AppStrings.HealthCertificate.Error.invalidSignatureFAQButtonTitle,
				style: .default,
				handler: { [weak self] _ in
					if LinkHelper.open(urlString: AppStrings.Links.invalidSignatureFAQ) {
						self?.viewModel?.activateScanning()
					}
				}
			)
		}

		let alert = UIAlertController(
			title: alertTitle,
			message: errorMessage,
			preferredStyle: .alert
		)
		alert.addAction(faqAlertAction)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.Common.alertActionOk,
				style: .default,
				handler: { [weak self] _ in
					self?.viewModel?.activateScanning()
				}
			)
		)

		DispatchQueue.main.async { [weak self] in
			self?.present(alert, animated: true)
		}
	}

	private func showCameraPermissionErrorAlert(error: Error) {
		let alert = UIAlertController(
			title: AppStrings.HealthCertificate.Error.title,
			message: error.localizedDescription,
			preferredStyle: .alert
		)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.Common.alertActionOk,
				style: .cancel,
				handler: { [weak self] _ in
					self?.dismiss()
				}
			)
		)

		DispatchQueue.main.async { [weak self] in
			self?.present(alert, animated: true)
		}
	}

	private func updatePreviewMask() {
		guard let previewLayer = previewLayer else {
			Log.debug("No preview layer available")
			return
		}

		let backdropColor = UIColor(white: 0, alpha: 0.2)
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
