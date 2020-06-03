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

	override func configure(cell: RiskLevelCollectionViewCell) {
		cell.delegate = self

		let title: String = isLoading ? AppStrings.Home.riskCardStatusCheckTitle : AppStrings.Home.riskCardUnknownTitle
		let titleColor: UIColor = .white
		cell.configureTitle(title: title, titleColor: titleColor)
		cell.configureBody(text: "", bodyColor: titleColor, isHidden: true)

		let color = UIColor.preferredColor(for: .unknownRisk)
		let separatorColor = UIColor.white.withAlphaComponent(0.15)
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

		cell.configureChevron(image: UIImage(systemName: "chevron.right.circle.fill"), tintColor: .preferredColor(for: .chevron))

		let buttonTitle: String = isLoading ? AppStrings.Home.riskCardStatusCheckButton : AppStrings.Home.riskCardUnknownButton

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
