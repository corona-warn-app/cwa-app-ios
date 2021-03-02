////
// 🦠 Corona-Warn-App
//

import UIKit
import AVFoundation

class QRCodeScannerViewController: UIViewController {

	// MARK: - Init

	init() {
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
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		viewModel.activateScanning()
	}

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let viewModel: QRCodeScannerViewModel
	private var previewLayer: AVCaptureVideoPreviewLayer!

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
}
