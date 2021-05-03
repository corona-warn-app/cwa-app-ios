////
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	func configure(_ cellViewModel: HealthCertificateCellViewModel) {
		// view model should provide all this data
		shieldImageView.backgroundColor = UIColor(red: 0.38, green: 0.435, blue: 0.494, alpha: 1)
		shieldImageView.image = UIImage(imageLiteralResourceName: "Icon - Teilschild")
		headlineTextLabel.text = "Impfung 1 von 2"
		detailsTextLabel.text = "durchgeführt am 12.04.2021"
	}

	// MARK: - Private

	private let backgroundContainerView = UIView()
	private let headlineTextLabel = ENALabel()
	private let detailsTextLabel = ENALabel()
	private let shieldImageView = UIImageView()

	private func setupView() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		selectionStyle = .none

		backgroundContainerView.backgroundColor = .enaColor(for: .background)
		backgroundContainerView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor

		if #available(iOS 13.0, *) {
			backgroundContainerView.layer.cornerCurve = .continuous
		}
		backgroundContainerView.layer.cornerRadius = 15.0
		backgroundContainerView.layer.masksToBounds = true
		backgroundContainerView.layer.borderWidth = 1.0

		backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(backgroundContainerView)

		headlineTextLabel.translatesAutoresizingMaskIntoConstraints = false
		headlineTextLabel.numberOfLines = 0

		detailsTextLabel.translatesAutoresizingMaskIntoConstraints = false
		detailsTextLabel.numberOfLines = 0

		let vStackView = UIStackView(arrangedSubviews: [headlineTextLabel, detailsTextLabel])
		vStackView.translatesAutoresizingMaskIntoConstraints = false
		vStackView.axis = .vertical
		vStackView.spacing = 8.0

		shieldImageView.contentMode = .center
		if #available(iOS 13.0, *) {
			shieldImageView.layer.cornerCurve = .continuous
		}
		shieldImageView.layer.cornerRadius = 15.0
		shieldImageView.layer.masksToBounds = true

		let hStackView = UIStackView(arrangedSubviews: [shieldImageView, vStackView])
		hStackView.translatesAutoresizingMaskIntoConstraints = false
		hStackView.axis = .horizontal
		hStackView.spacing = 16.0
		hStackView.distribution = .fillProportionally
		backgroundContainerView.addSubview(hStackView)

		NSLayoutConstraint.activate(
			[
				backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
				backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0),
				backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30.0),
				backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30.0),

				shieldImageView.widthAnchor.constraint(equalToConstant: 96.0),
				shieldImageView.heightAnchor.constraint(equalToConstant: 96.0),

				hStackView.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 16.0),
				hStackView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -24.0),
				hStackView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 14.0),
				hStackView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -14.0)
			]
		)
	}

}
