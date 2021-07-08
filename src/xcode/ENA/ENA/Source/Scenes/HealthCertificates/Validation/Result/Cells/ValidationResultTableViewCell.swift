////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class ValidationResultTableViewCell: UITableViewCell, ReuseIdentifierProviding {

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

		updateBorderColor()
	}

	// MARK: - Internal

	func configure(with cellModel: ValidationResultCellModel) {
		ruleDescriptionLabel.text = cellModel.ruleDescription
	}

	// MARK: - Private

	private let backgroundContainerView = UIView()

	private let ruleDescriptionLabel = ENALabel(style: .body)

	private func setupView() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		selectionStyle = .none

		backgroundContainerView.backgroundColor = .enaColor(for: .background)
		backgroundContainerView.layer.borderWidth = 1
		if #available(iOS 13.0, *) {
			backgroundContainerView.layer.cornerCurve = .continuous
		}
		backgroundContainerView.layer.cornerRadius = 15.0
		backgroundContainerView.layer.masksToBounds = true
		updateBorderColor()

		backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(backgroundContainerView)

		let contentStackView = UIStackView()
		contentStackView.axis = .horizontal
		contentStackView.spacing = 12
		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		contentStackView.alignment = .top
		backgroundContainerView.addSubview(contentStackView)

		let failureIconImageView = UIImageView(image: UIImage(named: "Icon_CertificateValidation_Failed"))
		failureIconImageView.setContentHuggingPriority(.required, for: .horizontal)
		contentStackView.addArrangedSubview(failureIconImageView)

		ruleDescriptionLabel.numberOfLines = 0
		ruleDescriptionLabel.textColor = .enaColor(for: .textPrimary1)
		ruleDescriptionLabel.text = AppStrings.HealthCertificate.Validation.Result.TechnicalFailed.certificateExpired
		contentStackView.addArrangedSubview(ruleDescriptionLabel)

		NSLayoutConstraint.activate(
			[
				backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0),
				backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0),
				backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				contentStackView.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 16.0),
				contentStackView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -16.0),
				contentStackView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16.0),
				contentStackView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16.0)
			]
		)

		accessibilityElements = [ruleDescriptionLabel]
	}

	private func updateBorderColor() {
		backgroundContainerView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
	}

}
