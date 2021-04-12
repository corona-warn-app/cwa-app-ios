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
		if let test = coronaTest as? PCRTest {
			setupForPCRTest(test, timeStamp: timeStamp)
		} else if let test = coronaTest as? AntigenTest {
			setupForAntigenTest(test, timeStamp: timeStamp)
		} else if let test = coronaTest as? CoronaTest {
			switch test.type {
			case .pcr:
				setupForPCRTest(test, timeStamp: timeStamp)
			case .antigen:
				setupForAntigenTest(test, timeStamp: timeStamp)
			}
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
	
	private func setupForPCRTest<T: Test>(_ coronaTest: T, timeStamp: Int64?) {
		
		subTitleLabel.text = AppStrings.ExposureSubmissionResult.PCR.card_subtitle
		titleLabel.text = coronaTest.testResult.text
		barView.backgroundColor = coronaTest.testResult.color
		imageView.image = coronaTest.testResult.image

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
	
	private func setupForAntigenTest<T: Test>(_ coronaTest: T, timeStamp: Int64?) {
		
		subTitleLabel.text = AppStrings.ExposureSubmissionResult.Antigen.card_subtitle
		titleLabel.text = coronaTest.testResult.text
		barView.backgroundColor = coronaTest.testResult.color
		imageView.image = coronaTest.testResult.image

		if let timeStamp = timeStamp {
			let formatter = DateFormatter()
			formatter.dateStyle = .medium
			formatter.timeStyle = .short
			let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
			timeLabel.text = "\(AppStrings.ExposureSubmissionResult.Antigen.registrationDate) \(formatter.string(from: date))"
		} else {
			timeLabel.text = "\(AppStrings.ExposureSubmissionResult.registrationDateUnknown)"
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

	var text: String {
		switch self {
		case .positive: return "\(AppStrings.ExposureSubmissionResult.card_title)\n\(AppStrings.ExposureSubmissionResult.card_positive)"
		case .negative: return "\(AppStrings.ExposureSubmissionResult.card_title)\n\(AppStrings.ExposureSubmissionResult.card_negative)"
		case .invalid: return AppStrings.ExposureSubmissionResult.card_invalid
		case .pending: return AppStrings.ExposureSubmissionResult.card_pending
		case .expired: return AppStrings.ExposureSubmissionResult.card_invalid
		}
	}
}
