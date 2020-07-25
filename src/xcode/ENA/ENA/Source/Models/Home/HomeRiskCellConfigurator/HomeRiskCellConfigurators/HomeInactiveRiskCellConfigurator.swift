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

	private var previousRiskLevel: EitherLowOrIncreasedRiskLevel?
	private var lastUpdateDate: Date?

	enum InactiveType {
		case noCalculationPossible
		case outdatedResults
	}

	var inactiveType: InactiveType = .noCalculationPossible

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
			return AppStrings.Home.riskCardNoDateTitle
		}
	}

	// MARK: Creating a Home Risk Cell Configurator

	init(
		inactiveType: InactiveType,
		previousRiskLevel: EitherLowOrIncreasedRiskLevel?,
		lastUpdateDate: Date?
	) {
		self.inactiveType = inactiveType
		self.previousRiskLevel = previousRiskLevel
		self.lastUpdateDate = lastUpdateDate
	}

	// MARK: Configuration

	func configure(cell: RiskInactiveCollectionViewCell) {
		cell.delegate = self

		let title: String = inactiveType == .noCalculationPossible ? AppStrings.Home.riskCardInactiveNoCalculationPossibleTitle : AppStrings.Home.riskCardInactiveOutdatedResultsTitle
		let titleColor: UIColor = .enaColor(for: .textPrimary1)
		cell.configureTitle(title: title, titleColor: titleColor)

		let bodyText: String = inactiveType == .noCalculationPossible ? AppStrings.Home.riskCardInactiveNoCalculationPossibleBody : AppStrings.Home.riskCardInactiveOutdatedResultsBody
		cell.configureBody(text: bodyText, bodyColor: titleColor)

		let color: UIColor = .enaColor(for: .background)
		let separatorColor: UIColor = .enaColor(for: .hairline)
		var itemCellConfigurators: [HomeRiskViewConfiguratorAny] = []

		let previousRiskTitle: String
		switch previousRiskLevel {
		case .low?:
			previousRiskTitle = AppStrings.Home.riskCardInactiveActiveItemLowTitle
		case .increased?:
			previousRiskTitle = AppStrings.Home.riskCardInactiveActiveItemHighTitle
		default:
			previousRiskTitle = AppStrings.Home.riskCardInactiveActiveItemUnknownTitle
		}

		let activateItemTitle = String(format: AppStrings.Home.riskCardInactiveActivateItemTitle, previousRiskTitle)
		let iconTintColor: UIColor = .enaColor(for: .riskNeutral)
		let item1 = HomeRiskImageItemViewConfigurator(title: activateItemTitle, titleColor: titleColor, iconImageName: "Icons_LetzteErmittlung-Light", iconTintColor: iconTintColor, color: color, separatorColor: separatorColor)
		let dateTitle = String(format: AppStrings.Home.riskCardDateItemTitle, lastUpdateDateString)
		let item2 = HomeRiskImageItemViewConfigurator(title: dateTitle, titleColor: titleColor, iconImageName: "Icons_Aktualisiert", iconTintColor: iconTintColor, color: color, separatorColor: separatorColor)
		itemCellConfigurators.append(contentsOf: [item1, item2])

		cell.configureRiskViews(cellConfigurators: itemCellConfigurators)
		cell.configureBackgroundColor(color: color)

		let buttonTitle: String = inactiveType == .noCalculationPossible ? AppStrings.Home.riskCardInactiveNoCalculationPossibleButton : AppStrings.Home.riskCardInactiveOutdatedResultsButton

		cell.configureActiveButton(title: buttonTitle)

		setupAccessibility(cell)

	}

	func setupAccessibility(_ cell: RiskInactiveCollectionViewCell) {
		cell.titleLabel.isAccessibilityElement = false
		cell.chevronImageView.isAccessibilityElement = false
		cell.viewContainer.isAccessibilityElement = false
		cell.stackView.isAccessibilityElement = false

		cell.topContainer.isAccessibilityElement = true
		cell.bodyLabel.isAccessibilityElement = true

		let topContainerText = cell.titleLabel.text ?? ""
		cell.topContainer.accessibilityLabel = topContainerText
		cell.topContainer.accessibilityTraits = [.button, .header]
	}

	// MARK: Hashable

	func hash(into hasher: inout Swift.Hasher) {
		hasher.combine(inactiveType)
		hasher.combine(previousRiskLevel)
		hasher.combine(lastUpdateDate)
	}

	static func == (lhs: HomeInactiveRiskCellConfigurator, rhs: HomeInactiveRiskCellConfigurator) -> Bool {
		lhs.inactiveType == rhs.inactiveType &&
		lhs.previousRiskLevel == rhs.previousRiskLevel &&
		lhs.lastUpdateDate == rhs.lastUpdateDate
	}
	
}

extension HomeInactiveRiskCellConfigurator: RiskInactiveCollectionViewCellDelegate {
	func activeButtonTapped(cell: RiskInactiveCollectionViewCell) {
		activeAction?()
	}
}
