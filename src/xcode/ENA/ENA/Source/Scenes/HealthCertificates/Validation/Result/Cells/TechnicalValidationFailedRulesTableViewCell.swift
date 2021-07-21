//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TechnicalValidationFailedRulesTableViewCell: UITableViewCell, ReuseIdentifierProviding {

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
	
	func customize(text: String, expirationDate: Date?) {
		failureDescriptionLabel.text = text
		if let expirationDate = expirationDate {
			expirationDateTitleLabel.isHidden = false
			let dateString = DateFormatter.localizedString(from: expirationDate, dateStyle: .short, timeStyle: .short)
			expirationDateLabel.text = String(format: AppStrings.HealthCertificate.Validation.Result.TechnicalFailed.expirationDate, dateString)
			expirationDateLabel.isHidden = false
		} else {
			expirationDateTitleLabel.isHidden = true
			expirationDateLabel.text = nil
			expirationDateLabel.isHidden = true
		}
	}
	
	// MARK: - Private

	private let backgroundContainerView = UIView()
	private let failureDescriptionLabel = StackViewLabel()
	private let expirationDateTitleLabel = StackViewLabel()
	private let expirationDateLabel = StackViewLabel()

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

		let failureIconImageView = UIImageView(image: UIImage(named: "Icon_CertificateValidation_Failed"))
		failureIconImageView.setContentHuggingPriority(.required, for: .horizontal)
		failureIconImageView.translatesAutoresizingMaskIntoConstraints = false
		backgroundContainerView.addSubview(failureIconImageView)
		
		let labelsStackView = UIStackView()
		labelsStackView.axis = .vertical
		labelsStackView.spacing = 4
		labelsStackView.translatesAutoresizingMaskIntoConstraints = false
		labelsStackView.alignment = .leading
		backgroundContainerView.addSubview(labelsStackView)
		
		failureDescriptionLabel.style = .body
		failureDescriptionLabel.numberOfLines = 0
		failureDescriptionLabel.textColor = .enaColor(for: .textPrimary1)
		labelsStackView.addArrangedSubview(failureDescriptionLabel)
		
		labelsStackView.setCustomSpacing(12, after: failureDescriptionLabel)
		
		expirationDateTitleLabel.style = .footnote
		expirationDateTitleLabel.numberOfLines = 1
		expirationDateTitleLabel.textColor = .enaColor(for: .textPrimary2)
		expirationDateTitleLabel.text = AppStrings.HealthCertificate.Validation.Result.TechnicalFailed.expirationDateTitle
		labelsStackView.addArrangedSubview(expirationDateTitleLabel)
		
		expirationDateLabel.style = .subheadline
		expirationDateLabel.numberOfLines = 1
		expirationDateLabel.textColor = .enaColor(for: .textPrimary1)
		labelsStackView.addArrangedSubview(expirationDateLabel)

		NSLayoutConstraint.activate(
			[
				backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0),
				backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0),
				backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				failureIconImageView.topAnchor.constraint(greaterThanOrEqualTo: backgroundContainerView.topAnchor, constant: 16.0),
				failureIconImageView.bottomAnchor.constraint(lessThanOrEqualTo: backgroundContainerView.bottomAnchor, constant: -16.0),
				failureIconImageView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16.0),
				failureIconImageView.trailingAnchor.constraint(lessThanOrEqualTo: backgroundContainerView.trailingAnchor, constant: -16.0),
				failureIconImageView.centerYAnchor.constraint(equalTo: backgroundContainerView.centerYAnchor),
				
				labelsStackView.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 16.0),
				labelsStackView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -16.0),
				labelsStackView.leadingAnchor.constraint(equalTo: failureIconImageView.trailingAnchor, constant: 12.0),
				labelsStackView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16.0)
			]
		)

		accessibilityElements = [failureDescriptionLabel]
	}

	private func updateBorderColor() {
		backgroundContainerView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
	}

}
