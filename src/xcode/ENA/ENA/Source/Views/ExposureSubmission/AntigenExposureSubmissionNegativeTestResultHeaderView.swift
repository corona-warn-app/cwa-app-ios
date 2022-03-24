////
// 🦠 Corona-Warn-App
//

import UIKit

class AntigenExposureSubmissionNegativeTestResultHeaderView: DynamicTableViewHeaderFooterView {
		
	// MARK: - Init
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	// swiftlint:disable:next function_body_length
	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		
		let wrapperView = UIView()
		wrapperView.backgroundColor = .enaColor(for: .separator)
		wrapperView.translatesAutoresizingMaskIntoConstraints = false
		wrapperView.layer.cornerRadius = 14
		wrapperView.layer.masksToBounds = true
		contentView.addSubview(wrapperView)
		
		imageView = UIImageView(image: UIImage(named: "Illu_Submission_NegativesTestErgebnis"))
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		wrapperView.addSubview(imageView)
		imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 90)
		
		subtitleLabel = ENALabel()
		subtitleLabel.style = .subheadline
		subtitleLabel.textColor = .enaColor(for: .textPrimary2)
		subtitleLabel.numberOfLines = 1
		subtitleLabel.adjustsFontSizeToFitWidth = true
		subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
		wrapperView.addSubview(subtitleLabel)
		
		let coronaTitleLabel = ENALabel()
		coronaTitleLabel.style = .title2
		coronaTitleLabel.textColor = .enaColor(for: .textPrimary1)
		coronaTitleLabel.text = AppStrings.ExposureSubmissionResult.card_title
		coronaTitleLabel.numberOfLines = 1
		coronaTitleLabel.adjustsFontSizeToFitWidth = true
		coronaTitleLabel.translatesAutoresizingMaskIntoConstraints = false
		wrapperView.addSubview(coronaTitleLabel)
		
		resultTitleLabel = ENALabel()
		resultTitleLabel.style = .title2
		resultTitleLabel.numberOfLines = 1
		resultTitleLabel.adjustsFontSizeToFitWidth = true
		resultTitleLabel.translatesAutoresizingMaskIntoConstraints = false
		wrapperView.addSubview(resultTitleLabel)
		
		personLabel = ENALabel()
		personLabel.style = .subheadline
		personLabel.font = .enaFont(for: .subheadline, weight: .bold)
		personLabel.textColor = .enaColor(for: .textPrimary1)
		personLabel.numberOfLines = 2
		personLabel.adjustsFontSizeToFitWidth = true
		personLabel.translatesAutoresizingMaskIntoConstraints = false
		wrapperView.addSubview(personLabel)
		
		let descriptionLabel = ENALabel()
		descriptionLabel.style = .subheadline
		descriptionLabel.textColor = .enaColor(for: .textPrimary1)
		descriptionLabel.text = AppStrings.ExposureSubmissionResult.Antigen.testNegativeDesc
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionLabel.numberOfLines = 0
		wrapperView.addSubview(descriptionLabel)
				
		lineView = UIView()
		lineView.layer.masksToBounds = true
		lineView.layer.cornerRadius = 2
		lineView.translatesAutoresizingMaskIntoConstraints = false
		wrapperView.addSubview(lineView)
		
		let separatorLineView = UIView()
		separatorLineView.backgroundColor = .enaColor(for: .hairline)
		separatorLineView.translatesAutoresizingMaskIntoConstraints = false
		wrapperView.addSubview(separatorLineView)
				
		dateLabel = ENALabel()
		dateLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
		dateLabel.textColor = .enaColor(for: .textPrimary1)
		dateLabel.numberOfLines = 0
		dateLabel.adjustsFontSizeToFitWidth = true
		dateLabel.translatesAutoresizingMaskIntoConstraints = false
		
		let regDateTitleLabel = ENALabel()
		regDateTitleLabel.style = .footnote
		regDateTitleLabel.textColor = .enaColor(for: .textPrimary1)
		regDateTitleLabel.numberOfLines = 0
		regDateTitleLabel.textAlignment = .center
		regDateTitleLabel.adjustsFontSizeToFitWidth = true
		regDateTitleLabel.text = AppStrings.ExposureSubmissionResult.Antigen.registrationDate
		regDateTitleLabel.translatesAutoresizingMaskIntoConstraints = false

		let regDateStackView = UIStackView()
		regDateStackView.translatesAutoresizingMaskIntoConstraints = false
		regDateStackView.axis = .vertical
		regDateStackView.alignment = .center
		regDateStackView.spacing = 16
		
		regDateStackView.addArrangedSubview(regDateTitleLabel)
		regDateStackView.addArrangedSubview(dateLabel)

		wrapperView.addSubview(regDateStackView)
		
		let leadingInset: CGFloat = 43
				
		NSLayoutConstraint.activate([
			// wrapperView
			wrapperView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
			wrapperView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
			wrapperView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
			wrapperView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
			// imageView
			imageView.leadingAnchor.constraint(greaterThanOrEqualTo: wrapperView.leadingAnchor, constant: leadingInset),
			imageView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -15),
			imageView.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: 20),
			imageView.bottomAnchor.constraint(lessThanOrEqualTo: wrapperView.bottomAnchor, constant: -20),
			imageWidthConstraint,
			// subtitleLabel
			subtitleLabel.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: leadingInset),
			subtitleLabel.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -6),
			subtitleLabel.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: 20),
			subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: wrapperView.bottomAnchor, constant: -20),
			// coronaTitleLabel
			coronaTitleLabel.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: leadingInset),
			coronaTitleLabel.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -6),
			coronaTitleLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 6),
			coronaTitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: wrapperView.bottomAnchor, constant: -20),
			// resultTitleLabel
			resultTitleLabel.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: leadingInset),
			resultTitleLabel.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -6),
			resultTitleLabel.topAnchor.constraint(equalTo: coronaTitleLabel.bottomAnchor, constant: 2),
			resultTitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: wrapperView.bottomAnchor, constant: -20),
			// personLabel
			personLabel.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: leadingInset),
			personLabel.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -6),
			personLabel.topAnchor.constraint(equalTo: resultTitleLabel.bottomAnchor, constant: 14),
			personLabel.bottomAnchor.constraint(lessThanOrEqualTo: wrapperView.bottomAnchor, constant: -20),
			// descriptionLabel
			descriptionLabel.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: leadingInset),
			descriptionLabel.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -6),
			descriptionLabel.topAnchor.constraint(equalTo: personLabel.bottomAnchor, constant: 8),
			descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: wrapperView.bottomAnchor, constant: -20),
			// lineView
			lineView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 15),
			lineView.trailingAnchor.constraint(lessThanOrEqualTo: wrapperView.trailingAnchor, constant: -15),
			lineView.topAnchor.constraint(equalTo: subtitleLabel.topAnchor),
			lineView.bottomAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
			lineView.widthAnchor.constraint(equalToConstant: 4),
			// separatorLineView
			separatorLineView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 15),
			separatorLineView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -15),
			separatorLineView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 15),
			separatorLineView.bottomAnchor.constraint(lessThanOrEqualTo: wrapperView.bottomAnchor, constant: -20),
			separatorLineView.heightAnchor.constraint(equalToConstant: 1),
			// registrationDateView
			regDateStackView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 15),
			regDateStackView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -15),
			regDateStackView.topAnchor.constraint(equalTo: separatorLineView.bottomAnchor, constant: 15),
			regDateStackView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -20)
		])
		
		updateIllustration(for: traitCollection)
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updateIllustration(for: traitCollection)
	}
	
	
	override func prepareForReuse() {
		super.prepareForReuse()
	}
		
	// MARK: - Internal
	
	func configure(coronaTest: UserAntigenTest) {
		lineView.backgroundColor = coronaTest.testResult.color
		imageView.image = coronaTest.testResult.image
		subtitleLabel.text = AppStrings.ExposureSubmissionResult.Antigen.card_subtitle
		// resultTitleLabel
		switch coronaTest.testResult {
		case .positive: resultTitleLabel.text = AppStrings.ExposureSubmissionResult.Antigen.card_positive
		case .negative: resultTitleLabel.text = AppStrings.ExposureSubmissionResult.Antigen.card_negative
		case .invalid: resultTitleLabel.text = AppStrings.ExposureSubmissionResult.card_invalid
		case .pending: resultTitleLabel.text = AppStrings.ExposureSubmissionResult.card_pending
		case .expired: resultTitleLabel.text = AppStrings.ExposureSubmissionResult.card_invalid
		}
		resultTitleLabel.textColor = coronaTest.testResult.color
		// personLabel
		if let name = coronaTest.testedPerson.fullName, let birthday = coronaTest.testedPerson.formattedDateOfBirth {
			personLabel.text = name + "\n" + AppStrings.ExposureSubmissionResult.Antigen.personBirthdayPrefix + " " + birthday
		} else {
			personLabel.text = nil
		}
		// dateLabel
		dateLabel.text = DateFormatter.localizedString(from: coronaTest.testDate, dateStyle: .medium, timeStyle: .short)
	}
	
	// MARK: - Private
	
	private var lineView: UIView!
	private var imageView: UIImageView!
	private var subtitleLabel: ENALabel!
	private var resultTitleLabel: ENALabel!
	private var personLabel: ENALabel!
	private var dateLabel: ENALabel!
	private var imageWidthConstraint: NSLayoutConstraint!
	private var regDateStackView: UIStackView!
	
	private func updateIllustration(for traitCollection: UITraitCollection) {
		if traitCollection.preferredContentSizeCategory >= .extraExtraExtraLarge {
			imageWidthConstraint.constant = 0
			imageView.isHidden = true
		} else {
			imageWidthConstraint.constant = 90
			imageView.isHidden = false
		}
	}
}
