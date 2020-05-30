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

import UIKit

final class HomeLowRiskCellConfigurator: HomeRiskCellConfigurator {
	private var numberDays: Int
	private var totalDays: Int

	// MARK: Creating a Home Risk Cell Configurator

	init(isLoading: Bool, isButtonEnabled: Bool, isButtonHidden: Bool, isCounterLabelHidden: Bool, startDate: Date?, releaseDate: Date?, numberDays: Int, totalDays: Int, lastUpdateDate: Date?) {
		self.numberDays = numberDays
		self.totalDays = totalDays
		super.init(isLoading: isLoading, isButtonEnabled: isButtonEnabled, isButtonHidden: isButtonHidden, isCounterLabelHidden: isCounterLabelHidden, startDate: startDate, releaseDate: releaseDate, lastUpdateDate: lastUpdateDate)
	}

	// MARK: Configuration

	override func configure(cell: RiskCollectionViewCell) {
		cell.delegate = self

		cell.removeAllArrangedSubviews()

		let title: String = isLoading ? AppStrings.Home.riskCardStatusCheckTitle : AppStrings.Home.riskCardLowTitle
		let titleColor: UIColor = .white
		cell.configureTitle(title: title, titleColor: titleColor)
		cell.configureBody(text: "", bodyColor: titleColor, isHidden: true)

		let color = UIColor.preferredColor(for: .positiveRisk)
		let separatorColor = UIColor.white.withAlphaComponent(0.15)
		var itemCellConfigurators: [HomeRiskViewConfiguratorAny] = []
		if isLoading {
			let isLoadingItem = HomeRiskLoadingItemViewConfigurator(title: AppStrings.Home.riskCardStatusCheckBody, titleColor: titleColor, isLoading: true, color: color, separatorColor: separatorColor)
			itemCellConfigurators.append(isLoadingItem)
		} else {
			let item1 = HomeRiskImageItemViewConfigurator(title: AppStrings.Home.riskCardLowNoContactItemTitle, titleColor: titleColor, iconImageName: "InfizierteKontakte", iconTintColor: titleColor, color: color, separatorColor: separatorColor)
			let numberDaysString = String(numberDays)
			let totalDaysString = String(totalDays)
			let saveDays = String(format: AppStrings.Home.riskCardLowSaveDaysItemTitle, numberDaysString, totalDaysString)
			let item2 = HomeRiskImageItemViewConfigurator(title: saveDays, titleColor: titleColor, iconImageName: "LetztePruefung", iconTintColor: titleColor, color: color, separatorColor: separatorColor)
			let dateTitle = String(format: AppStrings.Home.riskCardLowDateItemTitle, lastUpdateDateString)
			let item3 = HomeRiskImageItemViewConfigurator(title: dateTitle, titleColor: titleColor, iconImageName: "History", iconTintColor: titleColor, color: color, separatorColor: separatorColor)
			itemCellConfigurators.append(item1)
			itemCellConfigurators.append(item2)
			itemCellConfigurators.append(item3)
		}
		cell.configureRiskViews(cellConfigurators: itemCellConfigurators)
		cell.configureBackgroundColor(color: color)

		cell.configureChevron(image: UIImage(systemName: "chevron.right.circle.fill"), tintColor: .preferredColor(for: .chevron))

		let buttonTitle: String = isLoading ? AppStrings.Home.riskCardStatusCheckButton : AppStrings.Home.riskCardLowButton
		if let (minutes, seconds) = counterTouple() {
			let counterLabelText = String(format: AppStrings.Home.riskCardStatusCheckCounterLabel, minutes, seconds)
			cell.configureCounterLabel(text: counterLabelText, isHidden: isCounterLabelHidden)
			let formattedTime = String(format: "(%02u:%02u)", minutes, seconds)
			let updateButtonText = "\(buttonTitle) \(formattedTime)"
			cell.configureUpdateButton(
				title: updateButtonText,
				color: .preferredColor(for: .textPrimary1),
				backgroundColor: .preferredColor(for: .backgroundPrimary),
				isEnabled: isButtonEnabled,
				isHidden: isButtonHidden
			)
		} else {
			cell.configureCounterLabel(text: "test", isHidden: isCounterLabelHidden)
			cell.configureUpdateButton(
				title: buttonTitle,
				color: .preferredColor(for: .textPrimary1),
				backgroundColor: .preferredColor(for: .backgroundPrimary),
				isEnabled: isButtonEnabled,
				isHidden: isButtonHidden
			)
		}
	}
}
