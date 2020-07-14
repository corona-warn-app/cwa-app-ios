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

import UIKit

final class HomeUnknown48hRiskCellConfigurator: HomeRiskLevelCellConfigurator {
	// MARK: Configuration

	private var previousRiskLevel: EitherLowOrIncreasedRiskLevel?

	// MARK: Creating a unknown Risk cell
	init(
		isLoading: Bool,
		lastUpdateDate: Date?,
		detectionInterval: Int,
		detectionMode: DetectionMode,
		manualExposureDetectionState: ManualExposureDetectionState?,
		previousRiskLevel: EitherLowOrIncreasedRiskLevel?
	) {
		self.previousRiskLevel = previousRiskLevel

		super.init(
			isLoading: isLoading,
			isButtonEnabled: manualExposureDetectionState == .possible,
			isButtonHidden: detectionMode == .automatic,
			detectionIntervalLabelHidden: detectionMode != .automatic,
			lastUpdateDate: lastUpdateDate,
			detectionInterval: detectionInterval
		)
	}

	override func configure(cell: RiskLevelCollectionViewCell) {
		cell.delegate = self

		let title: String = isLoading ? AppStrings.Home.riskCardStatusCheckTitle : AppStrings.Home.riskCardUnknownTitle
		let titleColor: UIColor = .enaColor(for: .textContrast)
		cell.configureTitle(title: title, titleColor: titleColor)

		let body: String = AppStrings.Home.riskCardUnknown48hBody
		cell.configureBody(text: body, bodyColor: titleColor, isHidden: isLoading)

		let color: UIColor = .enaColor(for: .riskNeutral)
		let separatorColor: UIColor = .enaColor(for: .hairlineContrast)
		var itemCellConfigurators: [HomeRiskViewConfiguratorAny] = []
		if isLoading {
			let isLoadingItem = HomeRiskLoadingItemViewConfigurator(title: AppStrings.Home.riskCardStatusCheckBody, titleColor: titleColor, isLoading: true, color: color, separatorColor: separatorColor)
			itemCellConfigurators.append(isLoadingItem)
		} else {

			let previousRiskTitle: String
			switch previousRiskLevel {
			case .low?:
				previousRiskTitle = AppStrings.Home.riskCardLastActiveItemLowTitle
			case .increased?:
				previousRiskTitle = AppStrings.Home.riskCardLastActiveItemHighTitle
			default:
				previousRiskTitle = AppStrings.Home.riskCardLastActiveItemUnknownTitle
			}

			let activateItemTitle = String(format: AppStrings.Home.riskCardLastActiveItemTitle, previousRiskTitle)
			let iconTintColor: UIColor = titleColor
			let item1 = HomeRiskImageItemViewConfigurator(title: activateItemTitle, titleColor: titleColor, iconImageName: "Icons_LetzteErmittlung-Light", iconTintColor: iconTintColor, color: color, separatorColor: separatorColor)
			let dateTitle = String(format: AppStrings.Home.riskCardDateItemTitle, lastUpdateDateString)
			let item2 = HomeRiskImageItemViewConfigurator(title: dateTitle, titleColor: titleColor, iconImageName: "Icons_Aktualisiert", iconTintColor: iconTintColor, color: color, separatorColor: separatorColor)
			itemCellConfigurators.append(contentsOf: [item1, item2])

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
		hasher.combine(previousRiskLevel)
	}

	static func == (lhs: HomeUnknown48hRiskCellConfigurator, rhs: HomeUnknown48hRiskCellConfigurator) -> Bool {
		lhs.isLoading == rhs.isLoading &&
		lhs.isButtonEnabled == rhs.isButtonEnabled &&
		lhs.isButtonHidden == rhs.isButtonHidden &&
		lhs.detectionIntervalLabelHidden == rhs.detectionIntervalLabelHidden &&
		lhs.lastUpdateDate == rhs.lastUpdateDate &&
		lhs.detectionInterval == rhs.detectionInterval &&
		lhs.previousRiskLevel == rhs.previousRiskLevel
	}
}
