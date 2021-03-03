////
// 🦠 Corona-Warn-App
//

import UIKit
import AVFoundation
import OpenCombine

class CheckInQRCodeScannerViewController: UIViewController {

	// MARK: - Init

	init(
		presentEventForCheckIn: @escaping (CGRect, String) -> Void,
		presentCheckIns: @escaping () -> Void
	) {
		self.presentEventForCheckIn = presentEventForCheckIn
		self.presentCheckIns = presentCheckIns
		self.viewModel = CheckInQRCodeScannerViewModel()
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

	private let presentEventForCheckIn: (CGRect, String) -> Void
	private let presentCheckIns: () -> Void
	private let viewModel: CheckInQRCodeScannerViewModel

	private var previewLayer: AVCaptureVideoPreviewLayer!
	private var subscriptions: [AnyCancellable] = []

	private func setupView() {
		navigationItem.title = AppStrings.Events.QRScanner.title

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
			Log.debug("Failed to setup captureSession", log: .checkin)
			return
		}

		previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		previewLayer.frame = view.layer.bounds
		previewLayer.videoGravity = .resizeAspectFill
		view.layer.addSublayer(previewLayer)

		viewModel.onSuccess = { [weak self] metadataObject in
			guard let self = self,
				  let route = Route(metadataObject.stringValue),
				  let avMetaDataObject = metadataObject as? AVMetadataObject,
				  let newRect = self.previewLayer.transformedMetadataObject(for: avMetaDataObject)?.bounds,
				  case let Route.event(event) = route else {
				// we found something but will continue to scan
				return
			}
			AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
			self.viewModel.deactivateScanning()
			self.presentEventForCheckIn(newRect, event)
		}

		viewModel.onError = { _ in
			Log.debug("Error handling not done right now", log: .checkin)
		}

		viewModel.$qrCodes.sink { [weak self] metadataObjects in
			self?.qrRectViews.forEach { view in
				view.removeFromSuperview()
			}

			metadataObjects.forEach { metadataObject in
				if let barCodeObject = self?.previewLayer.transformedMetadataObject(for: metadataObject) {
					let qrRectView = UIView(frame: barCodeObject.bounds.insetBy(dx: -6.0, dy: -6.0))
					qrRectView.layer.borderWidth = 4.0
					qrRectView.layer.borderColor = UIColor.enaColor(for: .buttonPrimary).cgColor
					qrRectView.layer.cornerRadius = 8.0
					self?.view.addSubview(qrRectView)
					self?.qrRectViews.append(qrRectView)
				}
			}
		}
		.store(in: &subscriptions)
		
	}

	@objc
	private func didHitCheckInsButton() {
		presentCheckIns()
	}

	private var qrRectViews: [UIView] = []

}
