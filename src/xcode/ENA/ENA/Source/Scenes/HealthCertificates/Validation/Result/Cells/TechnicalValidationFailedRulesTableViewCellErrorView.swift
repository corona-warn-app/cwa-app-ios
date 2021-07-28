////
// 🦠 Corona-Warn-App
//

import UIKit

class TechnicalValidationFailedRulesTableViewCellErrorView: UIView {
	
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
		expirationDateTitleLabel.numberOfLines = 0
		expirationDateTitleLabel.textColor = .enaColor(for: .textPrimary2)
		expirationDateTitleLabel.text = AppStrings.HealthCertificate.Validation.Result.TechnicalFailed.expirationDateTitle
		labelsStackView.addArrangedSubview(expirationDateTitleLabel)
		
		let expirationDateLabel = StackViewLabel()
		expirationDateLabel.style = .subheadline
		expirationDateLabel.numberOfLines = 0
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
				failureIconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 22.0),
				failureIconImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16.0),
				failureIconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
				failureIconImageView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16.0),
				
				labelsStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16.0),
				labelsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.0),
				labelsStackView.leadingAnchor.constraint(equalTo: failureIconImageView.trailingAnchor, constant: 12.0),
				labelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0)
			]
		)
		
		accessibilityElements = [failureDescriptionLabel, expirationDateTitleLabel, expirationDateLabel].filter { !$0.isHidden }
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
