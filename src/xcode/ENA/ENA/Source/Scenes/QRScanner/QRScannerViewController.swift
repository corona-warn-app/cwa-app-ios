//
// 🦠 Corona-Warn-App
//

import UIKit
import AVFoundation

// swiftlint:disable:next type_body_length
class QRScannerViewController: UIViewController {

	// MARK: - Init

	init(
		healthCertificateService: HealthCertificateService,
		appConfiguration: AppConfigurationProviding,
		markCertificateAsNew: Bool,
		didScan: @escaping (QRCodeResult) -> Void,
		dismiss: @escaping () -> Void,
		presentFileScanner: @escaping () -> Void,
		onInfoButtonTap: @escaping () -> Void,
		onShowCameraPermissionError: @escaping () -> Void,
		onOtherScanningError: @escaping (QRCodeParserError) -> Void
	) {
		self.dismiss = dismiss
		self.presentFileScanner = presentFileScanner
		self.onInfoButtonTap = onInfoButtonTap

		super.init(nibName: nil, bundle: nil)

		let qrCodeParser = QRCodeParser(
			appConfigurationProvider: appConfiguration,
			healthCertificateService: healthCertificateService,
			markCertificateAsNew: markCertificateAsNew
		)
		
		viewModel = QRScannerViewModel(
			healthCertificateService: healthCertificateService,
			appConfiguration: appConfiguration,
			qrCodeParser: qrCodeParser,
			completion: { [weak self] result in
				switch result {
				case let .success(qrCodeResult):
					AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
					self?.viewModel?.deactivateScanning()
					didScan(qrCodeResult)
				case let .failure(error):
					if error == .scanningError(.cameraPermissionDenied) {
						#if targetEnvironment(simulator)
						// Don't show an error in simulator to enable debugging/UI-Tests
						return
						#else
						onShowCameraPermissionError()
						#endif
					} else {
						onOtherScanningError(error)
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
		#if targetEnvironment(simulator)
		// Show Debug to select QRCode that got scanned
		showCodeSelection()
		#endif
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

	// MARK: - Internal

	func activateScanning() {
		viewModel?.activateScanning()
	}

	// MARK: - Private

	private let focusView = QRScannerFocusView()
	private let dismiss: () -> Void
	private let presentFileScanner: () -> Void
	private let onInfoButtonTap: () -> Void
	private let contentView = UIView()
	private let flashButton = UIButton(type: .custom)
	private let fileButton = UIButton(type: .custom)
	private var previewLayer: AVCaptureVideoPreviewLayer! { didSet { updatePreviewMask() } }
	private var viewModel: QRScannerViewModel?

	private lazy var infoButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(imageLiteralResourceName: "infoBigger"), for: .normal)
		button.addTarget(self, action: #selector(didHitInfoButton), for: .touchUpInside)
		button.accessibilityLabel = AppStrings.UniversalQRScanner.Info.title
		button.accessibilityIdentifier = AccessibilityIdentifiers.UniversalQRScanner.info

		return button
	}()

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
		instructionDescription.textColor = .enaColor(for: .iconWithText)
		instructionDescription.font = .enaFont(for: .body)
		instructionDescription.text = AppStrings.UniversalQRScanner.instructionDescription
		instructionDescription.translatesAutoresizingMaskIntoConstraints = false

		fileButton.contentMode = .left
		fileButton.setImage(UIImage(imageLiteralResourceName: "file_button"), for: .normal)
		fileButton.setTitle(AppStrings.UniversalQRScanner.fileButtonTitle, for: .normal)
		fileButton.addTarget(self, action: #selector(didTapFileButton), for: .touchUpInside)
		fileButton.translatesAutoresizingMaskIntoConstraints = false
		fileButton.titleLabel?.font = .enaFont(for: .subheadline)
		fileButton.setTitleColor(.enaColor(for: .iconWithText), for: .normal)
		fileButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
		fileButton.accessibilityIdentifier = AccessibilityIdentifiers.UniversalQRScanner.file
		fileButton.accessibilityTraits = .button

		flashButton.imageView?.contentMode = .center
		flashButton.addTarget(self, action: #selector(didToggleFlash), for: .touchUpInside)
		flashButton.setImage(UIImage(named: "flash_disabled"), for: .normal)
		flashButton.setImage(UIImage(named: "bolt.fill"), for: .selected)
		flashButton.accessibilityLabel = AppStrings.UniversalQRScanner.flashButtonAccessibilityLabel
		flashButton.accessibilityIdentifier = AccessibilityIdentifiers.UniversalQRScanner.flash
		flashButton.accessibilityTraits = [.button]
		flashButton.translatesAutoresizingMaskIntoConstraints = false

		contentView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(instructionTitle)
		contentView.addSubview(instructionDescription)

		infoButton.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(infoButton)

		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(contentView)
		scrollView.contentInsetAdjustmentBehavior = .never
		
		view.addSubview(focusView)
		view.addSubview(scrollView)
		view.addSubview(flashButton)
		view.addSubview(fileButton)

		NSLayoutConstraint.activate(
			[
				focusView.topAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
				focusView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
				focusView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9, constant: 0),
				focusView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.45, constant: 0),
				
				instructionTitle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
				instructionTitle.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75, constant: 0),
				instructionTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
				
				instructionDescription.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
				instructionDescription.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75, constant: 0),
				instructionDescription.topAnchor.constraint(equalTo: instructionTitle.bottomAnchor, constant: 15),
				instructionDescription.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),

				infoButton.topAnchor.constraint(equalTo: instructionDescription.topAnchor, constant: -4),
				infoButton.leadingAnchor.constraint(equalTo: instructionDescription.trailingAnchor, constant: 4),
				infoButton.widthAnchor.constraint(equalToConstant: 30.0),
				infoButton.heightAnchor.constraint(equalToConstant: 30.0),
				
				contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
				contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
				contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
				contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
				contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
				
				scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				scrollView.topAnchor.constraint(equalTo: focusView.bottomAnchor, constant: 25),
				scrollView.bottomAnchor.constraint(greaterThanOrEqualTo: flashButton.topAnchor, constant: -10),
				scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),

				fileButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35),
				fileButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
				fileButton.heightAnchor.constraint(equalToConstant: 25),

				flashButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35),
				flashButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
				flashButton.heightAnchor.constraint(equalToConstant: 25),
				flashButton.widthAnchor.constraint(equalToConstant: 20)
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
	private func didTapFileButton() {
		presentFileScanner()
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
			flashButton.accessibilityValue = AppStrings.UniversalQRScanner.flashButtonAccessibilityOnValue
			flashButton.accessibilityCustomActions = [UIAccessibilityCustomAction(name: AppStrings.UniversalQRScanner.flashButtonAccessibilityDisableAction, target: self, selector: #selector(didToggleFlash))]
		case .lightOff:
			flashButton.isEnabled = true
			flashButton.isSelected = false
			flashButton.accessibilityValue = AppStrings.UniversalQRScanner.flashButtonAccessibilityOffValue
			flashButton.accessibilityCustomActions = [UIAccessibilityCustomAction(name: AppStrings.UniversalQRScanner.flashButtonAccessibilityEnableAction, target: self, selector: #selector(didToggleFlash))]
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

	@objc
	private func didHitInfoButton() {
		onInfoButtonTap()
	}
	
	#if targetEnvironment(simulator)
	private func showCodeSelection() {
		let alertVC = UIAlertController(title: "Select a QRCode you want to fake", message: nil, preferredStyle: .alert)
		let hc1 = UIAlertAction(title: "HC1", style: .default, handler: { [weak self] _ in
			self?.viewModel?.fakeHealthCert1Scan()
		})
		hc1.accessibilityIdentifier = AccessibilityIdentifiers.UniversalQRScanner.fakeHC1
		alertVC.addAction(hc1)
		
		let hc2 = UIAlertAction(title: "HC2", style: .default, handler: { [weak self] _ in
			self?.viewModel?.fakeHealthCert2Scan()
		})
		hc2.accessibilityIdentifier = AccessibilityIdentifiers.UniversalQRScanner.fakeHC2
		alertVC.addAction(hc2)
		
		let pcr = UIAlertAction(title: "PCR", style: .default, handler: { [weak self] _ in
			self?.viewModel?.fakePCRTestScan()
		})
		pcr.accessibilityIdentifier = AccessibilityIdentifiers.UniversalQRScanner.fakePCR
		alertVC.addAction(pcr)
		
		let pcr2 = UIAlertAction(title: "PCR2", style: .default, handler: { [weak self] _ in
			self?.viewModel?.fakePCRTest2Scan()
		})
		pcr2.accessibilityIdentifier = AccessibilityIdentifiers.UniversalQRScanner.fakePCR2
		alertVC.addAction(pcr2)
		
		let event = UIAlertAction(title: "Event", style: .default, handler: { [weak self] _ in
			self?.viewModel?.fakeEventScan()
		})
		event.accessibilityIdentifier = AccessibilityIdentifiers.UniversalQRScanner.fakeEvent
		alertVC.addAction(event)

		let ticketValidation = UIAlertAction(title: "Ticket Validation", style: .default, handler: { [weak self] _ in
			self?.viewModel?.fakeTicketValidation()
		})
		ticketValidation.accessibilityIdentifier = AccessibilityIdentifiers.UniversalQRScanner.fakeTicketValidation
		alertVC.addAction(ticketValidation)

		let other = UIAlertAction(title: "Other", style: .cancel)
		other.accessibilityIdentifier = AccessibilityIdentifiers.UniversalQRScanner.other
		alertVC.addAction(other)
		
		present(alertVC, animated: false, completion: nil)
		
	}
	#endif
}
