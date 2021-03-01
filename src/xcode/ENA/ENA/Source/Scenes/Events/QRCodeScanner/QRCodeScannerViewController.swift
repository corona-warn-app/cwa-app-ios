////
// 🦠 Corona-Warn-App
//

import UIKit
import AVFoundation

class QRCodeScannerViewController: UIViewController {

	// MARK: - Init

	init(
		dismiss: @escaping () -> Void
	) {
		self.dismiss = dismiss
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

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let viewModel: QRCodeScannerViewModel
	private var previewLayer: AVCaptureVideoPreviewLayer!
	private let dismiss: () -> Void

	private func setupViewModel() {
		viewModel.onSuccess = { [weak self] stringValue in
			Log.debug("QRCode found: \(stringValue)")
			self?.dismiss()
		}

		viewModel.onError = { _ in
			Log.debug("Error handling not done right now")
		}

		previewLayer = AVCaptureVideoPreviewLayer(session: viewModel.captureSession)
		previewLayer.frame = view.layer.bounds
		previewLayer.videoGravity = .resizeAspectFill
		view.layer.addSublayer(previewLayer)

		viewModel.activateScanning()
	}
}
