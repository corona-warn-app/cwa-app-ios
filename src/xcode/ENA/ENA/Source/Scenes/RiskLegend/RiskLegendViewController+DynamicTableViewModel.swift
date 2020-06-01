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
			.section(
				header: .image(UIImage(named: "risk-legend-image"), height: 200),
				footer: .space(height: 32),
				cells: [
					.iconTitle(number: 1, text: AppStrings.RiskLegend.legend1Title),
					.body(text: AppStrings.RiskLegend.legend1Text)
				]
			),
			.section(
				footer: .space(height: 32),
				cells: [
					.iconTitle(number: 2, text: AppStrings.RiskLegend.legend2Title),
					.body(text: AppStrings.RiskLegend.legend2Text),
					.space(height: 8),
					.headline(text: AppStrings.RiskLegend.legend2RiskLevels),
					.dotBodyCell(color: .preferredColor(for: .negativeRisk), text: AppStrings.RiskLegend.legend2High),
					.dotBodyCell(color: .preferredColor(for: .positiveRisk), text: AppStrings.RiskLegend.legend2Low),
					.dotBodyCell(color: .preferredColor(for: .unknownRisk), text: AppStrings.RiskLegend.legend2Unknown)
				]
			),
			.section(
				footer: .separator(color: .preferredColor(for: .separator), insets: UIEdgeInsets(top: 32, left: 0, bottom: 32, right: 0)),
				cells: [
					.iconTitle(number: 3, text: AppStrings.RiskLegend.legend3Title),
					.body(text: AppStrings.RiskLegend.legend3Text)
				]
			),
			.section(
				footer: .space(height: 8),
				cells: [
					.title2(text: AppStrings.RiskLegend.definitionsTitle)
				]
			),
			.section(cells: [
				.headline(text: AppStrings.RiskLegend.storeTitle),
				.body(text: AppStrings.RiskLegend.storeText)
			]),
			.section(cells: [
				.headline(text: AppStrings.RiskLegend.checkTitle),
				.body(text: AppStrings.RiskLegend.checkText)
			]),
			.section(cells: [
				.headline(text: AppStrings.RiskLegend.contactTitle),
				.body(text: AppStrings.RiskLegend.contactText)
			]),
			.section(cells: [
				.headline(text: AppStrings.RiskLegend.notificationTitle),
				.body(text: AppStrings.RiskLegend.notificationText)
			]),
			.section(cells: [
				.headline(text: AppStrings.RiskLegend.randomTitle),
				.body(text: AppStrings.RiskLegend.randomText)
			])
		])
	}
}

private extension DynamicCell {
	static func space(height: CGFloat, color: UIColor? = nil) -> Self {
		.identifier(RiskLegendViewController.CellReuseIdentifier.space) { _, cell, _ in
			guard let cell = cell as? DynamicTableViewSpaceCell else { return }
			cell.height = height
			cell.backgroundColor = color
		}
	}

	static func title1(text: String) -> Self {
		.identifier(RiskLegendViewController.CellReuseIdentifier.title1) { _, cell, _ in
			cell.textLabel?.text = text
		}
	}

	static func title2(text: String) -> Self {
		.identifier(RiskLegendViewController.CellReuseIdentifier.title2) { _, cell, _ in
			cell.textLabel?.text = text
		}
	}

	static func headline(text: String) -> Self {
		.identifier(RiskLegendViewController.CellReuseIdentifier.headline) { _, cell, _ in
			cell.textLabel?.text = text
		}
	}

	static func subheadline(text: String) -> Self {
		.identifier(RiskLegendViewController.CellReuseIdentifier.subheadline) { _, cell, _ in
			cell.textLabel?.text = text
		}
	}

	static func body(text: String) -> Self {
		.identifier(RiskLegendViewController.CellReuseIdentifier.body) { _, cell, _ in
			cell.textLabel?.text = text
		}
	}

	static func footnote(text: String) -> Self {
		.identifier(RiskLegendViewController.CellReuseIdentifier.footnote) { _, cell, _ in
			cell.textLabel?.text = text
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

// TODO: Refactor into DynamicTableViewController
extension DynamicTypeTableViewCell {
	class Title1: DynamicTypeTableViewCell {
		static let style: ENALabel.Style = .title1
		override var textStyle: UIFont.TextStyle? { Self.style.textStyle }
		override var fontSize: CGFloat? { Self.style.fontSize }
		override var fontWeight: UIFont.Weight? { UIFont.Weight(Self.style.fontWeight) }
	}

	class Title2: DynamicTypeTableViewCell {
		static let style: ENALabel.Style = .title2
		override var textStyle: UIFont.TextStyle? { Self.style.textStyle }
		override var fontSize: CGFloat? { Self.style.fontSize }
		override var fontWeight: UIFont.Weight? { UIFont.Weight(Self.style.fontWeight) }
	}

	class Headline: DynamicTypeTableViewCell {
		static let style: ENALabel.Style = .headline
		override var textStyle: UIFont.TextStyle? { Self.style.textStyle }
		override var fontSize: CGFloat? { Self.style.fontSize }
		override var fontWeight: UIFont.Weight? { UIFont.Weight(Self.style.fontWeight) }
	}

	class Subheadline: DynamicTypeTableViewCell {
		static let style: ENALabel.Style = .subheadline
		override var textStyle: UIFont.TextStyle? { Self.style.textStyle }
		override var fontSize: CGFloat? { Self.style.fontSize }
		override var fontWeight: UIFont.Weight? { UIFont.Weight(Self.style.fontWeight) }
	}

	class Body: DynamicTypeTableViewCell {
		static let style: ENALabel.Style = .body
		override var textStyle: UIFont.TextStyle? { Self.style.textStyle }
		override var fontSize: CGFloat? { Self.style.fontSize }
		override var fontWeight: UIFont.Weight? { UIFont.Weight(Self.style.fontWeight) }
	}

	class Footnote: DynamicTypeTableViewCell {
		static let style: ENALabel.Style = .footnote
		override var textStyle: UIFont.TextStyle? { Self.style.textStyle }
		override var fontSize: CGFloat? { Self.style.fontSize }
		override var fontWeight: UIFont.Weight? { UIFont.Weight(Self.style.fontWeight) }
	}
}
