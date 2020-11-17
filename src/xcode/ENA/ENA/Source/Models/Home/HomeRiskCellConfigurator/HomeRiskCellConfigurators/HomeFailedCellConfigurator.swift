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

final class HomeFailedCellConfigurator: HomeRiskCellConfigurator {

	// MARK: - Init

	init(
		previousRiskLevel: RiskLevel?,
		lastUpdateDate: Date?
	) {
		self.previousRiskLevel = previousRiskLevel
		self.lastUpdateDate = lastUpdateDate
	}

	// MARK: - Overrides

	// MARK: - Internal

	var activeAction: (() -> Void)?

	let title = AppStrings.Home.riskCardFailedCalculationTitle
	let body = AppStrings.Home.riskCardFailedCalculationBody
	let buttonTitle = AppStrings.Home.riskCardFailedCalculationRestartButtonTitle

	var previousRiskTitle: String {
		switch previousRiskLevel {
		case .low?:
			return AppStrings.Home.riskCardLastActiveItemLowTitle
		case .high?:
			return AppStrings.Home.riskCardLastActiveItemHighTitle
		default:
			return AppStrings.Home.riskCardLastActiveItemUnknownTitle
		}
	}

	func setupAccessibility(_ cell: RiskFailedCollectionViewCell) {
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

	func configure(cell: RiskFailedCollectionViewCell) {

		cell.delegate = self

		// Configuring the UI.

		configureUI(for: cell)
		configureRiskViewsUI(for: cell)

		setupAccessibility(cell)

	}

	func hash(into hasher: inout Swift.Hasher) {
		hasher.combine(previousRiskLevel)
		hasher.combine(lastUpdateDate)
	}

	static func == (lhs: HomeFailedCellConfigurator, rhs: HomeFailedCellConfigurator) -> Bool {
		lhs.previousRiskLevel == rhs.previousRiskLevel &&
		lhs.lastUpdateDate == rhs.lastUpdateDate
	}

	// MARK: - Private

	private var previousRiskLevel: RiskLevel?
	private var lastUpdateDate: Date?


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

	/// Adjusts the UI for the given cell, including setting text and adjusting colors.
	private func configureUI(for cell: RiskFailedCollectionViewCell) {
		cell.configureTitle(title: title, titleColor: .enaColor(for: .textPrimary1))
		cell.configureBody(text: body, bodyColor: .enaColor(for: .textPrimary1))
		cell.configureBackgroundColor(color: .enaColor(for: .background))
		cell.configureActiveButton(title: buttonTitle)
	}

	/// Adjusts the UI for the risk views of a given cell.
	private func configureRiskViewsUI(for cell: RiskFailedCollectionViewCell) {
		let activateItemTitle = String(format: AppStrings.Home.riskCardLastActiveItemTitle, previousRiskTitle)
		let dateTitle = String(format: AppStrings.Home.riskCardDateItemTitle, lastUpdateDateString)

		let itemCellConfigurators = [
			// Card for the last state of the risk state.
			HomeRiskImageItemViewConfigurator(
				title: activateItemTitle,
				titleColor: .enaColor(for: .textPrimary1),
				iconImageName: "Icons_LetzteErmittlung-Light",
				iconTintColor: .enaColor(for: .riskNeutral),
				color: .enaColor(for: .background),
				separatorColor: .enaColor(for: .hairline)
			),

			// Card for the last exposure date.
			HomeRiskImageItemViewConfigurator(
				title: dateTitle,
				titleColor: .enaColor(for: .textPrimary1),
				iconImageName: "Icons_Aktualisiert",
				iconTintColor: .enaColor(for: .riskNeutral),
				color: .enaColor(for: .background),
				separatorColor: .enaColor(for: .hairline)
			)

		]

		cell.configureRiskViews(cellConfigurators: itemCellConfigurators)
	}
}

// MARK: - Protocol RiskFailedCollectionViewCellDelegate

extension HomeFailedCellConfigurator: RiskFailedCollectionViewCellDelegate {
	func activeButtonTapped(cell: RiskFailedCollectionViewCell) {
		activeAction?()
	}
}
