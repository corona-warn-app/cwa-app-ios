//
// Corona-Warn-App
//
// SAP SE and all other contributors /
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

import Foundation
import UIKit

extension RiskLegendViewController {
	var model: DynamicTableViewModel {
		DynamicTableViewModel([
			.navigationSubtitle(text: AppStrings.RiskLegend.subtitle,
								accessibilityIdentifier: "AppStrings.RiskLegend.subtitle"),
			.section(
				header: .image(UIImage(named: "Illu_Legende-Overview"),
							   accessibilityLabel: AppStrings.RiskLegend.titleImageAccLabel,
							   accessibilityIdentifier: "AppStrings.RiskLegend.titleImageAccLabel",
							   height: 200),
				footer: .space(height: 32),
				cells: [
					.iconTitle(number: 1, text: AppStrings.RiskLegend.legend1Title),
					.body(text: AppStrings.RiskLegend.legend1Text,
						  accessibilityIdentifier: "AppStrings.RiskLegend.legend1Text")
				]
			),
			.section(
				footer: .space(height: 32),
				cells: [
					.iconTitle(number: 2, text: AppStrings.RiskLegend.legend2Title),
					.body(text: AppStrings.RiskLegend.legend2Text,
						  accessibilityIdentifier: "AppStrings.RiskLegend.legend2Text"),
					.space(height: 8),
					.headline(text: AppStrings.RiskLegend.legend2RiskLevels,
							  accessibilityIdentifier: "AppStrings.RiskLegend.legend2RiskLevels"),
					.space(height: 8),
					.dotBodyCell(color: .preferredColor(for: .negativeRisk), text: AppStrings.RiskLegend.legend2High),
					.dotBodyCell(color: .preferredColor(for: .positiveRisk), text: AppStrings.RiskLegend.legend2Low),
					.dotBodyCell(color: .preferredColor(for: .unknownRisk), text: AppStrings.RiskLegend.legend2Unknown)
				]
			),
			.section(
				footer: .separator(color: .preferredColor(for: .separator), insets: UIEdgeInsets(top: 32, left: 0, bottom: 32, right: 0)),
				cells: [
					.iconTitle(number: 3, text: AppStrings.RiskLegend.legend3Title),
					.body(text: AppStrings.RiskLegend.legend3Text,
						  accessibilityIdentifier: "AppStrings.RiskLegend.legend3Text")
				]
			),
			.section(
				footer: .space(height: 8),
				cells: [
					.title2(text: AppStrings.RiskLegend.definitionsTitle,
							accessibilityIdentifier: "AppStrings.RiskLegend.definitionsTitle")
				]
			),
			.section(
				cells: [
					.headlineWithoutBottomInset(text: AppStrings.RiskLegend.storeTitle,
												accessibilityIdentifier: "AppStrings.RiskLegend.storeTitle"),
					.body(text: AppStrings.RiskLegend.storeText,
						  accessibilityIdentifier: "AppStrings.RiskLegend.storeText")
				]
			),
			.section(
				header: .space(height: 16),
				cells: [
					.headlineWithoutBottomInset(text: AppStrings.RiskLegend.checkTitle,
												accessibilityIdentifier: "AppStrings.RiskLegend.checkTitle"),
					.body(text: AppStrings.RiskLegend.checkText,
						  accessibilityIdentifier: "AppStrings.RiskLegend.checkText")
				]
			),
			.section(
				header: .space(height: 16),
				cells: [
					.headlineWithoutBottomInset(text: AppStrings.RiskLegend.contactTitle,
												accessibilityIdentifier: "AppStrings.RiskLegend.contactTitle"),
					.body(text: AppStrings.RiskLegend.contactText,
						  accessibilityIdentifier: "AppStrings.RiskLegend.contactText")
				]
			),
			.section(
				header: .space(height: 16),
				cells: [
					.headlineWithoutBottomInset(text: AppStrings.RiskLegend.notificationTitle,
												accessibilityIdentifier: "AppStrings.RiskLegend.notificationTitle"),
					.body(text: AppStrings.RiskLegend.notificationText,
						  accessibilityIdentifier: "AppStrings.RiskLegend.notificationText")
				]
			),
			.section(
				header: .space(height: 16),
				cells: [
					.headlineWithoutBottomInset(text: AppStrings.RiskLegend.randomTitle,
												accessibilityIdentifier: "AppStrings.RiskLegend.randomTitle"),
					.body(text: AppStrings.RiskLegend.randomText,
						  accessibilityIdentifier: "AppStrings.RiskLegend.randomText")
				]
			)
		])
	}
}

private extension DynamicCell {
	static func headlineWithoutBottomInset(text: String, accessibilityIdentifier: String?) -> Self {
		.headline(text: text, accessibilityIdentifier: accessibilityIdentifier) { _, cell, _ in
			cell.contentView.preservesSuperviewLayoutMargins = false
			cell.contentView.layoutMargins.bottom = 0
			cell.accessibilityIdentifier = accessibilityIdentifier
		}
	}

	static func iconTitle(number: UInt8, text: String) -> Self {
		.identifier(RiskLegendViewController.CellReuseIdentifier.numberedTitle) { _, cell, _ in
			guard let cell = cell as? RiskLegendNumberedTitleCell else { return }
			cell.numberLabel.text = "\(number)"
			cell.textLabel?.text = text
		}
	}

	static func dotBodyCell(color: UIColor, text: String) -> Self {
		.identifier(RiskLegendViewController.CellReuseIdentifier.dotBody) { _, cell, _ in
			guard let cell = cell as? RiskLegendDotBodyCell else { return }
			cell.dotView.backgroundColor = color
			cell.textLabel?.text = text
		}
	}
}
