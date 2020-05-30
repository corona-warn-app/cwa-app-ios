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

final class HomeInactiveRiskCellConfigurator: HomeRiskCellConfigurator {
	private var lastUpdateDate: Date?
	private var lastInvestigation: String

	// MARK: Creating a Home Risk Cell Configurator

	init(isLoading: Bool, isButtonEnabled: Bool, lastInvestigation: String, lastUpdateDate: Date?) {
		self.lastUpdateDate = lastUpdateDate
		self.lastInvestigation = lastInvestigation
		super.init(isLoading: isLoading, isButtonEnabled: isButtonEnabled, isButtonHidden: false, isCounterLabelHidden: true, startDate: nil, releaseDate: nil, lastUpdateDate: lastUpdateDate)
	}

	// MARK: Configuration

	override func configure(cell: RiskCollectionViewCell) {
		cell.delegate = self

		cell.removeAllArrangedSubviews()

		let title: String = isLoading ? AppStrings.Home.riskCardStatusCheckTitle : AppStrings.Home.riskCardInactiveTitle
		let titleColor: UIColor = .black
		cell.configureTitle(title: title, titleColor: titleColor)

		let bodyText = AppStrings.Home.riskCardInactiveBody
		cell.configureBody(text: bodyText, bodyColor: titleColor, isHidden: false)

		let color = UIColor.white
		let separatorColor = UIColor.systemGray5
		var itemCellConfigurators: [HomeRiskViewConfiguratorAny] = []
		if isLoading {
			let isLoadingItem = HomeRiskLoadingItemViewConfigurator(title: AppStrings.Home.riskCardStatusCheckBody, titleColor: titleColor, isLoading: true, color: color, separatorColor: separatorColor)
			itemCellConfigurators.append(isLoadingItem)
		} else {
			let lastInvestigationTitle = String(format: AppStrings.Home.riskCardInactiveActivateItemTitle, lastInvestigation)
			let iconTintColor = UIColor(red: 93.0 / 255.0, green: 111.0 / 255.0, blue: 128.0 / 255.0, alpha: 1.0)
			let item1 = HomeRiskImageItemViewConfigurator(title: lastInvestigationTitle, titleColor: titleColor, iconImageName: "exposure-detection-last-risk-level-contrast", iconTintColor: iconTintColor, color: color, separatorColor: separatorColor)

			let dateTitle = String(format: AppStrings.Home.riskCardInactiveDateItemTitle, lastUpdateDateString)
			let item2 = HomeRiskImageItemViewConfigurator(title: dateTitle, titleColor: titleColor, iconImageName: "exposure-detection-refresh-contrast", iconTintColor: iconTintColor, color: color, separatorColor: separatorColor)
			itemCellConfigurators.append(contentsOf: [item1, item2])
		}
		cell.configureRiskViews(cellConfigurators: itemCellConfigurators)
		cell.configureBackgroundColor(color: color)

		cell.configureChevron(image: UIImage(systemName: "chevron.right.circle.fill"), tintColor: .lightGray)

		let buttonTitle: String = isLoading ? AppStrings.Home.riskCardStatusCheckButton : AppStrings.Home.riskCardInactiveButton

		cell.configureCounterLabel(text: "", isHidden: isCounterLabelHidden)
		cell.configureUpdateButton(
			title: buttonTitle,
			color: .preferredColor(for: .tintColor),
			backgroundColor: .systemGray5,
			isEnabled: isButtonEnabled,
			isHidden: isButtonHidden
		)
	}
}
