//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

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
		switch viewModel.covPassCheckInfoPosition {
		case .top:
			stackView.removeArrangedSubview(covPassCheckInfoStackView)
			stackView.removeArrangedSubview(qrCodeImageContainerView)
			stackView.addArrangedSubview(covPassCheckInfoStackView)
			stackView.addArrangedSubview(qrCodeImageContainerView)
		case .bottom:
			stackView.removeArrangedSubview(qrCodeImageContainerView)
			stackView.removeArrangedSubview(covPassCheckInfoStackView)
			stackView.addArrangedSubview(qrCodeImageContainerView)
			stackView.addArrangedSubview(covPassCheckInfoStackView)
		}

		accessibilityLabel = viewModel.accessibilityLabel
		blockingView.isHidden = !viewModel.shouldBlockCertificateCode
		covPassCheckInfoStackView.isHidden = viewModel.shouldBlockCertificateCode
		onCovPassCheckInfoButtonTap = viewModel.onCovPassCheckInfoButtonTap

		subscriptions.removeAll()

		viewModel.$qrCodeImage
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.image, on: qrCodeImageView)
			.store(in: &subscriptions)

		self.viewModel = viewModel
	}

	// MARK: - Private

	private var viewModel: HealthCertificateQRCodeViewModel?

	private var subscriptions = Set<AnyCancellable>()

	private let stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 8

		return stackView
	}()

	private lazy var covPassCheckInfoStackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [covPassCheckInfoLabel, covPassCheckInfoButton])
		stackView.spacing = 4
		stackView.alignment = .center

		return stackView
	}()

	private let covPassCheckInfoLabel: UILabel = {
		let covPassCheckInfoLabel = ENALabel(style: .subheadline)
		covPassCheckInfoLabel.numberOfLines = 0
		covPassCheckInfoLabel.textColor = UIColor(enaColor: .textPrimary1)
		covPassCheckInfoLabel.text = AppStrings.HealthCertificate.UnifiedQRCode.notice

		return covPassCheckInfoLabel
	}()

	private lazy var covPassCheckInfoButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(imageLiteralResourceName: "infoBigger"), for: .normal)
		button.addTarget(self, action: #selector(didTapCovPassCheckInfoButton), for: .touchUpInside)

		return button
	}()

	private let qrCodeImageContainerView = UIView()

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

	private var onCovPassCheckInfoButtonTap: (() -> Void)?

	private func setUp() {
		backgroundColor = .clear
		accessibilityTraits = .image

		stackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(stackView)

		qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
		qrCodeImageContainerView.addSubview(qrCodeImageView)

		blockingView.translatesAutoresizingMaskIntoConstraints = false
		qrCodeImageContainerView.addSubview(blockingView)

		warningTriangleImageView.translatesAutoresizingMaskIntoConstraints = false
		blockingView.addSubview(warningTriangleImageView)
		
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			stackView.topAnchor.constraint(equalTo: topAnchor),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

			covPassCheckInfoButton.widthAnchor.constraint(equalToConstant: 30.0),
			covPassCheckInfoButton.heightAnchor.constraint(equalToConstant: 30.0),

			qrCodeImageView.heightAnchor.constraint(equalTo: qrCodeImageView.widthAnchor),

			qrCodeImageView.leadingAnchor.constraint(equalTo: qrCodeImageContainerView.leadingAnchor),
			qrCodeImageView.topAnchor.constraint(equalTo: qrCodeImageContainerView.topAnchor),
			qrCodeImageView.trailingAnchor.constraint(equalTo: qrCodeImageContainerView.trailingAnchor),
			qrCodeImageView.bottomAnchor.constraint(equalTo: qrCodeImageContainerView.bottomAnchor),

			blockingView.leadingAnchor.constraint(equalTo: qrCodeImageContainerView.leadingAnchor),
			blockingView.topAnchor.constraint(equalTo: qrCodeImageContainerView.topAnchor),
			blockingView.trailingAnchor.constraint(equalTo: qrCodeImageContainerView.trailingAnchor),
			blockingView.bottomAnchor.constraint(equalTo: qrCodeImageContainerView.bottomAnchor),

			warningTriangleImageView.centerXAnchor.constraint(equalTo: blockingView.centerXAnchor),
			warningTriangleImageView.centerYAnchor.constraint(equalTo: blockingView.centerYAnchor)
		])
	}

	@objc
	private func didTapCovPassCheckInfoButton() {
		onCovPassCheckInfoButtonTap?()
	}

	// MARK: - Unitest helpers

#if DEBUG
	var covPassCheckInfoLabelIsHidden: Bool {
		covPassCheckInfoLabel.isHidden
	}

	var covPassCheckInfoButtonIsHidden: Bool {
		covPassCheckInfoButton.isHidden
	}
#endif

}
