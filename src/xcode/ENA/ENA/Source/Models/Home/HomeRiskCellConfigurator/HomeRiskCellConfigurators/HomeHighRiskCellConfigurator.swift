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

	private let titleColor: UIColor = .enaColor(for: .textContrast)
	private let color: UIColor = .enaColor(for: .riskHigh)
	private let separatorColor: UIColor = .enaColor(for: .hairlineContrast)

	// MARK: Creating a Home Risk Cell Configurator

	init(
		state: ActivityState,
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
			state: state,
			isButtonEnabled: manualExposureDetectionState == .possible,
			isButtonHidden: detectionMode == .automatic,
			detectionIntervalLabelHidden: detectionMode != .automatic,
			lastUpdateDate: lastUpdateDate,
			detectionInterval: detectionInterval
		)
	}

	// MARK: Configuration

	override func configure(cell: RiskLevelCollectionViewCell) {
		var itemCellConfigurators: [HomeRiskViewConfiguratorAny] = []
		
		switch state {
		case .loading:
			itemCellConfigurators.append(setupLoadingCellState(for: cell))
		default:
			itemCellConfigurators.append(contentsOf: setupNormalCellState(for: cell))
		}

		cell.configureRiskViews(cellConfigurators: itemCellConfigurators)
		cell.configureBackgroundColor(color: color)
		cell.delegate = self
		cell.configureBody(text: "", bodyColor: titleColor, isHidden: true)
		cell.configureDetectionIntervalLabel(
			text: String(format: AppStrings.Home.riskCardIntervalUpdateTitle, "\(detectionInterval)"),
			isHidden: detectionIntervalLabelHidden
		)

		configureButton(for: cell)
		setupAccessibility(cell)
	}

	// MARK: - Configuration helpers.

	private func setupLoadingCellState(for cell: RiskLevelCollectionViewCell) -> HomeRiskViewConfiguratorAny {
		cell.configureTitle(title: AppStrings.Home.riskCardStatusCheckTitle, titleColor: titleColor)
		return HomeRiskLoadingItemViewConfigurator(title: AppStrings.Home.riskCardStatusCheckBody, titleColor: titleColor, isActivityIndicatorOn: true, color: color, separatorColor: separatorColor)
	}

	private func setupNormalCellState(for cell: RiskLevelCollectionViewCell) -> [HomeRiskViewConfiguratorAny] {
		cell.configureTitle(title: AppStrings.Home.riskCardHighTitle, titleColor: titleColor)
		let numberOfDaysSinceLastExposure = daysSinceLastExposure ?? 0
		let numberContactsTitle = String(format: AppStrings.Home.riskCardHighNumberContactsItemTitle, numberRiskContacts)
		let lastContactTitle = String(format: AppStrings.Home.riskCardLastContactItemTitle, numberOfDaysSinceLastExposure)
		let dateTitle = String(format: AppStrings.Home.riskCardDateItemTitle, lastUpdateDateString)

		return [
			HomeRiskImageItemViewConfigurator(title: numberContactsTitle, titleColor: titleColor, iconImageName: "Icons_RisikoBegegnung", iconTintColor: titleColor, color: color, separatorColor: separatorColor),
			HomeRiskImageItemViewConfigurator(title: lastContactTitle, titleColor: titleColor, iconImageName: "Icons_Calendar", iconTintColor: titleColor, color: color, separatorColor: separatorColor),
			HomeRiskImageItemViewConfigurator(title: dateTitle, titleColor: titleColor, iconImageName: "Icons_Aktualisiert", iconTintColor: titleColor, color: color, separatorColor: separatorColor)
		]
	}

	// MARK: Hashable

	override func hash(into hasher: inout Swift.Hasher) {
		super.hash(into: &hasher)
		hasher.combine(numberRiskContacts)
		hasher.combine(daysSinceLastExposure)
	}

	static func == (lhs: HomeHighRiskCellConfigurator, rhs: HomeHighRiskCellConfigurator) -> Bool {
		lhs.state == rhs.state &&
		lhs.isButtonEnabled == rhs.isButtonEnabled &&
		lhs.isButtonHidden == rhs.isButtonHidden &&
		lhs.detectionIntervalLabelHidden == rhs.detectionIntervalLabelHidden &&
		lhs.lastUpdateDate == rhs.lastUpdateDate &&
		lhs.numberRiskContacts == rhs.numberRiskContacts &&
		lhs.daysSinceLastExposure == rhs.daysSinceLastExposure &&
		lhs.detectionInterval == rhs.detectionInterval
	}
}
