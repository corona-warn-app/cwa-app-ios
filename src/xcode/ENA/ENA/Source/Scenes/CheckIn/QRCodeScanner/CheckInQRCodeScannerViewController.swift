////
// 🦠 Corona-Warn-App
//

import UIKit
import AVFoundation
import OpenCombine

class CheckInQRCodeScannerViewController: UIViewController {

	// MARK: - Init

	init(
		didScanCheckIn: @escaping (String) -> Void,
		dismiss: @escaping () -> Void
	) {
		self.didScanCheckIn = didScanCheckIn
		self.viewModel = CheckInQRCodeScannerViewModel()
		self.dismiss = dismiss
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.rightBarButtonItem = CloseBarButtonItem(onTap: dismiss)

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

	// MARK: - Private

	private let didScanCheckIn: (String) -> Void
	private let dismiss: () -> Void

	private let viewModel: CheckInQRCodeScannerViewModel
	private var previewLayer: AVCaptureVideoPreviewLayer!

	private func setupView() {
		navigationItem.title = AppStrings.Events.QRScanner.title
		view.backgroundColor = .enaColor(for: .background)
	}

	private func setupViewModel() {
		guard let captureSession = viewModel.captureSession else {
			Log.debug("Failed to setup captureSession", log: .checkin)
			return
		}

		previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		previewLayer.frame = view.layer.bounds
		previewLayer.videoGravity = .resizeAspectFill
		view.layer.addSublayer(previewLayer)

		viewModel.onSuccess = { [weak self] event in
			guard let self = self else {
				return
			}
			AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
			self.viewModel.deactivateScanning()
			self.didScanCheckIn(event)
		}

		viewModel.onError = { [weak self] error in
			switch error {
			// for the moment we always show the same alert
			case .cameraPermissionDenied:
				self?.showErrorAlert()
			case .codeNotFound:
				self?.showErrorAlert()
			case .other:
				self?.showErrorAlert()
			}
		}
	}

	private func showErrorAlert() {

		viewModel.deactivateScanning()

		let alert = UIAlertController(title: "QR-Code nicht gültig", message: nil, preferredStyle: .alert)
		alert.addAction(
			UIAlertAction(
				title: "abbrechen",
				style: .cancel,
				handler: { [weak self] _ in
					self?.dismiss()
				}
			)
		)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
			self?.viewModel.activateScanning()
		}))

		DispatchQueue.main.async { [weak self] in
			self?.present(alert, animated: true)
		}
	}

}
