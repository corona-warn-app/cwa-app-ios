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

final class HomeUnknownRiskCellConfigurator: HomeRiskLevelCellConfigurator {
	// MARK: Configuration

	// MARK: Creating a unknown Risk cell
	init(
		isLoading: Bool,
		lastUpdateDate: Date?,
		detectionInterval: Int,
		detectionMode: DetectionMode,
		manualExposureDetectionState: ManualExposureDetectionState?
	) {
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
		cell.configureBody(text: "", bodyColor: titleColor, isHidden: true)

		let color: UIColor = .enaColor(for: .riskNeutral)
		let separatorColor: UIColor = .enaColor(for: .hairlineContrast)
		var itemCellConfigurators: [HomeRiskViewConfiguratorAny] = []
		if isLoading {
			let isLoadingItem = HomeRiskLoadingItemViewConfigurator(title: AppStrings.Home.riskCardStatusCheckBody, titleColor: titleColor, isLoading: true, color: color, separatorColor: separatorColor)
			itemCellConfigurators.append(isLoadingItem)
		} else {
			let item = HomeRiskTextItemViewConfigurator(title: AppStrings.Home.riskCardUnknownItemTitle, titleColor: titleColor, color: color, separatorColor: separatorColor)
			itemCellConfigurators.append(item)
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
	}

	static func == (lhs: HomeUnknownRiskCellConfigurator, rhs: HomeUnknownRiskCellConfigurator) -> Bool {
		lhs.isLoading == rhs.isLoading &&
		lhs.isButtonEnabled == rhs.isButtonEnabled &&
		lhs.isButtonHidden == rhs.isButtonHidden &&
		lhs.detectionIntervalLabelHidden == rhs.detectionIntervalLabelHidden &&
		lhs.lastUpdateDate == rhs.lastUpdateDate &&
		lhs.detectionInterval == rhs.detectionInterval
	}
}
