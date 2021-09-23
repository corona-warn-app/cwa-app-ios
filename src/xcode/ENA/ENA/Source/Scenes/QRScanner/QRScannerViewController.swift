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
		markCertificateAsNew: Bool,
		markCoronaTestAsNew: Bool,
		didScan: @escaping (QRCodeResult) -> Void,
		dismiss: @escaping () -> Void
	) {
		self.dismiss = dismiss
		
		super.init(nibName: nil, bundle: nil)
		
		viewModel = QRScannerViewModel(
			healthCertificateService: healthCertificateService,
			verificationHelper: verificationHelper,
			appConfiguration: appConfiguration,
			markCertificateAsNew: markCertificateAsNew,
			markCoronaTestAsNew: markCoronaTestAsNew,
			completion: { [weak self] result in
				switch result {
				case let .success(qrCodeResult):
					AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
					self?.viewModel?.deactivateScanning()
					didScan(qrCodeResult)
				case let .failure(error):
					if error == .scanningError(.cameraPermissionDenied) {
						self?.showCameraPermissionErrorAlert()
					} else {
						self?.showErrorAlert(error: error)
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
	private let contentView = UIView()
	private var previewLayer: AVCaptureVideoPreviewLayer! { didSet { updatePreviewMask() } }
	private let flashButton = UIButton(type: .custom)
	
	private var viewModel: QRScannerViewModel?
	private let dismiss: () -> Void

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)

		focusView.backdropOpacity = 0.2
		focusView.tintColor = .enaColor(for: .textContrast)
		focusView.translatesAutoresizingMaskIntoConstraints = false
		focusView.configure(cornerRadius: 8, borderWidth: 1)
		
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

		flashButton.imageView?.contentMode = .center
		flashButton.addTarget(self, action: #selector(didToggleFlash), for: .touchUpInside)
		flashButton.setImage(UIImage(named: "flash_disabled"), for: .normal)
		flashButton.setImage(UIImage(named: "bolt.fill"), for: .selected)
		flashButton.accessibilityLabel = AppStrings.ExposureSubmissionQRScanner.flashButtonAccessibilityLabel
		flashButton.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmissionQRScanner.flash
		flashButton.accessibilityTraits = [.button]
		flashButton.translatesAutoresizingMaskIntoConstraints = false

		contentView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(instructionTitle)
		contentView.addSubview(instructionDescription)

		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(contentView)
		scrollView.contentInsetAdjustmentBehavior = .never
		
		view.addSubview(focusView)
		view.addSubview(scrollView)
		view.addSubview(flashButton)

		NSLayoutConstraint.activate(
			[
				focusView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
				focusView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
				focusView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9, constant: 0),
				focusView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.45, constant: 25),
				
				instructionTitle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
				instructionTitle.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75, constant: 0),
				instructionTitle.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 0),
				
				instructionDescription.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
				instructionDescription.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75, constant: 0),
				instructionDescription.topAnchor.constraint(greaterThanOrEqualTo: instructionTitle.bottomAnchor, constant: 15),
				instructionDescription.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor, constant: 0),
				
				flashButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35),
				flashButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
				flashButton.heightAnchor.constraint(equalToConstant: 25),
				flashButton.widthAnchor.constraint(equalToConstant: 20),
				
				contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
				contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
				contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
				contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
				contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
				
				scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				scrollView.topAnchor.constraint(equalTo: focusView.bottomAnchor, constant: 25),
				scrollView.bottomAnchor.constraint(equalTo: flashButton.topAnchor, constant: -10),
				scrollView.widthAnchor.constraint(equalTo: view.widthAnchor)
			]
		)
	}

	private func setupNavigationBar() {
		navigationItem.title = AppStrings.UniversalQRScanner.scannerTitle
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

	private func showErrorAlert(error: QRCodeParserError) {
		viewModel?.deactivateScanning()

		let unwrappedError: Error
		switch error {
		case .scanningError(let qrScannerError):
			unwrappedError = qrScannerError
		case .checkinQrError(let checkinQRScannerError):
			unwrappedError = checkinQRScannerError
		case .certificateQrError(let healthCertificateServiceError):
			unwrappedError = healthCertificateServiceError
		}

		var alertTitle = AppStrings.HealthCertificate.Error.title
		var errorMessage = unwrappedError.localizedDescription
		var faqAlertAction: UIAlertAction?

		if case .certificateQrError(.invalidSignature) = error {
			// invalid signature error on certificates needs a specific title, errorMessage and FAQ action
			alertTitle = AppStrings.HealthCertificate.Error.invalidSignatureTitle
			errorMessage = unwrappedError.localizedDescription
			faqAlertAction = UIAlertAction(
				title: AppStrings.HealthCertificate.Error.invalidSignatureFAQButtonTitle,
				style: .default,
				handler: { [weak self] _ in
					if LinkHelper.open(urlString: AppStrings.Links.invalidSignatureFAQ) {
						self?.viewModel?.activateScanning()
					}
				}
			)
		} else if case .certificateQrError = error {
			// Show FAQ section for other certificate errors
			errorMessage += AppStrings.HealthCertificate.Error.faqDescription

			faqAlertAction = UIAlertAction(
				title: AppStrings.HealthCertificate.Error.faqButtonTitle,
				style: .default,
				handler: { [weak self] _ in
					if LinkHelper.open(urlString: AppStrings.Links.healthCertificateErrorFAQ) {
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

		if let faqAlertAction = faqAlertAction {
			alert.addAction(faqAlertAction)
		}
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

	private func showCameraPermissionErrorAlert() {
		let alert = UIAlertController(
			title: AppStrings.HealthCertificate.Error.title,
			message: QRScannerError.cameraPermissionDenied.localizedDescription,
			preferredStyle: .alert
		)
		alert.addAction(
			UIAlertAction(
				title: AppStrings.Common.alertActionOk,
				style: .cancel,
				handler: { [weak self] _ in
					// self?.dismiss()
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
