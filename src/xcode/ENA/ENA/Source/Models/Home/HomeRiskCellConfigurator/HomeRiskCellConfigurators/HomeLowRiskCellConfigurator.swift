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

final class HomeLowRiskCellConfigurator: HomeRiskLevelCellConfigurator {
	private var numberRiskContacts: Int
	private var numberDays: Int
	private var totalDays: Int
	private let detectionInterval: Int

	// MARK: Creating a Home Risk Cell Configurator

	init(
		numberRiskContacts: Int,
		numberDays: Int,
		totalDays: Int,
		lastUpdateDate: Date?,
		isButtonHidden: Bool,
		detectionMode: DetectionMode,
		manualExposureDetectionState: ManualExposureDetectionState?,
		detectionInterval: Int
	) {
		self.numberRiskContacts = numberRiskContacts
		self.numberDays = numberDays
		self.totalDays = totalDays
		self.detectionInterval = detectionInterval
		super.init(
			isLoading: false,
			isButtonEnabled: manualExposureDetectionState == .possible,
			isButtonHidden: isButtonHidden,
			detectionIntervalLabelHidden: detectionMode != .automatic,
			lastUpdateDate: lastUpdateDate
		)
	}

	// MARK: Configuration

	override func configure(cell: RiskLevelCollectionViewCell) {
		cell.delegate = self

		let title = isLoading ? AppStrings.Home.riskCardStatusCheckTitle : AppStrings.Home.riskCardLowTitle
		let titleColor: UIColor = .enaColor(for: .textContrast)
		cell.configureTitle(title: title, titleColor: titleColor)
		cell.configureBody(text: "", bodyColor: titleColor, isHidden: true)

		let color: UIColor = .enaColor(for: .riskLow)
		let separatorColor: UIColor = .enaColor(for: .hairlineContrast)
		var itemCellConfigurators: [HomeRiskViewConfiguratorAny] = []
		if isLoading {
			let isLoadingItem = HomeRiskLoadingItemViewConfigurator(title: AppStrings.Home.riskCardStatusCheckBody, titleColor: titleColor, isLoading: true, color: color, separatorColor: separatorColor)
			itemCellConfigurators.append(isLoadingItem)
		} else {
			let numberContactsTitle = String(format: AppStrings.Home.riskCardNumberContactsItemTitle, numberRiskContacts)
			itemCellConfigurators.append(
				HomeRiskImageItemViewConfigurator(
					title: numberContactsTitle,
					titleColor: titleColor,
					iconImageName: "Icons_KeineRisikoBegegnung",
					iconTintColor: titleColor,
					color: color,
					separatorColor: separatorColor
				)
			)
			let numberDaysString = String(numberDays)
			let totalDaysString = String(totalDays)
			let saveDays = String(
				format: AppStrings.Home.riskCardLowSaveDaysItemTitle, numberDaysString, totalDaysString
			)
			let progressImage: String = numberDays >= totalDays ? "Icons_TracingCircleFull - Dark" : "Icons_TracingCircle-Dark_Step \(numberDays)"
			itemCellConfigurators.append(
				HomeRiskImageItemViewConfigurator(
					title: saveDays,
					titleColor: titleColor,
					iconImageName: progressImage,
					iconTintColor: titleColor,
					color: color,
					separatorColor: separatorColor
				)
			)

			let dateTitle = String(format: AppStrings.Home.riskCardDateItemTitle, lastUpdateDateString)
			itemCellConfigurators.append(
				HomeRiskImageItemViewConfigurator(
					title: dateTitle,
					titleColor: titleColor,
					iconImageName: "Icons_Aktualisiert",
					iconTintColor: titleColor,
					color: color,
					separatorColor: separatorColor
				)
			)
		}
		cell.configureRiskViews(cellConfigurators: itemCellConfigurators)
		cell.configureBackgroundColor(color: color)

		let intervalString = "\(detectionInterval)"
		let intervalTitle = String(format: AppStrings.Home.riskCardIntervalUpdateTitle, intervalString)
		cell.configureDetectionIntervalLabel(
			text: intervalTitle,
			isHidden: detectionIntervalLabelHidden
		)

		let buttonTitle: String
		if isLoading {
			buttonTitle = AppStrings.Home.riskCardStatusCheckButton
		} else {
			let intervalDisabledButtonTitle = String(format: AppStrings.Home.riskCardIntervalDisabledButtonTitle, intervalString)
			buttonTitle = isButtonEnabled ? AppStrings.Home.riskCardLowButton : intervalDisabledButtonTitle
		}
		cell.configureUpdateButton(
			title: buttonTitle,
			isEnabled: isButtonEnabled,
			isHidden: isButtonHidden,
			accessibilityIdentifier: AccessibilityIdentifiers.Home.riskCardIntervalUpdateTitle
		)

		setupAccessibility(cell)
	}
}
