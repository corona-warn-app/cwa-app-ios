////
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateQRCodeCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
		isAccessibilityElement = false

		qrCodeImageView.isAccessibilityElement = true
		qrCodeImageView.accessibilityTraits = .image
		certificateCountLabel.isAccessibilityElement = true
		validityLabel.isAccessibilityElement = true

		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.qrCodeCell
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateBorderWidth()
	}

	// MARK: - Internal

	func configure(with cellViewModel: HealthCertificateQRCodeCellViewModel) {
		qrCodeImageView.image = cellViewModel.qrCodeImage
		qrCodeImageView.accessibilityLabel = cellViewModel.accessibilityText

		backgroundContainerView.backgroundColor = cellViewModel.backgroundColor
		backgroundContainerView.layer.borderColor = cellViewModel.borderColor.cgColor

		certificateCountLabel.text = cellViewModel.certificate
		certificateCountLabel.isHidden = cellViewModel.certificate == nil

		validityLabel.text = cellViewModel.validity
		validityLabel.isHidden = cellViewModel.validity == nil
	}

	// MARK: - Private

	private let backgroundContainerView = UIView()
	private let qrCodeImageView = UIImageView()
	private let certificateCountLabel = ENALabel()
	private let validityLabel = ENALabel()
	private let stackView = UIStackView()

	private func setupView() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		selectionStyle = .none

		if #available(iOS 13.0, *) {
			backgroundContainerView.layer.cornerCurve = .continuous
		}
		backgroundContainerView.layer.cornerRadius = 15.0
		backgroundContainerView.layer.masksToBounds = true
		updateBorderWidth()

		backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(backgroundContainerView)

		qrCodeImageView.contentMode = .scaleAspectFit
		qrCodeImageView.layer.magnificationFilter = CALayerContentsFilter.nearest
		stackView.addArrangedSubview(qrCodeImageView)

		certificateCountLabel.font = .enaFont(for: .headline)
		certificateCountLabel.numberOfLines = 0
		stackView.addArrangedSubview(certificateCountLabel)

		validityLabel.font = .enaFont(for: .body)
		validityLabel.numberOfLines = 0
		stackView.addArrangedSubview(validityLabel)

		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.alignment = .leading
		stackView.axis = .vertical
		stackView.spacing = 4.0
		backgroundContainerView.addSubview(stackView)

		NSLayoutConstraint.activate(
			[
				backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0),
				backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0),
				backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				qrCodeImageView.heightAnchor.constraint(equalTo: qrCodeImageView.widthAnchor),

				stackView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 14.0),
				stackView.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 14.0),
				stackView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -14.0),
				stackView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -14.0)
			]
		)

	}

	private func updateBorderWidth() {
		backgroundContainerView.layer.borderWidth = traitCollection.userInterfaceStyle == .dark ? 0 : 1
	}

}
