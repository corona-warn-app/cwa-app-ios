//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import Foundation
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

	func configure(testResult: TestResult, timeStamp: Int64?) {
		subTitleLabel.text = AppStrings.ExposureSubmissionResult.card_subtitle
		titleLabel.text = testResult.text
		barView.backgroundColor = testResult.color
		imageView.image = testResult.image

		if let timeStamp = timeStamp {
			let formatter = DateFormatter()
			formatter.dateStyle = .medium
			formatter.timeStyle = .none
			let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
			timeLabel.text = "\(AppStrings.ExposureSubmissionResult.registrationDate) \(formatter.string(from: date))"
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

private extension TestResult {
	var color: UIColor {
		switch self {
		case .positive: return .enaColor(for: .riskHigh)
		case .negative: return .enaColor(for: .riskLow)
		case .invalid, .redeemed: return .enaColor(for: .riskNeutral)
		case .pending: return .enaColor(for: .riskNeutral)
		}
	}

	var image: UIImage? {
		switch self {
		case .positive: return UIImage(named: "Illu_Submission_PositivTestErgebnis")
		case .negative: return UIImage(named: "Illu_Submission_NegativesTestErgebnis")
		case .invalid, .redeemed: return UIImage(named: "Illu_Submission_FehlerhaftesTestErgebnis")
		case .pending: return UIImage(named: "Illu_Submission_PendingTestErgebnis")
		}
	}

	var text: String {
		switch self {
		case .positive: return "\(AppStrings.ExposureSubmissionResult.card_title)\n\(AppStrings.ExposureSubmissionResult.card_positive)"
		case .negative: return "\(AppStrings.ExposureSubmissionResult.card_title)\n\(AppStrings.ExposureSubmissionResult.card_negative)"
		case .invalid: return AppStrings.ExposureSubmissionResult.card_invalid
		case .pending: return AppStrings.ExposureSubmissionResult.card_pending
		case .redeemed: return AppStrings.ExposureSubmissionResult.card_invalid
		}
	}
}
