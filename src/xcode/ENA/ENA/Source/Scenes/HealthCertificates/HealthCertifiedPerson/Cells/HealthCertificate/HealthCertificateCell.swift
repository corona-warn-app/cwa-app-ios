////
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
		setupAccessibility()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateBorder()
	}

	// MARK: - Internal
	
	func configure(
		_ cellViewModel: HealthCertificateCellViewModel,
		withDisclosureIndicator: Bool = true
	) {
		gradientBackground.type = cellViewModel.gradientType
		iconImageView.image = cellViewModel.image

		headlineLabel.text = cellViewModel.headline
		subheadlineLabel.text = cellViewModel.subheadline
		detailsLabel.text = cellViewModel.detail

		validityStateInfoLabel.text = cellViewModel.validityStateInfo
		validityStateInfoLabel.isHidden = cellViewModel.validityStateInfo == nil

		currentlyUsedStackView.isHidden = !cellViewModel.isCurrentlyUsedCertificateHintVisible
		unseenNewsIndicator.isHidden = !cellViewModel.isUnseenNewsIndicatorVisible
	
		disclosureImageView.isHidden = !withDisclosureIndicator

		setupAccessibility()
	}

	// MARK: - Private

	private let backgroundContainerView = UIView()
	private let disclosureContainerView = UIView()
	private let disclosureImageView = UIImageView()

	private let headlineLabel = ENALabel(style: .headline)
	private let subheadlineLabel = ENALabel(style: .body)
	private let detailsLabel = ENALabel(style: .body)
	private let validityStateInfoLabel = ENALabel(style: .body)

	private let currentlyUsedStackView = UIStackView()
	private let currentlyUsedImageView = UIImageView()
	private let currentlyUsedLabel = ENALabel()
	private let iconImageView = UIImageView()
	private let unseenNewsIndicator = CertificateBadgeView()
	private let gradientBackground = GradientView()

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

		headlineLabel.numberOfLines = 0
		headlineLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

		disclosureImageView.image = UIImage(named: "Icons_Chevron_plain")
		disclosureImageView.contentMode = .scaleAspectFit
		disclosureImageView.translatesAutoresizingMaskIntoConstraints = false

		disclosureContainerView.addSubview(disclosureImageView)
		disclosureContainerView.setContentHuggingPriority(.defaultHigh, for: .horizontal)

		let headlineStackView = UIStackView(arrangedSubviews: [headlineLabel, disclosureContainerView])
		headlineStackView.alignment = .bottom
		headlineStackView.distribution = .fill
		headlineStackView.axis = .horizontal
		headlineStackView.spacing = 8

		subheadlineLabel.textColor = .enaColor(for: .textPrimary2)
		subheadlineLabel.numberOfLines = 0

		detailsLabel.textColor = .enaColor(for: .textPrimary2)
		detailsLabel.numberOfLines = 0

		let subheadlineDetailsStackView = UIStackView(arrangedSubviews: [subheadlineLabel, detailsLabel])
		subheadlineDetailsStackView.axis = .vertical
		subheadlineDetailsStackView.spacing = 0

		validityStateInfoLabel.textColor = .enaColor(for: .textPrimary1)
		validityStateInfoLabel.numberOfLines = 0

		currentlyUsedImageView.image = UIImage(named: "CurrentlyUsedCertificate_Icon")
		currentlyUsedImageView.contentMode = .scaleAspectFit
		currentlyUsedImageView.setContentHuggingPriority(.required, for: .horizontal)
		currentlyUsedStackView.addArrangedSubview(currentlyUsedImageView)

		currentlyUsedLabel.style = .body
		currentlyUsedLabel.textColor = .enaColor(for: .textPrimary2)
		currentlyUsedLabel.numberOfLines = 0
		currentlyUsedLabel.text = AppStrings.HealthCertificate.Person.currentlyUsedCertificate
		currentlyUsedStackView.addArrangedSubview(currentlyUsedLabel)

		currentlyUsedStackView.axis = .horizontal
		currentlyUsedStackView.alignment = .top
		currentlyUsedStackView.spacing = 6

		let vStackView = UIStackView(arrangedSubviews: [headlineStackView, subheadlineDetailsStackView, validityStateInfoLabel, currentlyUsedStackView])
		vStackView.axis = .vertical
		vStackView.spacing = 6

		gradientBackground.type = .solidGrey(withStars: false)
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

		unseenNewsIndicator.backgroundColor = .systemRed
		unseenNewsIndicator.translatesAutoresizingMaskIntoConstraints = false
		backgroundContainerView.insertSubview(unseenNewsIndicator, aboveSubview: gradientBackground)

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

				unseenNewsIndicator.widthAnchor.constraint(equalToConstant: 15),
				unseenNewsIndicator.heightAnchor.constraint(equalToConstant: 15),
				unseenNewsIndicator.centerXAnchor.constraint(equalTo: gradientBackground.trailingAnchor, constant: -4),
				unseenNewsIndicator.centerYAnchor.constraint(equalTo: gradientBackground.topAnchor, constant: 4),

				hStackView.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 16.0),
				hStackView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -24.0),
				hStackView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16.0),
				hStackView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16.0),

				disclosureContainerView.leadingAnchor.constraint(equalTo: disclosureImageView.leadingAnchor),
				disclosureContainerView.trailingAnchor.constraint(equalTo: disclosureImageView.trailingAnchor),

				disclosureImageView.bottomAnchor.constraint(equalTo: headlineLabel.firstBaselineAnchor),
				disclosureImageView.widthAnchor.constraint(equalToConstant: 7)
			]
		)
	}

	private func setupAccessibility() {
		accessibilityElements = [backgroundContainerView as Any]

		backgroundContainerView.accessibilityElements = [headlineLabel as Any, subheadlineLabel as Any, detailsLabel as Any]

		if currentlyUsedStackView.isHidden {
			backgroundContainerView.accessibilityElements = [headlineLabel as Any, subheadlineLabel as Any, detailsLabel as Any]
		} else {
			backgroundContainerView.accessibilityElements = [headlineLabel as Any, subheadlineLabel as Any, detailsLabel as Any, currentlyUsedLabel as Any]
		}

		headlineLabel.accessibilityTraits = [.staticText, .button]
	}

	private func updateBorder() {
		backgroundContainerView.layer.borderWidth = traitCollection.userInterfaceStyle == .dark ? 0 : 1
	}

}
