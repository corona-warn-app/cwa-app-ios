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

	private var lastInvestigation: String
	private var lastUpdateDate: Date?

	var activeAction: (() -> Void)?

	private static let lastUpdateDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.doesRelativeDateFormatting = true
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .short
		return dateFormatter
	}()

	private var lastUpdateDateString: String {
		if let lastUpdateDate = lastUpdateDate {
			return Self.lastUpdateDateFormatter.string(from: lastUpdateDate)
		} else {
			return " - "
		}
	}

	// MARK: Creating a Home Risk Cell Configurator

	init(lastInvestigation: String, lastUpdateDate: Date?) {
		self.lastInvestigation = lastInvestigation
		self.lastUpdateDate = lastUpdateDate
	}

	// MARK: Configuration

	func configure(cell: RiskInactiveCollectionViewCell) {
		cell.delegate = self

		cell.removeAllArrangedSubviews()

		let title = AppStrings.Home.riskCardInactiveTitle
		let titleColor: UIColor = .black
		cell.configureTitle(title: title, titleColor: titleColor)

		let bodyText = AppStrings.Home.riskCardInactiveBody
		cell.configureBody(text: bodyText, bodyColor: titleColor)

		let color = UIColor.white
		let separatorColor = UIColor.systemGray5
		var itemCellConfigurators: [HomeRiskViewConfiguratorAny] = []

		let lastInvestigationTitle = String(format: AppStrings.Home.riskCardInactiveActivateItemTitle, lastInvestigation)
		let iconTintColor = UIColor(red: 93.0 / 255.0, green: 111.0 / 255.0, blue: 128.0 / 255.0, alpha: 1.0)
		let item1 = HomeRiskImageItemViewConfigurator(title: lastInvestigationTitle, titleColor: titleColor, iconImageName: "InfizierteKontakte", iconTintColor: iconTintColor, color: color, separatorColor: separatorColor)

		let dateTitle = String(format: AppStrings.Home.riskCardInactiveDateItemTitle, lastUpdateDateString)
		let item2 = HomeRiskImageItemViewConfigurator(title: dateTitle, titleColor: titleColor, iconImageName: "Calendar", iconTintColor: iconTintColor, color: color, separatorColor: separatorColor)
		itemCellConfigurators.append(contentsOf: [item1, item2])

		cell.configureRiskViews(cellConfigurators: itemCellConfigurators)
		cell.configureBackgroundColor(color: color)

		cell.configureChevron(image: UIImage(systemName: "chevron.right.circle.fill"), tintColor: .lightGray)

		let buttonTitle = AppStrings.Home.riskCardInactiveButton

		cell.configureActiveButton(
			title: buttonTitle,
			color: .preferredColor(for: .tint),
			backgroundColor: .systemGray5
		)
	}
}

extension HomeInactiveRiskCellConfigurator: RiskInactiveCollectionViewCellDelegate {
	func activeButtonTapped(cell: RiskInactiveCollectionViewCell) {
		activeAction?()
	}
}
