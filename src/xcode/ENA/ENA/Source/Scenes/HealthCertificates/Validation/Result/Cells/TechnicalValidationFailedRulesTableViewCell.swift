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
	
	override func prepareForReuse() {
		super.prepareForReuse()
		clearErrorViews()
	}

	// MARK: - Internal
	
	func customize(signatureInvalid: Bool, expirationDate: Date?) {
		
		clearErrorViews()
		
		errorViewsStackView.addArrangedSubview(TechnicalValidationFailedRulesTableViewCellErrorView(text: AppStrings.HealthCertificate.Validation.Result.TechnicalFailed.notValidDateFormat, expirationDate: nil))
		
		if signatureInvalid {
			addErrorViewSeparator()
			errorViewsStackView.addArrangedSubview(TechnicalValidationFailedRulesTableViewCellErrorView(text: AppStrings.HealthCertificate.Validation.Result.TechnicalFailed.certificateNotValid, expirationDate: nil))
		}
		
		if let expirationDate = expirationDate {
			addErrorViewSeparator()
			errorViewsStackView.addArrangedSubview(TechnicalValidationFailedRulesTableViewCellErrorView(text: AppStrings.HealthCertificate.Validation.Result.TechnicalFailed.technicalExpirationDatePassed, expirationDate: expirationDate))
		}
	}
	
	// MARK: - Private

	private let backgroundContainerView = UIView()
	private let errorViewsStackView = UIStackView()

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
		
		errorViewsStackView.axis = .vertical
		errorViewsStackView.spacing = 0
		errorViewsStackView.translatesAutoresizingMaskIntoConstraints = false
		errorViewsStackView.alignment = .leading
		backgroundContainerView.addSubview(errorViewsStackView)

		NSLayoutConstraint.activate(
			[
				backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0),
				backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0),
				backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				errorViewsStackView.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor),
				errorViewsStackView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor),
				errorViewsStackView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor),
				errorViewsStackView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor)
			]
		)
	}

	private func updateBorderColor() {
		backgroundContainerView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
	}

	private func clearErrorViews() {
		errorViewsStackView.arrangedSubviews.forEach { errorViewsStackView.removeArrangedSubview($0); $0.removeFromSuperview() }
	}
	
	private func addErrorViewSeparator() {
		let separator = UIView()
		separator.translatesAutoresizingMaskIntoConstraints = false
		separator.backgroundColor = .enaColor(for: .hairline)
		errorViewsStackView.addArrangedSubview(separator)
		separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
		separator.widthAnchor.constraint(equalTo: errorViewsStackView.widthAnchor).isActive = true
	}
}

private class TechnicalValidationFailedRulesTableViewCellErrorView: UIView {
	
	// MARK: - Init
	
	init(text: String, expirationDate: Date?) {
		
		super.init(frame: .zero)
		
		let failureIconImageView = UIImageView(image: UIImage(named: "Icon_CertificateValidation_Failed"))
		failureIconImageView.setContentHuggingPriority(.required, for: .horizontal)
		failureIconImageView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(failureIconImageView)
		
		let labelsStackView = UIStackView()
		labelsStackView.axis = .vertical
		labelsStackView.spacing = 4
		labelsStackView.translatesAutoresizingMaskIntoConstraints = false
		labelsStackView.alignment = .leading
		addSubview(labelsStackView)
		
		let failureDescriptionLabel = StackViewLabel()
		failureDescriptionLabel.style = .body
		failureDescriptionLabel.numberOfLines = 0
		failureDescriptionLabel.textColor = .enaColor(for: .textPrimary1)
		failureDescriptionLabel.text = text
		labelsStackView.addArrangedSubview(failureDescriptionLabel)
		
		labelsStackView.setCustomSpacing(12, after: failureDescriptionLabel)
		
		let expirationDateTitleLabel = StackViewLabel()
		expirationDateTitleLabel.style = .footnote
		expirationDateTitleLabel.numberOfLines = 1
		expirationDateTitleLabel.textColor = .enaColor(for: .textPrimary2)
		expirationDateTitleLabel.text = AppStrings.HealthCertificate.Validation.Result.TechnicalFailed.expirationDateTitle
		labelsStackView.addArrangedSubview(expirationDateTitleLabel)
		
		let expirationDateLabel = StackViewLabel()
		expirationDateLabel.style = .subheadline
		expirationDateLabel.numberOfLines = 1
		expirationDateLabel.textColor = .enaColor(for: .textPrimary1)
		labelsStackView.addArrangedSubview(expirationDateLabel)
		
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
		
		NSLayoutConstraint.activate(
			[
				failureIconImageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 16.0),
				failureIconImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16.0),
				failureIconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
				failureIconImageView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16.0),
				failureIconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
				
				labelsStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16.0),
				labelsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.0),
				labelsStackView.leadingAnchor.constraint(equalTo: failureIconImageView.trailingAnchor, constant: 12.0),
				labelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0)
			]
		)
		
		accessibilityElements = [failureDescriptionLabel]
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
