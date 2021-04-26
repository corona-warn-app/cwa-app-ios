////
// 🦠 Corona-Warn-App
//

import UIKit

class QRCodeCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	func configure(with cellViewModel: QRCodeCellViewModel) {
		qrCodeImageView.image = cellViewModel.qrCodeImage
		backgroundContainerView.backgroundColor = cellViewModel.backgroundColor
		backgroundContainerView.layer.borderColor = cellViewModel.boarderColor.cgColor
	}

	// MARK: - Private

	private let backgroundContainerView = UIView()
	private let qrCodeImageView = UIImageView()

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
		backgroundContainerView.addSubview(qrCodeImageView)

		NSLayoutConstraint.activate(
			[
				backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0),
				backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0),
				backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30.0),
				backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30.0),

				qrCodeImageView.topAnchor.constraint(greaterThanOrEqualTo: backgroundContainerView.topAnchor, constant: 16.0),
				qrCodeImageView.bottomAnchor.constraint(greaterThanOrEqualTo: backgroundContainerView.bottomAnchor, constant: -16.0),
				qrCodeImageView.heightAnchor.constraint(equalToConstant: 280.0),
				qrCodeImageView.widthAnchor.constraint(equalToConstant: 280.0),
				qrCodeImageView.centerYAnchor.constraint(equalTo: backgroundContainerView.centerYAnchor),
				qrCodeImageView.centerXAnchor.constraint(equalTo: backgroundContainerView.centerXAnchor)
			]
		)

	}

}
