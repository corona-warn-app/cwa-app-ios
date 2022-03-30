//
// 🦠 Corona-Warn-App
//

import UIKit

class ExposureSubmissionTestResultHeaderView: DynamicTableViewHeaderFooterView {
			
	// MARK: Attributes.

	@IBOutlet private var barView: UIView!
	@IBOutlet private var subTitleLabel: ENALabel!
	@IBOutlet private var titleLabel: ENALabel!
	@IBOutlet private var timeLabel: ENALabel!
	@IBOutlet private var imageView: UIImageView!

	override func awakeFromNib() {
		super.awakeFromNib()
		updateIllustration(for: traitCollection)
	}

	// MARK: - DynamicTableViewHeaderFooterView methods.

	func configure(coronaTest: UserCoronaTest) {
		barView.backgroundColor = coronaTest.testResult.color
		imageView.image = coronaTest.testResult.image

		let formattedTestDate = DateFormatter.localizedString(from: coronaTest.testDate, dateStyle: .medium, timeStyle: .none)
		
		switch coronaTest.type {
		case .pcr:
			subTitleLabel.text = AppStrings.ExposureSubmissionResult.PCR.card_subtitle
			timeLabel.text = "\(AppStrings.ExposureSubmissionResult.PCR.registrationDate) \(formattedTestDate)"
		case .antigen:
			subTitleLabel.text = AppStrings.ExposureSubmissionResult.Antigen.card_subtitle
			timeLabel.text = String(format: AppStrings.Home.TestResult.Negative.dateAntigen, formattedTestDate)
		}
		
		switch coronaTest.testResult {
		case .positive: titleLabel.text = "\(AppStrings.ExposureSubmissionResult.card_title)\n\(AppStrings.ExposureSubmissionResult.PCR.card_positive)"
		case .negative: titleLabel.text = "\(AppStrings.ExposureSubmissionResult.card_title)\n\(AppStrings.ExposureSubmissionResult.PCR.card_negative)"
		case .invalid: titleLabel.text = AppStrings.ExposureSubmissionResult.card_invalid
		case .pending: titleLabel.text = AppStrings.ExposureSubmissionResult.card_pending
		case .expired: titleLabel.text = AppStrings.ExposureSubmissionResult.card_invalid
		}
	}

	func configure(coronaTest: FamilyMemberCoronaTest) {
		barView.backgroundColor = coronaTest.testResult.color
		imageView.image = coronaTest.testResult.image

		let formattedTestDate = DateFormatter.localizedString(from: coronaTest.testDate, dateStyle: .medium, timeStyle: .none)
		
		switch coronaTest.type {
		case .pcr:
			subTitleLabel.text = AppStrings.ExposureSubmissionResult.PCR.card_subtitle
			timeLabel.text = "\(AppStrings.ExposureSubmissionResult.PCR.registrationDate) \(formattedTestDate)"
		case .antigen:
			subTitleLabel.text = AppStrings.ExposureSubmissionResult.Antigen.card_subtitle
			timeLabel.text = String(format: AppStrings.Home.TestResult.Negative.dateAntigen, formattedTestDate)
		}
		
		switch coronaTest.testResult {
		case .positive: titleLabel.text = "\(AppStrings.ExposureSubmissionResult.card_title)\n\(AppStrings.ExposureSubmissionResult.PCR.card_positive)"
		case .negative: titleLabel.text = "\(AppStrings.ExposureSubmissionResult.card_title)\n\(AppStrings.ExposureSubmissionResult.PCR.card_negative)"
		case .invalid: titleLabel.text = AppStrings.ExposureSubmissionResult.card_invalid
		case .pending: titleLabel.text = AppStrings.ExposureSubmissionResult.card_pending
		case .expired: titleLabel.text = AppStrings.ExposureSubmissionResult.card_invalid
		}
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		updateIllustration(for: traitCollection)
	}

	private func updateIllustration(for traitCollection: UITraitCollection) {
		if traitCollection.preferredContentSizeCategory >= .extraExtraExtraLarge {
			imageView.isHidden = true
		} else {
			imageView.isHidden = false
		}
	}
}

extension TestResult {
	
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
