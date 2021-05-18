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

	// MARK: - Internal

	func configure(_ cellViewModel: HealthCertificateCellViewModel) {
		gradientBackground.type = cellViewModel.gradientType
		shieldImageView.image = cellViewModel.image
		headlineTextLabel.text = cellViewModel.headline
		detailsTextLabel.text = cellViewModel.detail
	}

	// MARK: - Private

	private let backgroundContainerView = UIView()
	private let disclosureContainerView = UIView()
	private let disclosureImageView = UIImageView()
	private let headlineTextLabel = ENALabel()
	private let detailsTextLabel = ENALabel()
	private let shieldImageView = UIImageView()
	private let gradientBackground = GradientView()

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

		headlineTextLabel.font = .enaFont(for: .headline)
		headlineTextLabel.numberOfLines = 0
		headlineTextLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

		disclosureImageView.image = UIImage(named: "Icons_Chevron_plain")
		disclosureImageView.contentMode = .scaleAspectFit
		disclosureImageView.translatesAutoresizingMaskIntoConstraints = false

		disclosureContainerView.addSubview(disclosureImageView)
		disclosureContainerView.setContentHuggingPriority(.defaultHigh, for: .horizontal)

		let headlineStackView = UIStackView(arrangedSubviews: [headlineTextLabel, disclosureContainerView])
		headlineStackView.alignment = .bottom
		headlineStackView.distribution = .fill
		headlineStackView.axis = .horizontal
		headlineStackView.spacing = 8.0

		detailsTextLabel.font = .enaFont(for: .subheadline)
		detailsTextLabel.numberOfLines = 0

		let vStackView = UIStackView(arrangedSubviews: [headlineStackView, detailsTextLabel])
		vStackView.axis = .vertical
		vStackView.spacing = 8.0

		gradientBackground.type = .solidGrey
		gradientBackground.translatesAutoresizingMaskIntoConstraints = false
		if #available(iOS 13.0, *) {
			gradientBackground.layer.cornerCurve = .continuous
		}
		gradientBackground.layer.cornerRadius = 15.0
		gradientBackground.layer.masksToBounds = true

		shieldImageView.contentMode = .center
		shieldImageView.translatesAutoresizingMaskIntoConstraints = false
		gradientBackground.addSubview(shieldImageView)

		let hStackView = UIStackView(arrangedSubviews: [gradientBackground, vStackView])
		hStackView.translatesAutoresizingMaskIntoConstraints = false
		hStackView.axis = .horizontal
		hStackView.spacing = 16.0
		hStackView.distribution = .fillProportionally
		hStackView.alignment = .top
		backgroundContainerView.addSubview(hStackView)

		NSLayoutConstraint.activate(
			[
				backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0),
				backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0),
				backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				gradientBackground.widthAnchor.constraint(equalToConstant: 96.0),
				gradientBackground.heightAnchor.constraint(equalToConstant: 96.0),

				shieldImageView.widthAnchor.constraint(equalTo: gradientBackground.widthAnchor),
				shieldImageView.heightAnchor.constraint(equalTo: gradientBackground.heightAnchor),
				shieldImageView.centerXAnchor.constraint(equalTo: gradientBackground.centerXAnchor),
				shieldImageView.centerYAnchor.constraint(equalTo: gradientBackground.centerYAnchor),

				hStackView.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 16.0),
				hStackView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -24.0),
				hStackView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16.0),
				hStackView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16.0),

				disclosureContainerView.leadingAnchor.constraint(equalTo: disclosureImageView.leadingAnchor),
				disclosureContainerView.trailingAnchor.constraint(equalTo: disclosureImageView.trailingAnchor),

				disclosureImageView.bottomAnchor.constraint(equalTo: headlineTextLabel.firstBaselineAnchor),
				disclosureImageView.widthAnchor.constraint(equalToConstant: 7)
			]
		)
	}

}
