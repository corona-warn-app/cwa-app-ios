//
// Corona-Warn-App
//
// SAP SE and all other contributors /
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

import UIKit

class HomeRiskLevelCellConfigurator: HomeRiskCellConfigurator {

	// MARK: Properties
	let identifier = UUID()
	var buttonAction: (() -> Void)?

	var isLoading: Bool
	var isButtonEnabled: Bool
	var isButtonHidden: Bool
	var detectionIntervalLabelHidden: Bool
	var lastUpdateDate: Date?

	private static let lastUpdateDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.doesRelativeDateFormatting = true
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .short
		return dateFormatter
	}()

	var lastUpdateDateString: String {
		if let lastUpdateDate = lastUpdateDate {
			return Self.lastUpdateDateFormatter.string(from: lastUpdateDate)
		} else {
			return AppStrings.Home.riskCardNoDateTitle
		}
	}

	// MARK: Creating a Home Risk Cell Configurator

	init(
		isLoading: Bool,
		isButtonEnabled: Bool,
		isButtonHidden: Bool,
		detectionIntervalLabelHidden: Bool,
		lastUpdateDate: Date?
	) {
		self.isLoading = isLoading
		self.isButtonEnabled = isButtonEnabled
		self.isButtonHidden = isButtonHidden
		self.detectionIntervalLabelHidden = detectionIntervalLabelHidden
		self.lastUpdateDate = lastUpdateDate
	}

	// MARK: Loading
	func startLoading() {
		isLoading = true
	}

	func stopLoading() {
		isLoading = false
	}

	// MARK: Button

	func updateButtonEnabled(_ enabled: Bool) {
		isButtonEnabled = enabled
	}

	func updateButtonHidden(_ hidden: Bool) {
		isButtonHidden = hidden
	}

	// MARK: Configuration

	func configure(cell _: RiskLevelCollectionViewCell) {
		fatalError("implement this method in children")
	}

	func setupAccessibility(_ cell: RiskLevelCollectionViewCell) {
		cell.titleLabel.isAccessibilityElement = false
		cell.chevronImageView.isAccessibilityElement = false
		cell.viewContainer.isAccessibilityElement = false
		cell.stackView.isAccessibilityElement = false

		cell.topContainer.isAccessibilityElement = true
		cell.bodyLabel.isAccessibilityElement = true
		cell.detectionIntervalLabel.isAccessibilityElement = true
		cell.updateButton.isAccessibilityElement = true

		cell.topContainer.accessibilityTraits = [.updatesFrequently, .button]
		cell.bodyLabel.accessibilityTraits = [.updatesFrequently]
		cell.detectionIntervalLabel.accessibilityTraits = [.updatesFrequently]
		cell.updateButton.accessibilityTraits = [.updatesFrequently, .button]

		cell.topContainer.accessibilityLabel = cell.titleLabel.text ?? ""

		cell.topContainer.accessibilityIdentifier = AccessibilityIdentifiers.RiskCollectionViewCell.topContainer
		cell.bodyLabel.accessibilityIdentifier = AccessibilityIdentifiers.RiskCollectionViewCell.bodyLabel
		cell.detectionIntervalLabel.accessibilityIdentifier = AccessibilityIdentifiers.RiskCollectionViewCell.detectionIntervalLabel
		cell.updateButton.accessibilityIdentifier = AccessibilityIdentifiers.RiskCollectionViewCell.updateButton

	}
}

extension HomeRiskLevelCellConfigurator: RiskLevelCollectionViewCellDelegate {
	func updateButtonTapped(cell _: RiskLevelCollectionViewCell) {
		buttonAction?()
	}
}
