//
// 🦠 Corona-Warn-App
//

import UIKit

class ExposureSubmissionTestResultHeaderView: DynamicTableViewHeaderFooterView {
			
	// MARK: Attributes.

	@IBOutlet var barView: UIView!

	@IBOutlet var stackView: UIStackView!
	@IBOutlet var subTitleLabel: ENALabel!
	@IBOutlet var titleLabel: ENALabel!
	@IBOutlet var timeLabel: ENALabel!

	@IBOutlet var imageView: UIImageView!

	override func awakeFromNib() {
		super.awakeFromNib()
		updateIllustration(for: traitCollection)
	}

	// MARK: - DynamicTableViewHeaderFooterView methods.

	func configure<T: Test>(coronaTest: T, timeStamp: Int64?) {
		
		subTitleLabel.text = AppStrings.ExposureSubmissionResult.PCR.card_subtitle
		barView.backgroundColor = coronaTest.testResult.color
		imageView.image = coronaTest.testResult.image
		
		switch coronaTest.testResult {
		case .positive: titleLabel.text = "\(AppStrings.ExposureSubmissionResult.card_title)\n\(AppStrings.ExposureSubmissionResult.PCR.card_positive)"
		case .negative: titleLabel.text = "\(AppStrings.ExposureSubmissionResult.card_title)\n\(AppStrings.ExposureSubmissionResult.PCR.card_negative)"
		case .invalid: titleLabel.text = AppStrings.ExposureSubmissionResult.card_invalid
		case .pending: titleLabel.text = AppStrings.ExposureSubmissionResult.card_pending
		case .expired: titleLabel.text = AppStrings.ExposureSubmissionResult.card_invalid
		}

		if let timeStamp = timeStamp {
			let formatter = DateFormatter()
			formatter.dateStyle = .medium
			formatter.timeStyle = .none
			let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
			timeLabel.text = "\(AppStrings.ExposureSubmissionResult.PCR.registrationDate) \(formatter.string(from: date))"
		} else {
			timeLabel.text = "\(AppStrings.ExposureSubmissionResult.registrationDateUnknown)"
		}
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updateIllustration(for: traitCollection)
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
	}

	private func updateIllustration(for traitCollection: UITraitCollection) {
		if traitCollection.preferredContentSizeCategory >= .extraExtraExtraLarge {
			imageView.isHidden = true
		} else {
			imageView.isHidden = false
		}
	}
}

class AntigenExposureSubmissionTestResultHeaderView: DynamicTableViewHeaderFooterView {
		
	private var lineView: UIView!
	private var imageView: UIImageView!
	private var subtitleLabel: ENALabel!
	private var resultTitleLabel: ENALabel!
	private var personLabel: ENALabel!
	private var dateLabel: ENALabel!
	private var counterView: TestResultCounterView!
	
	private var imageWidthConstraint: NSLayoutConstraint!
	
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
		
		dateLabel = ENALabel()
		dateLabel.style = .subheadline
		dateLabel.textColor = .enaColor(for: .textPrimary2)
		dateLabel.numberOfLines = 1
		dateLabel.adjustsFontSizeToFitWidth = true
		dateLabel.translatesAutoresizingMaskIntoConstraints = false
		wrapperView.addSubview(dateLabel)
		
		lineView = UIView()
		lineView.layer.masksToBounds = true
		lineView.layer.cornerRadius = 2
		lineView.translatesAutoresizingMaskIntoConstraints = false
		wrapperView.addSubview(lineView)
		
		let separatorLineView = UIView()
		separatorLineView.backgroundColor = .enaColor(for: .hairline)
		separatorLineView.translatesAutoresizingMaskIntoConstraints = false
		wrapperView.addSubview(separatorLineView)
		
		counterView = TestResultCounterView()
		wrapperView.addSubview(counterView)
		
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
			// dateLabel
			dateLabel.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: leadingInset),
			dateLabel.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -6),
			dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
			dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: wrapperView.bottomAnchor, constant: -20),
			// lineView
			lineView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 15),
			lineView.trailingAnchor.constraint(lessThanOrEqualTo: wrapperView.trailingAnchor, constant: -15),
			lineView.topAnchor.constraint(equalTo: subtitleLabel.topAnchor),
			lineView.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor),
			lineView.widthAnchor.constraint(equalToConstant: 4),
			// separatorLineView
			separatorLineView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 15),
			separatorLineView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -15),
			separatorLineView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 15),
			separatorLineView.bottomAnchor.constraint(lessThanOrEqualTo: wrapperView.bottomAnchor, constant: -20),
			separatorLineView.heightAnchor.constraint(equalToConstant: 1),
			// counterView
			counterView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 15),
			counterView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -15),
			counterView.topAnchor.constraint(equalTo: separatorLineView.bottomAnchor, constant: 15),
			counterView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -20)
		])
		
		updateIllustration(for: traitCollection)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updateIllustration(for: traitCollection)
	}
	
	private func updateIllustration(for traitCollection: UITraitCollection) {
		if traitCollection.preferredContentSizeCategory >= .extraExtraExtraLarge {
			imageWidthConstraint.constant = 0
			imageView.isHidden = true
		} else {
			imageWidthConstraint.constant = 90
			imageView.isHidden = false
		}
	}
	
	func configure(coronaTest: AntigenTest, timeStamp: Int64?) {
		
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
		if let name = coronaTest.testedPerson.name, let birthday = coronaTest.testedPerson.birthday {
			personLabel.text = name + "\n" + AppStrings.ExposureSubmissionResult.Antigen.personBirthdayPrefix + " " + birthday
		} else if let name = coronaTest.testedPerson.name {
			personLabel.text = name
		} else if let birthday = coronaTest.testedPerson.birthday {
			personLabel.text = AppStrings.ExposureSubmissionResult.Antigen.personBirthdayPrefix + " " + birthday
		} else {
			personLabel.text = nil
		}
		// dateLabel
		if let timeStamp = timeStamp {
			let formatter = DateFormatter()
			formatter.dateStyle = .medium
			formatter.timeStyle = .short
			let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
			dateLabel.text = "\(AppStrings.ExposureSubmissionResult.Antigen.registrationDate) \(formatter.string(from: date)) \(AppStrings.ExposureSubmissionResult.Antigen.registrationDateSuffix)"
		} else {
			dateLabel.text = "\(AppStrings.ExposureSubmissionResult.registrationDateUnknown)"
		}
	}
}

class TestResultCounterView: UIView {
	
	convenience init() {
		self.init(frame: .zero)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		// self
		translatesAutoresizingMaskIntoConstraints = false
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	var beginDate: Date? {
		didSet {
			
		}
	}
}

private extension TestResult {
	
	var color: UIColor {
		switch self {
		case .positive: return .enaColor(for: .riskHigh)
		case .negative: return .enaColor(for: .riskLow)
		case .invalid, .expired: return .enaColor(for: .riskNeutral)
		case .pending: return .enaColor(for: .riskNeutral)
		}
	}

	var image: UIImage? {
		switch self {
		case .positive: return UIImage(named: "Illu_Submission_PositivTestErgebnis")
		case .negative: return UIImage(named: "Illu_Submission_NegativesTestErgebnis")
		case .invalid, .expired: return UIImage(named: "Illu_Submission_FehlerhaftesTestErgebnis")
		case .pending: return UIImage(named: "Illu_Submission_PendingTestErgebnis")
		}
	}
}
