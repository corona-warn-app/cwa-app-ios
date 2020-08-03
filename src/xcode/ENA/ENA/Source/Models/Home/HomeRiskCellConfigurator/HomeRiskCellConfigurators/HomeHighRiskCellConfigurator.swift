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

final class HomeHighRiskCellConfigurator: HomeRiskLevelCellConfigurator {
	private var numberRiskContacts: Int
	private var daysSinceLastExposure: Int?

	// MARK: Creating a Home Risk Cell Configurator

	init(
		isLoading: Bool,
		numberRiskContacts: Int,
		daysSinceLastExposure: Int?,
		lastUpdateDate: Date?,
		manualExposureDetectionState: ManualExposureDetectionState?,
		detectionMode: DetectionMode,
		detectionInterval: Int
	) {
		self.numberRiskContacts = numberRiskContacts
		self.daysSinceLastExposure = daysSinceLastExposure
		super.init(
			isLoading: isLoading,
			isButtonEnabled: manualExposureDetectionState == .possible,
			isButtonHidden: detectionMode == .automatic,
			detectionIntervalLabelHidden: detectionMode != .automatic,
			lastUpdateDate: lastUpdateDate,
			detectionInterval: detectionInterval
		)
	}

	// MARK: Configuration

	override func configure(cell: RiskLevelCollectionViewCell) {
		cell.delegate = self

		let title: String = isLoading ? AppStrings.Home.riskCardStatusCheckTitle : AppStrings.Home.riskCardHighTitle
		let titleColor: UIColor = .enaColor(for: .textContrast)
		cell.configureTitle(title: title, titleColor: titleColor)
		cell.configureBody(text: "", bodyColor: titleColor, isHidden: true)

		let color: UIColor = .enaColor(for: .riskHigh)
		let separatorColor: UIColor = .enaColor(for: .hairlineContrast)
		var itemCellConfigurators: [HomeRiskViewConfiguratorAny] = []
		if isLoading {
			let isLoadingItem = HomeRiskLoadingItemViewConfigurator(title: AppStrings.Home.riskCardStatusCheckBody, titleColor: titleColor, isLoading: true, color: color, separatorColor: separatorColor)
			itemCellConfigurators.append(isLoadingItem)
		} else {
			let numberOfDaysSinceLastExposure = daysSinceLastExposure ?? 0
			let numberContactsTitle = String(format: AppStrings.Home.riskCardNumberContactsItemTitle, numberRiskContacts)
			let item1 = HomeRiskImageItemViewConfigurator(title: numberContactsTitle, titleColor: titleColor, iconImageName: "Icons_RisikoBegegnung", iconTintColor: titleColor, color: color, separatorColor: separatorColor)
			let lastContactTitle = String(format: AppStrings.Home.riskCardLastContactItemTitle, numberOfDaysSinceLastExposure)
			let item2 = HomeRiskImageItemViewConfigurator(title: lastContactTitle, titleColor: titleColor, iconImageName: "Icons_Calendar", iconTintColor: titleColor, color: color, separatorColor: separatorColor)
			let dateTitle = String(format: AppStrings.Home.riskCardDateItemTitle, lastUpdateDateString)
			let item3 = HomeRiskImageItemViewConfigurator(title: dateTitle, titleColor: titleColor, iconImageName: "Icons_Aktualisiert", iconTintColor: titleColor, color: color, separatorColor: separatorColor)
			itemCellConfigurators.append(contentsOf: [item1, item2, item3])
		}
		cell.configureRiskViews(cellConfigurators: itemCellConfigurators)
		cell.configureBackgroundColor(color: color)

		let intervalTitle = String(format: AppStrings.Home.riskCardIntervalUpdateTitle, "\(detectionInterval)")
		cell.configureDetectionIntervalLabel(
			text: intervalTitle,
			isHidden: detectionIntervalLabelHidden
		)


		configureButton(for: cell)
		setupAccessibility(cell)
	}

	// MARK: Hashable

	override func hash(into hasher: inout Swift.Hasher) {
		super.hash(into: &hasher)
		hasher.combine(numberRiskContacts)
		hasher.combine(daysSinceLastExposure)
	}

	static func == (lhs: HomeHighRiskCellConfigurator, rhs: HomeHighRiskCellConfigurator) -> Bool {
		lhs.isLoading == rhs.isLoading &&
		lhs.isButtonEnabled == rhs.isButtonEnabled &&
		lhs.isButtonHidden == rhs.isButtonHidden &&
		lhs.detectionIntervalLabelHidden == rhs.detectionIntervalLabelHidden &&
		lhs.lastUpdateDate == rhs.lastUpdateDate &&
		lhs.numberRiskContacts == rhs.numberRiskContacts &&
		lhs.daysSinceLastExposure == rhs.daysSinceLastExposure &&
		lhs.detectionInterval == rhs.detectionInterval
	}
}
