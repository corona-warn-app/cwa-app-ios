////
// 🦠 Corona-Warn-App
//

import UIKit

class MissingRightsTableViewCell: UITableViewCell, ConfigureAbleCell {

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
		let qrCodeImageView = UIImageView(image: UIImage(imageLiteralResourceName: "Icons_iOS_Einstellungen"))
		qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
		qrCodeImageView.contentMode = .right

		let headline = ENALabel(frame: .zero)
		headline.translatesAutoresizingMaskIntoConstraints = false
		headline.font = .enaFont(for: .title2)
		headline.textColor = .enaColor(for: .textPrimary1)
		headline.textAlignment = .left
		headline.numberOfLines = 0
		headline.text = "Benutzung der Kamera erlauben"

		let hStackView = UIStackView(arrangedSubviews: [headline, qrCodeImageView])
		hStackView.translatesAutoresizingMaskIntoConstraints = false
		hStackView.axis = .horizontal
		hStackView.alignment = .center
		hStackView.distribution = .fill
		hStackView.spacing = 4.0

		let textLabel = ENALabel(frame: .zero)
		textLabel.translatesAutoresizingMaskIntoConstraints = false
		textLabel.font = .enaFont(for: .body)
		textLabel.textColor = .enaColor(for: .textPrimary1)
		textLabel.textAlignment = .left
		textLabel.numberOfLines = 0
		textLabel.text = "Lorem ipsum muss separat in den Geräte Einstellungen..."

		let vStackView = UIStackView(arrangedSubviews: [hStackView, textLabel])
		vStackView.translatesAutoresizingMaskIntoConstraints = false
		vStackView.axis = .vertical
		vStackView.distribution = .fill
		vStackView.spacing = 14.0

		let backgroundView = UIView(frame: .zero)
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		backgroundView.backgroundColor = .enaColor(for: .cellBackground)
		backgroundView.layer.cornerRadius = 8.0

		contentView.addSubview(backgroundView)
		backgroundView.addSubview(vStackView)

		NSLayoutConstraint.activate(
			[
				qrCodeImageView.widthAnchor.constraint(equalToConstant: 28.0),
				backgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15.0),
				backgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15.0),
				backgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
				backgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

				vStackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16.0),
				vStackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16.0),
				vStackView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 14.0),
				vStackView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -14.0)

			]
		)

	}

}
