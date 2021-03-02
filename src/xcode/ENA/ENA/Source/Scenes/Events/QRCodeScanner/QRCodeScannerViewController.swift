////
// 🦠 Corona-Warn-App
//

import UIKit
import AVFoundation

class QRCodeScannerViewController: UIViewController {

	// MARK: - Init

	init(
		presentCheckIns: @escaping () -> Void
	) {
		self.presentCheckIns = presentCheckIns
		self.viewModel = QRCodeScannerViewModel()
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupViewModel()
		setupView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewModel.activateScanning()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		viewModel.deactivateScanning()
	}

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let presentCheckIns: () -> Void
	private let viewModel: QRCodeScannerViewModel
	private var previewLayer: AVCaptureVideoPreviewLayer!

	private func setupView() {
		title = AppStrings.Events.QRScanner.title

		view.backgroundColor = .enaColor(for: .background)

		let showEventListButton = UIButton(type: .custom)
		showEventListButton.translatesAutoresizingMaskIntoConstraints = false
		showEventListButton.contentHorizontalAlignment = .leading
		showEventListButton.contentEdgeInsets = UIEdgeInsets(top: 19, left: 24, bottom: 19, right: 24)
		showEventListButton.setTitle(AppStrings.Events.QRScanner.checkinsButton, for: .normal)
		showEventListButton.setTitleColor(.enaColor(for: .buttonPrimary), for: .normal)
		let colorImage = UIImage.with(color: .enaColor(for: .cellBackground))
		showEventListButton.setBackgroundImage(colorImage, for: .normal)
		showEventListButton.layer.cornerRadius = 8.0
		showEventListButton.layer.masksToBounds = true
		view.addSubview(showEventListButton)

		NSLayoutConstraint.activate([
			showEventListButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			showEventListButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -34.0),
			showEventListButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -24.0),
			showEventListButton.heightAnchor.constraint(equalToConstant: 51.0)
		])

		showEventListButton.addTarget(self, action: #selector(didHitCheckInsButton), for: .primaryActionTriggered)
	}

	private func setupViewModel() {
		guard let captureSession = viewModel.captureSession else {
			Log.debug("Failed to setup captureSession")
			return
		}

		viewModel.onSuccess = { [weak self] stringValue in
			Log.debug("QRCode found: \(stringValue)")
		}

		viewModel.onError = { _ in
			Log.debug("Error handling not done right now")
		}

		previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		previewLayer.frame = view.layer.bounds
		previewLayer.videoGravity = .resizeAspectFill
		view.layer.addSublayer(previewLayer)
	}

	@objc
	private func didHitCheckInsButton() {
		presentCheckIns()
	}

}
