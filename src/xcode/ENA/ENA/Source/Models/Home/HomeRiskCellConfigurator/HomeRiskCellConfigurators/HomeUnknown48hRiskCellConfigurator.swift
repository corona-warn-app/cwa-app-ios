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

	private var previousRiskLevel: EitherLowOrIncreasedRiskLevel?

	// MARK: Creating a unknown 48h Risk cell
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

	// MARK: - Computed properties.

	var title: String {
		return isLoading ? AppStrings.Home.riskCardStatusCheckTitle : AppStrings.Home.riskCardUnknownTitle
	}

	var previousRiskTitle: String {
		switch previousRiskLevel {
		case .low?:
			return AppStrings.Home.riskCardLastActiveItemLowTitle
		case .increased?:
			return AppStrings.Home.riskCardLastActiveItemHighTitle
		default:
			return AppStrings.Home.riskCardLastActiveItemUnknownTitle
		}
	}

	// MARK: - UI Helper methods.

	/// Adjusts the UI for the given cell, including setting text and adjusting colors.
	private func configureUI(for cell: RiskLevelCollectionViewCell) {
		cell.configureBackgroundColor(color: .enaColor(for: .riskNeutral))
		cell.configureTitle(title: title, titleColor: .enaColor(for: .textContrast))
		cell.configureBody(text: AppStrings.Home.riskCardUnknown48hBody, bodyColor: .enaColor(for: .textContrast), isHidden: isLoading)
		configureButton(for: cell)
		let intervalTitle = String(format: AppStrings.Home.riskCardIntervalUpdateTitle, "\(detectionInterval)")
		cell.configureDetectionIntervalLabel(text: intervalTitle, isHidden: detectionIntervalLabelHidden)
	}

	/// Adjusts the UI for the risk views of a given cell.
	private func configureRiskViewsUI(for cell: RiskLevelCollectionViewCell) {
		let itemCellConfigurators = setupItemCellConfigurators()
		cell.configureRiskViews(cellConfigurators: itemCellConfigurators)
	}

	private func setupItemCellConfigurators() -> [HomeRiskViewConfiguratorAny] {
		if isLoading {
			return [
				HomeRiskLoadingItemViewConfigurator(
					title: AppStrings.Home.riskCardStatusCheckBody,
					titleColor: .enaColor(for: .textContrast),
					isLoading: true,
					color: .enaColor(for: .riskNeutral),
					separatorColor: .enaColor(for: .hairlineContrast)
				)
			]
		} else {
			let activateItemTitle = String(format: AppStrings.Home.riskCardLastActiveItemTitle, previousRiskTitle)
			let dateTitle = String(format: AppStrings.Home.riskCardDateItemTitle, lastUpdateDateString)

			return [
				// Card for the last state of the risk state.
				HomeRiskImageItemViewConfigurator(
					title: activateItemTitle,
					titleColor: .enaColor(for: .textContrast),
					iconImageName: "Icons_LetzteErmittlung-Light",
					iconTintColor: .enaColor(for: .textContrast),
					color: .enaColor(for: .riskNeutral),
					separatorColor: .enaColor(for: .hairlineContrast)),

				// Card for the last exposure date.
				HomeRiskImageItemViewConfigurator(
					title: dateTitle,
					titleColor: .enaColor(for: .textContrast),
					iconImageName: "Icons_Aktualisiert",
					iconTintColor: .enaColor(for: .textContrast),
					color: .enaColor(for: .riskNeutral),
					separatorColor: .enaColor(for: .hairlineContrast)
				)
			]
		}
	}

	// MARK: - Configuration.

	override func configure(cell: RiskLevelCollectionViewCell) {
		cell.delegate = self

		// Configure the UI.

		configureUI(for: cell)
		configureRiskViewsUI(for: cell)

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
