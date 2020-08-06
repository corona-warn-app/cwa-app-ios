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
	private var numberDays: Int {
		activeTracing.inDays
	}
	private var totalDays: Int {
		activeTracing.maximumNumberOfDays
	}
	private let detectionInterval: Int
	private let activeTracing: ActiveTracing

	// MARK: Creating a Home Risk Cell Configurator

	init(
		isLoading: Bool,
		numberRiskContacts: Int,
		lastUpdateDate: Date?,
		isButtonHidden: Bool,
		detectionMode: DetectionMode,
		manualExposureDetectionState: ManualExposureDetectionState?,
		detectionInterval: Int,
		activeTracing: ActiveTracing
	) {
		self.numberRiskContacts = numberRiskContacts
		self.detectionInterval = detectionInterval
		self.activeTracing = activeTracing
		super.init(
			isLoading: isLoading,
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
			let numberContactsTitle = String(format: AppStrings.Home.riskCardLowNumberContactsItemTitle, numberRiskContacts)
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
			let progressImage: String = numberDays >= totalDays ? "Icons_TracingCircleFull - Dark" : "Icons_TracingCircle-Dark_Step \(activeTracing.inDays)"
			itemCellConfigurators.append(
				HomeRiskImageItemViewConfigurator(
					title: activeTracing.localizedDuration,
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

		let intervalTitle = String(format: AppStrings.Home.riskCardIntervalUpdateTitle, "\(detectionInterval)")
		cell.configureDetectionIntervalLabel(
			text: intervalTitle,
			isHidden: detectionIntervalLabelHidden
		)

		configureButton(for: cell)
		setupAccessibility(cell)
	}

	override func configureButton(for cell: RiskLevelCollectionViewCell) {
		super.configureButton(for: cell)
		cell.configureUpdateButton(
			title: buttonTitle,
			isEnabled: isButtonEnabled,
			isHidden: isButtonHidden,
			accessibilityIdentifier: AccessibilityIdentifiers.Home.riskCardIntervalUpdateTitle
		)
	}

	private var buttonTitle: String {
		if isLoading { return AppStrings.Home.riskCardStatusCheckButton }
		if isButtonEnabled { return AppStrings.Home.riskCardLowButton }
		if let timeUntilUpdate = timeUntilUpdate { return String(format: AppStrings.ExposureDetection.refreshIn, timeUntilUpdate) }
		return String(format: AppStrings.Home.riskCardIntervalDisabledButtonTitle, "\(detectionInterval)")
	}
	
	// MARK: Hashable

	override func hash(into hasher: inout Swift.Hasher) {
		super.hash(into: &hasher)
		hasher.combine(numberRiskContacts)
		hasher.combine(numberDays)
		hasher.combine(totalDays)
		hasher.combine(detectionInterval)
	}

	static func == (lhs: HomeLowRiskCellConfigurator, rhs: HomeLowRiskCellConfigurator) -> Bool {
		lhs.isLoading == rhs.isLoading &&
		lhs.isButtonEnabled == rhs.isButtonEnabled &&
		lhs.isButtonHidden == rhs.isButtonHidden &&
		lhs.detectionIntervalLabelHidden == rhs.detectionIntervalLabelHidden &&
		lhs.lastUpdateDate == rhs.lastUpdateDate &&
		lhs.numberRiskContacts == rhs.numberRiskContacts &&
		lhs.numberDays == rhs.numberDays &&
		lhs.totalDays == rhs.totalDays &&
		lhs.detectionInterval == rhs.detectionInterval
	}
}
