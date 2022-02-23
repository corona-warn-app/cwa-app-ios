//
// 🦠 Corona-Warn-App
//

import UIKit

class ReissuanceConsentCertificateCell: UITableViewCell {

	// MARK: - Init

	override init(
		style: UITableViewCell.CellStyle, reuseIdentifier: String?
	) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	func configure(
		_ cellViewModel: HealthCertificateCellViewModel
	) {
		gradientBackground.type = cellViewModel.gradientType
		iconImageView.image = cellViewModel.image

		headlineLabel.text = cellViewModel.headline
		subHeadlineLabel.text = cellViewModel.subheadline
		detailsLabel.text = cellViewModel.detail
		setupAccessibility()
	}

	// MARK: - Private

	private let backgroundContainerView = UIView()
	private let headlineLabel = ENALabel(style: .headline)
	private let subHeadlineLabel = ENALabel(style: .body)
	private let detailsLabel = ENALabel(style: .body)
	private let gradientBackground = GradientView()
	private let iconImageView = UIImageView()

	private func setupView() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		selectionStyle = .none
		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Person.certificateCell

		backgroundContainerView.backgroundColor = .enaColor(for: .cellBackground2)
		backgroundContainerView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
		if #available(iOS 13.0, *) {
			backgroundContainerView.layer.cornerCurve = .continuous
		}
		backgroundContainerView.layer.cornerRadius = 15.0
		backgroundContainerView.layer.masksToBounds = true
		updateBorder()
		backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(backgroundContainerView)

		let vStackView = UIStackView(arrangedSubviews: [headlineLabel, subHeadlineLabel, detailsLabel])
		vStackView.axis = .vertical
		vStackView.spacing = 6

		gradientBackground.type = .solidGrey
		gradientBackground.translatesAutoresizingMaskIntoConstraints = false
		if #available(iOS 13.0, *) {
			gradientBackground.layer.cornerCurve = .continuous
		}
		gradientBackground.layer.cornerRadius = 15.0
		gradientBackground.layer.masksToBounds = true

		iconImageView.contentMode = .center
		iconImageView.translatesAutoresizingMaskIntoConstraints = false
		gradientBackground.addSubview(iconImageView)


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

				iconImageView.widthAnchor.constraint(equalTo: gradientBackground.widthAnchor),
				iconImageView.heightAnchor.constraint(equalTo: gradientBackground.heightAnchor),
				iconImageView.centerXAnchor.constraint(equalTo: gradientBackground.centerXAnchor),
				iconImageView.centerYAnchor.constraint(equalTo: gradientBackground.centerYAnchor),

				hStackView.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 16.0),
				hStackView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -24.0),
				hStackView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16.0),
				hStackView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16.0)
			]
		)
	}

	private func setupAccessibility() {
		accessibilityElements = [backgroundContainerView as Any]
		backgroundContainerView.accessibilityElements = [headlineLabel as Any, subHeadlineLabel as Any, detailsLabel as Any]
		headlineLabel.accessibilityTraits = [.staticText, .button]
	}

	private func updateBorder() {
		backgroundContainerView.layer.borderWidth = traitCollection.userInterfaceStyle == .dark ? 0 : 1
	}

}
