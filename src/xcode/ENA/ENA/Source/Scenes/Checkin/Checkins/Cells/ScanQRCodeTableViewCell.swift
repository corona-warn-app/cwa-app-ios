////
// 🦠 Corona-Warn-App
//

import UIKit

class ScanQRCodeTableViewCell: UITableViewCell, ConfigureAbleCell {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	// MARK: - Protocol ConfigureAbleCell

	func configure<T>(cellViewModel: T) {

	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private func setupView() {
		let qrCodeImageView = UIImageView(image: UIImage(imageLiteralResourceName: "Icons_qrScan"))
		qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
		qrCodeImageView.contentMode = .center

		let label = UILabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .enaFont(for: .headline)
		label.textColor = .enaColor(for: .textPrimary1)
		label.textAlignment = .left
		label.text = "QR-Code scannen"

		let stackView = UIStackView(arrangedSubviews: [qrCodeImageView, label])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.distribution = .fillProportionally
		stackView.spacing = 20.0

		let backgroundView = UIView(frame: .zero)
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.backgroundColor = .enaColor(for: .cellBackground)
		backgroundView.layer.cornerRadius = 8.0

		contentView.addSubview(backgroundView)
		backgroundView.addSubview(stackView)

		NSLayoutConstraint.activate(
			[
				backgroundView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
				backgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15.0),
				backgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15.0),
				backgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
				backgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

				stackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 21.0),
				stackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
				stackView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
				stackView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor)

			]
		)

	}

}
