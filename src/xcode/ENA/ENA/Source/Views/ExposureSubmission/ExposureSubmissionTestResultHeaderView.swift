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

import Foundation
import UIKit

class ExposureSubmissionTestResultHeaderView: DynamicTableViewHeaderFooterView {
	// MARK: Attributes.

	private var titleLabel: ENALabel!
	private var subTitleLabel: ENALabel!
	private var timeLabel: ENALabel!

	private var imageView: UIImageView!
	private var barView: UIView!

	private var stackView: UIStackView!
	private var baseView = UIView()

	// MARK: - UITableViewCell methods.

	override func prepareForReuse() {
		super.prepareForReuse()
		baseView.subviews.forEach { $0.removeFromSuperview() }
		baseView.removeFromSuperview()
	}

	// MARK: - DynamicTableViewHeaderFooterView methods.

	func configure(testResult: TestResult, timeStamp: Int64?) {
		setupView(testResult)
		setupConstraints()

		subTitleLabel.text = AppStrings.ExposureSubmissionResult.card_subtitle
		titleLabel.text = localizedString(for: testResult)
		barView.backgroundColor = testResult.color

		if let timeStamp = timeStamp {
			let formatter = DateFormatter()
			formatter.dateStyle = .medium
			formatter.timeStyle = .none
			let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
			timeLabel.text = "\n\(AppStrings.ExposureSubmissionResult.registrationDate) \(formatter.string(from: date))"
		} else {
			timeLabel.text = "\n\(AppStrings.ExposureSubmissionResult.registrationDateUnknown)"
		}
	}

	// MARK: Configuration helpers.

	private func setupView(_ result: TestResult) {

		imageView = UIImageView(image: image(for: result))
		imageView.contentMode = .scaleAspectFit

		baseView.backgroundColor = UIColor.enaColor(for: .separator)
		baseView.layer.cornerRadius = 14

		barView = UIView()
		barView.layer.cornerRadius = 2

		stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 8.0

		subTitleLabel = ENALabel()
		subTitleLabel.text = "Footnote"
		subTitleLabel.numberOfLines = 0
		subTitleLabel.style = .footnote
		subTitleLabel.textColor = .enaColor(for: .textPrimary2)

		titleLabel = ENALabel()
		titleLabel.text = "Title 2"
		titleLabel.numberOfLines = 0
		titleLabel.style = .title2
		titleLabel.textColor = .enaColor(for: .textPrimary1)

		timeLabel = ENALabel()
		timeLabel.text = "timelabel"
		timeLabel.style = .footnote
		timeLabel.textColor = .enaColor(for: .textPrimary1)
		timeLabel.numberOfLines = 0
	}

	private func setupConstraints() {

		// No autoresizing mask constraint.
		imageView.translatesAutoresizingMaskIntoConstraints = false
		baseView.translatesAutoresizingMaskIntoConstraints = false
		barView.translatesAutoresizingMaskIntoConstraints = false
		stackView.translatesAutoresizingMaskIntoConstraints = false

		// Setup view hierarchy.
		addSubview(baseView)

		stackView.addArrangedSubview(subTitleLabel)
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(timeLabel)

		baseView.addSubview(imageView)
		baseView.addSubview(barView)
		baseView.addSubview(stackView)

		// Setup constraints.
		baseView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
		baseView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
		baseView.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
		let bottomConstraint = baseView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
		bottomConstraint.priority = .init(999)
		bottomConstraint.isActive = true

		barView.widthAnchor.constraint(equalToConstant: 4).isActive = true
		barView.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 16).isActive = true
		barView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -16).isActive = true
		barView.leftAnchor.constraint(equalTo: baseView.leftAnchor, constant: 14).isActive = true

		stackView.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 16).isActive = true
		stackView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -16).isActive = true
		stackView.leadingAnchor.constraint(equalTo: barView.trailingAnchor, constant: 16).isActive = true
		stackView.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 16).isActive = true

		imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
		imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
		imageView.centerYAnchor.constraint(equalTo: baseView.centerYAnchor).isActive = true
		imageView.rightAnchor.constraint(equalTo: baseView.rightAnchor, constant: -16).isActive = true
	}

	private func localizedString(for testResult: TestResult) -> String {
		switch testResult {
		case .positive:
			return "\(AppStrings.ExposureSubmissionResult.card_title)\n\(AppStrings.ExposureSubmissionResult.card_positive)"
		case .negative:
			return "\(AppStrings.ExposureSubmissionResult.card_title)\n\(AppStrings.ExposureSubmissionResult.card_negative)"
		case .invalid:
			return AppStrings.ExposureSubmissionResult.card_invalid
		case .pending:
			return AppStrings.ExposureSubmissionResult.card_pending
		}
	}

	private func image(for result: TestResult) -> UIImage? {
		switch result {
		case .positive:
			return UIImage(named: "Illu_Submission_PositivTestErgebnis")
		case .negative:
			return UIImage(named: "Illu_Submission_NegativesTestErgebnis")
		case .invalid:
			return UIImage(named: "Illu_Submission_FehlerhaftesTestErgebnis")
		case .pending:
			return UIImage(named: "Illu_Submission_PendingTestErgebnis")
		}
	}
}

private extension TestResult {
	var color: UIColor {
		switch self {
		case .positive: return .enaColor(for: .riskHigh)
		case .negative: return .enaColor(for: .riskLow)
		case .invalid: return .enaColor(for: .riskNeutral)
		case .pending: return .enaColor(for: .riskNeutral)
		}
	}
}
