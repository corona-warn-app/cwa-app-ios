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

	let identifier = UUID()

	// MARK: Properties

	var buttonAction: (() -> Void)?

	var isLoading: Bool
	var isButtonEnabled: Bool
	var isButtonHidden: Bool
	var detectionIntervalLabelHidden: Bool

	var startDate: Date?
	var releaseDate: Date?

	var lastUpdateDate: Date?

	private let calendar = Calendar.current

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
		startDate: Date?,
		releaseDate: Date?,
		lastUpdateDate: Date?
	) {
		self.isLoading = isLoading
		self.isButtonEnabled = isButtonEnabled
		self.isButtonHidden = isButtonHidden // ; TODO: Use isButtonHidden again
		self.detectionIntervalLabelHidden = detectionIntervalLabelHidden
		self.startDate = startDate
		self.releaseDate = releaseDate
		self.lastUpdateDate = lastUpdateDate
	}

	// MARK: Loading

	func startLoading() {
		isLoading = true
	}

	func stopLoading() {
		isLoading = false
	}

	// MARK: Counter

	func updateCounter(startDate: Date, releaseDate: Date) {
		self.startDate = startDate
		self.releaseDate = releaseDate
	}

	func removeCounter() {
		startDate = nil
		releaseDate = nil
	}

	// MARK: Button

	func updateButtonEnabled(_ enabled: Bool) {
		isButtonEnabled = enabled
	}

	func configureCounter(buttonTitle: String, cell: RiskLevelCollectionViewCell) {
		cell.configureDetectionIntervalLabel(
			text: "Aktualisierung alle 24 Stunden",
			isHidden: detectionIntervalLabelHidden
		)
		cell.configureUpdateButton(
			title: buttonTitle,
			isEnabled: isButtonEnabled,
			isHidden: isButtonHidden
		)

	}

	// MARK: Configuration

	func configure(cell _: RiskLevelCollectionViewCell) {
		fatalError("implement this method in children")
	}
}

extension HomeRiskLevelCellConfigurator: RiskLevelCollectionViewCellDelegate {
	func updateButtonTapped(cell _: RiskLevelCollectionViewCell) {
		buttonAction?()
	}
}
