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

	private var column = UIView()
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
		subTitleLabel.text = AppStrings.ExposureSubmissionResult.card_subtitle
		titleLabel.text = localizedString(for: testResult)
		barView.backgroundColor = testResult.color

		if let timeStamp = timeStamp {
			let formatter = DateFormatter()
			formatter.dateStyle = .medium
			formatter.timeStyle = .none
			let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
			timeLabel.text = "\(AppStrings.ExposureSubmissionResult.registrationDate) \(formatter.string(from: date))"
		} else {
			timeLabel.text = AppStrings.ExposureSubmissionResult.registrationDateUnknown
		}
	}

	// MARK: Configuration helpers.

	// swiftlint:disable:next function_body_length
	private func setupView(_ result: TestResult) {
		baseView.backgroundColor = UIColor.enaColor(for: .separator)
		baseView.layer.cornerRadius = 14
		baseView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(baseView)

		baseView.widthAnchor.constraint(equalTo: widthAnchor, constant: -32).isActive = true
		baseView.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
		baseView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
		baseView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

		barView = UIView()
		barView.layer.cornerRadius = 2
		barView.translatesAutoresizingMaskIntoConstraints = false
		baseView.addSubview(barView)

		barView.widthAnchor.constraint(equalToConstant: 4).isActive = true
		barView.heightAnchor.constraint(equalToConstant: 120).isActive = true
		barView.centerYAnchor.constraint(equalTo: baseView.centerYAnchor).isActive = true
		barView.leftAnchor.constraint(equalTo: baseView.leftAnchor, constant: 14).isActive = true
		barView.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 16).isActive = true

		column = UIView()
		column.translatesAutoresizingMaskIntoConstraints = false
		baseView.addSubview(column)
		column.heightAnchor.constraint(equalTo: baseView.heightAnchor).isActive = true
		column.widthAnchor.constraint(equalToConstant: 160).isActive = true
		column.centerYAnchor.constraint(equalTo: baseView.centerYAnchor).isActive = true
		column.leftAnchor.constraint(equalTo: barView.rightAnchor, constant: 25).isActive = true

		subTitleLabel = ENALabel()
		subTitleLabel.text = "Footnote"
		subTitleLabel.numberOfLines = 0
		subTitleLabel.style = .footnote
		subTitleLabel.textColor = .enaColor(for: .textPrimary2)
		subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
		column.addSubview(subTitleLabel)
		subTitleLabel.leftAnchor.constraint(equalTo: column.leftAnchor, constant: 5).isActive = true
		subTitleLabel.topAnchor.constraint(equalTo: barView.topAnchor).isActive = true

		titleLabel = ENALabel()
		titleLabel.text = "Title 2"
		titleLabel.numberOfLines = 0
		titleLabel.style = .title2
		titleLabel.textColor = .enaColor(for: .textPrimary1)
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		column.addSubview(titleLabel)
		titleLabel.leftAnchor.constraint(equalTo: column.leftAnchor, constant: 5).isActive = true
		titleLabel.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 5).isActive = true
		titleLabel.widthAnchor.constraint(equalTo: column.widthAnchor).isActive = true

		timeLabel = ENALabel()
		timeLabel.text = "timelabel"
		timeLabel.style = .footnote
		timeLabel.textColor = .enaColor(for: .textPrimary1)
		timeLabel.translatesAutoresizingMaskIntoConstraints = false
		column.addSubview(timeLabel)
		timeLabel.leftAnchor.constraint(equalTo: column.leftAnchor, constant: 5).isActive = true
		timeLabel.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -16).isActive = true

		imageView = UIImageView(image: image(for: result))
		imageView.translatesAutoresizingMaskIntoConstraints = false
		baseView.addSubview(imageView)
		imageView.contentMode = .scaleAspectFit
		imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
		imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
		imageView.centerYAnchor.constraint(equalTo: baseView.centerYAnchor).isActive = true
		imageView.rightAnchor.constraint(equalTo: baseView.rightAnchor, constant: -20).isActive = true
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
