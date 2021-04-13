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

	func configure(coronaTest: CoronaTest, timeStamp: Int64?) {

		barView.backgroundColor = coronaTest.testResult.color
		imageView.image = coronaTest.testResult.image
		
		switch coronaTest.type {
		case .pcr:
			subTitleLabel.text = AppStrings.ExposureSubmissionResult.PCR.card_subtitle
		case .antigen:
			subTitleLabel.text = AppStrings.ExposureSubmissionResult.Antigen.card_subtitle
		}
		
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
