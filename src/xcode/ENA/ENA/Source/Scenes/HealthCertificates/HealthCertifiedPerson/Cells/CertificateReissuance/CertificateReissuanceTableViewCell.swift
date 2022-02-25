////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class CertificateReissuanceTableViewCell: UITableViewCell, ReuseIdentifierProviding {

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

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateBorderWidth()
	}

	// MARK: - Internal

	func configure(with cellModel: CertificateReissuanceCellModel) {
		titleLabel.text = cellModel.title
		titleLabel.isHidden = (cellModel.title ?? "").isEmpty

		subtitleLabel.text = cellModel.subtitle
		subtitleLabel.isHidden = (cellModel.subtitle ?? "").isEmpty

		unseenNewsIndicator.isHidden = !cellModel.isUnseenNewsIndicatorVisible
	}

	// MARK: - Private

	private let backgroundContainerView: UIView = {
		let backgroundContainerView = UIView()
		backgroundContainerView.backgroundColor = .enaColor(for: .cellBackground2)
		backgroundContainerView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
		if #available(iOS 13.0, *) {
			backgroundContainerView.layer.cornerCurve = .continuous
		}
		backgroundContainerView.layer.cornerRadius = 15.0
		backgroundContainerView.layer.masksToBounds = true

		return backgroundContainerView
	}()

	private let disclosureContainerView: UIView = {
		let disclosureContainerView = UIView()
		disclosureContainerView.setContentHuggingPriority(.defaultHigh, for: .horizontal)

		return disclosureContainerView
	}()

	private let disclosureImageView: UIImageView = {
		let disclosureImageView = UIImageView()
		disclosureImageView.image = UIImage(named: "Icons_Chevron_plain")
		disclosureImageView.contentMode = .scaleAspectFit
		disclosureImageView.translatesAutoresizingMaskIntoConstraints = false

		return disclosureImageView
	}()

	private let contentStackView: UIStackView = {
		let contentStackView = UIStackView()
		contentStackView.axis = .vertical
		contentStackView.alignment = .fill
		contentStackView.spacing = 6

		return contentStackView
	}()

	private let titleStackView: UIStackView = {
		let titleStackView = UIStackView()
		titleStackView.axis = .horizontal
		titleStackView.distribution = .fill
		titleStackView.alignment = .center
		titleStackView.spacing = 6

		return titleStackView
	}()

	private let titleLabel: ENALabel = {
		let titleLabel = ENALabel(style: .headline)
		titleLabel.numberOfLines = 0
		titleLabel.textColor = .enaColor(for: .textPrimary1)
		titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

		return titleLabel
	}()

	private let unseenNewsIndicator: UIView = {
		let unseenNewsIndicator = UIView()
		unseenNewsIndicator.backgroundColor = .systemRed
		unseenNewsIndicator.layer.cornerRadius = 5.5

		return unseenNewsIndicator
	}()

	private let subtitleLabel: ENALabel = {
		let subtitleLabel = ENALabel(style: .body)
		subtitleLabel.numberOfLines = 0
		subtitleLabel.textColor = .enaColor(for: .textPrimary2)

		return subtitleLabel
	}()

	private func setupView() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		selectionStyle = .none

		accessibilityIdentifier = AccessibilityIdentifiers.BoosterNotification.Details.boosterNotificationCell

		updateBorderWidth()

		backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(backgroundContainerView)

		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		backgroundContainerView.addSubview(contentStackView)

		disclosureContainerView.addSubview(disclosureImageView)

		titleStackView.addArrangedSubview(titleLabel)
		titleStackView.addArrangedSubview(unseenNewsIndicator)
		titleStackView.addArrangedSubview(UIView())
		titleStackView.addArrangedSubview(disclosureContainerView)

		contentStackView.addArrangedSubview(titleStackView)
		contentStackView.setCustomSpacing(0, after: titleStackView)
		contentStackView.addArrangedSubview(subtitleLabel)

		NSLayoutConstraint.activate(
			[
				backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0),
				backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0),
				backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				contentStackView.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 16.0),
				contentStackView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -16.0),
				contentStackView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16.0),
				contentStackView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16.0),

				unseenNewsIndicator.widthAnchor.constraint(equalToConstant: 11),
				unseenNewsIndicator.heightAnchor.constraint(equalToConstant: 11),

				disclosureContainerView.leadingAnchor.constraint(equalTo: disclosureImageView.leadingAnchor),
				disclosureContainerView.trailingAnchor.constraint(equalTo: disclosureImageView.trailingAnchor),

				disclosureImageView.bottomAnchor.constraint(equalTo: titleLabel.firstBaselineAnchor),
				disclosureImageView.widthAnchor.constraint(equalToConstant: 7)
			]
		)
	}

	private func updateBorderWidth() {
		backgroundContainerView.layer.borderWidth = traitCollection.userInterfaceStyle == .dark ? 0 : 1
	}

}
