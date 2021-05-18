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
		backgroundContainerView.isAccessibilityElement = true
		backgroundContainerView.accessibilityTraits = .image
		backgroundContainerView.accessibilityLabel = AppStrings.ExposureSubmission.AntigenTest.Profile.QRCodeImageDescription
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	func configure(with cellViewModel: HealthCertificateQRCodeCellViewModel) {
		qrCodeImageView.image = cellViewModel.qrCodeImage
		backgroundContainerView.backgroundColor = cellViewModel.backgroundColor
		backgroundContainerView.layer.borderColor = cellViewModel.borderColor.cgColor
		certificateCountLabel.text = cellViewModel.certificate
		validityLabel.text = cellViewModel.validity
	}

	// MARK: - Private

	private let backgroundContainerView = UIView()
	private let qrCodeImageView = UIImageView()
	private let certificateCountLabel = ENALabel()
	private let validityLabel = ENALabel()

	private func setupView() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		selectionStyle = .none

		if #available(iOS 13.0, *) {
			backgroundContainerView.layer.cornerCurve = .continuous
		}
		backgroundContainerView.layer.cornerRadius = 15.0
		backgroundContainerView.layer.masksToBounds = true
		backgroundContainerView.layer.borderWidth = 1.0

		backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(backgroundContainerView)

		qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
		qrCodeImageView.contentMode = .scaleAspectFit
		qrCodeImageView.layer.magnificationFilter = CALayerContentsFilter.nearest
		backgroundContainerView.addSubview(qrCodeImageView)

		certificateCountLabel.translatesAutoresizingMaskIntoConstraints = false
		certificateCountLabel.font = .enaFont(for: .headline)
		certificateCountLabel.numberOfLines = 0

		validityLabel.translatesAutoresizingMaskIntoConstraints = false
		validityLabel.font = .enaFont(for: .body)
		validityLabel.numberOfLines = 0

		let stackView = UIStackView(arrangedSubviews: [certificateCountLabel, validityLabel])
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

				qrCodeImageView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 14.0),
				qrCodeImageView.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 14.0),
				qrCodeImageView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -14.0),
				qrCodeImageView.widthAnchor.constraint(equalTo: qrCodeImageView.heightAnchor),

				stackView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 14.0),
				stackView.topAnchor.constraint(equalTo: qrCodeImageView.bottomAnchor, constant: 4.0),
				stackView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -14.0),
				stackView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -14.0)
			]
		)

	}

}
