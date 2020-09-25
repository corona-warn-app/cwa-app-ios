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

	private let titleColor: UIColor = .enaColor(for: .textContrast)
	private let color: UIColor = .enaColor(for: .riskNeutral)
	private let separatorColor: UIColor = .enaColor(for: .hairlineContrast)

	// MARK: Configuration

	// MARK: Creating a unknown Risk cell
	init(
		state: RiskProvider.ActivityState,
		lastUpdateDate: Date?,
		detectionInterval: Int,
		detectionMode: DetectionMode,
		manualExposureDetectionState: ManualExposureDetectionState?
	) {
		super.init(
			state: state,
			isButtonEnabled: manualExposureDetectionState == .possible,
			isButtonHidden: detectionMode == .automatic,
			detectionIntervalLabelHidden: detectionMode != .automatic,
			lastUpdateDate: lastUpdateDate,
			detectionInterval: detectionInterval
		)
	}

	override func configure(cell: RiskLevelCollectionViewCell) {
		var itemCellConfigurators: [HomeRiskViewConfiguratorAny] = []

		switch state {
		case .downloading:
			itemCellConfigurators += [setupDownloadingCellState(for: cell)]
		case .detecting:
			itemCellConfigurators += [setupDetectingCellState(for: cell)]
		default:
			itemCellConfigurators.append(setupNormalCellState(for: cell))

		}

		cell.delegate = self
		cell.configureBody(text: "", bodyColor: titleColor, isHidden: true)
		cell.configureRiskViews(cellConfigurators: itemCellConfigurators)
		cell.configureBackgroundColor(color: color)
		cell.configureDetectionIntervalLabel(
			text: String(format: AppStrings.Home.riskCardIntervalUpdateTitle, "\(detectionInterval)"),
			isHidden: detectionIntervalLabelHidden
		)

		configureButton(for: cell)
		setupAccessibility(cell)
	}

	// MARK: - Configuration helpers.

	private func setupDownloadingCellState(for cell: RiskLevelCollectionViewCell) -> HomeRiskViewConfiguratorAny {
		cell.configureTitle(title: AppStrings.Home.riskCardStatusDownloadingTitle, titleColor: titleColor)
		return HomeRiskLoadingItemViewConfigurator(title: AppStrings.Home.riskCardStatusDownloadingBody, titleColor: titleColor, isActivityIndicatorOn: true, color: color, separatorColor: separatorColor)
	}

	private func setupDetectingCellState(for cell: RiskLevelCollectionViewCell) -> HomeRiskViewConfiguratorAny {
		cell.configureTitle(title: AppStrings.Home.riskCardStatusDetectingTitle, titleColor: titleColor)
		return HomeRiskLoadingItemViewConfigurator(title: AppStrings.Home.riskCardStatusDetectingBody, titleColor: titleColor, isActivityIndicatorOn: true, color: color, separatorColor: separatorColor)
	}

	private func setupNormalCellState(for cell: RiskLevelCollectionViewCell) -> HomeRiskViewConfiguratorAny {
		cell.configureTitle(title: AppStrings.Home.riskCardUnknownTitle, titleColor: titleColor)
		return HomeRiskTextItemViewConfigurator(title: AppStrings.Home.riskCardUnknownItemTitle, titleColor: titleColor, color: color, separatorColor: separatorColor)
	}


	// MARK: Hashable

	override func hash(into hasher: inout Swift.Hasher) {
		super.hash(into: &hasher)
	}

	static func == (lhs: HomeUnknownRiskCellConfigurator, rhs: HomeUnknownRiskCellConfigurator) -> Bool {
		lhs.state == rhs.state &&
		lhs.isButtonEnabled == rhs.isButtonEnabled &&
		lhs.isButtonHidden == rhs.isButtonHidden &&
		lhs.detectionIntervalLabelHidden == rhs.detectionIntervalLabelHidden &&
		lhs.lastUpdateDate == rhs.lastUpdateDate &&
		lhs.detectionInterval == rhs.detectionInterval
	}
}
