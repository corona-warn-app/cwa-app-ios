//
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateQRCodeView: UIView {

	// MARK: - Init

	init() {
		super.init(frame: .zero)

		setUp()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		setUp()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	func configure(with viewModel: HealthCertificateQRCodeViewModel) {
		qrCodeImageView.image = viewModel.qrCodeImage
		accessibilityLabel = viewModel.accessibilityLabel
		blockingView.isHidden = !viewModel.shouldBlockCertificateCode
	}

	// MARK: - Private

	private let qrCodeImageView: UIImageView = {
		let qrCodeImageView = UIImageView()
		qrCodeImageView.contentMode = .scaleAspectFit
		qrCodeImageView.layer.magnificationFilter = CALayerContentsFilter.nearest

		return qrCodeImageView
	}()

	private let blockingView: UIView = {
		let blockingView = UIView()
		blockingView.backgroundColor = UIColor.white.withAlphaComponent(0.9)

		return blockingView
	}()

	private let warningTriangleImageView: UIImageView = {
		let warningTriangleImageView = UIImageView()
		warningTriangleImageView.contentMode = .scaleAspectFit
		warningTriangleImageView.image = UIImage(named: "Icon_WarningTriangle_blocking")

		return warningTriangleImageView
	}()

	private func setUp() {
		backgroundColor = .clear

		qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(qrCodeImageView)

		blockingView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(blockingView)

		warningTriangleImageView.translatesAutoresizingMaskIntoConstraints = false
		blockingView.addSubview(warningTriangleImageView)
		
		NSLayoutConstraint.activate([
			qrCodeImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
			qrCodeImageView.topAnchor.constraint(equalTo: topAnchor),
			qrCodeImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
			qrCodeImageView.bottomAnchor.constraint(equalTo: bottomAnchor),

			blockingView.leadingAnchor.constraint(equalTo: leadingAnchor),
			blockingView.topAnchor.constraint(equalTo: topAnchor),
			blockingView.trailingAnchor.constraint(equalTo: trailingAnchor),
			blockingView.bottomAnchor.constraint(equalTo: bottomAnchor),

			warningTriangleImageView.centerXAnchor.constraint(equalTo: blockingView.centerXAnchor),
			warningTriangleImageView.centerYAnchor.constraint(equalTo: blockingView.centerYAnchor)
		])
	}

}
