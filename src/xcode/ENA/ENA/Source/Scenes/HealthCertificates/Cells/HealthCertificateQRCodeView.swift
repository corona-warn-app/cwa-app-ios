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
		noticeLabel.isHidden = viewModel.shouldBlockCertificateCode
	}

	// MARK: - Private

	private let noticeLabel: UILabel = {
		let noticeLabel = ENALabel(style: .subheadline)
		noticeLabel.numberOfLines = 0
		noticeLabel.textColor = UIColor(enaColor: .textPrimary1)
		noticeLabel.text = AppStrings.HealthCertificate.UnifiedQRCode.notice
		return noticeLabel
	}()

	private let infoButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(imageLiteralResourceName: "info"), for: .normal)
		return button
	}()

	private lazy var topStackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [noticeLabel, infoButton])
		stackView.axis = .horizontal
		stackView.spacing = 4.0
		stackView.alignment = .center
		stackView.distribution = .fillProportionally
		return stackView
	}()

	private let qrCodeImageView: UIImageView = {
		let qrCodeImageView = UIImageView()
		qrCodeImageView.contentMode = .scaleAspectFit

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
		accessibilityTraits = .image

		noticeLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(noticeLabel)

		infoButton.translatesAutoresizingMaskIntoConstraints = false
		addSubview(infoButton)

		qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(qrCodeImageView)

		blockingView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(blockingView)

		warningTriangleImageView.translatesAutoresizingMaskIntoConstraints = false
		blockingView.addSubview(warningTriangleImageView)
		
		NSLayoutConstraint.activate([
			noticeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
			noticeLabel.topAnchor.constraint(equalTo: topAnchor),
//			noticeLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

			infoButton.leadingAnchor.constraint(equalTo: noticeLabel.trailingAnchor, constant: 4.0),
			infoButton.trailingAnchor.constraint(equalTo: trailingAnchor),
			infoButton.centerYAnchor.constraint(equalTo: noticeLabel.centerYAnchor),
			infoButton.widthAnchor.constraint(equalToConstant: 30.0),
			infoButton.heightAnchor.constraint(equalToConstant: 30.0),

			qrCodeImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
			qrCodeImageView.topAnchor.constraint(equalTo: noticeLabel.bottomAnchor, constant: 14.0),
			qrCodeImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
			qrCodeImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0),

			qrCodeImageView.heightAnchor.constraint(equalTo: qrCodeImageView.widthAnchor),

			blockingView.leadingAnchor.constraint(equalTo: leadingAnchor),
			blockingView.topAnchor.constraint(equalTo: topAnchor),
			blockingView.trailingAnchor.constraint(equalTo: trailingAnchor),
			blockingView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0),

			warningTriangleImageView.centerXAnchor.constraint(equalTo: blockingView.centerXAnchor),
			warningTriangleImageView.centerYAnchor.constraint(equalTo: blockingView.centerYAnchor)
		])
	}

}
