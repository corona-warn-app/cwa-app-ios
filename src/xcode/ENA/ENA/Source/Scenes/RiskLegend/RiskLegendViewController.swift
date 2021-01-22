//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class RiskLegendViewController: DynamicTableViewController {

	// MARK: - Init

	init(
		onDismiss: @escaping () -> Void
	) {
		self.onDismiss = onDismiss
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupTableView()

		navigationItem.rightBarButtonItem = CloseBarButtonItem(
			onTap: { [weak self] in
				self?.onDismiss()
			}
		)

		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.title = AppStrings.RiskLegend.title

		view.backgroundColor = .enaColor(for: .background)

		dynamicTableViewModel = model
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		cell.backgroundColor = .clear
		return cell
	}

	// MARK: - Internal

	enum CellReuseIdentifier: String, TableViewCellReuseIdentifiers {
		case numberedTitle = "numberedTitleCell"
		case dotBody = "RiskLegendDotBodyCell"
	}

	let onDismiss: () -> Void

	// MARK: - Private

	private func setupTableView() {
		tableView.separatorStyle = .none
		tableView.register(
			RiskLegendDotBodyCell.self,
			forCellReuseIdentifier: RiskLegendViewController.CellReuseIdentifier.dotBody.rawValue
		)
	}

	private var model: DynamicTableViewModel {
		DynamicTableViewModel([
			.navigationSubtitle(
				text: AppStrings.RiskLegend.subtitle,
				accessibilityIdentifier: AccessibilityIdentifiers.RiskLegend.subtitle),
			.section(
				header: .image(UIImage(named: "Illu_Legende-Overview"),
							   accessibilityLabel: AppStrings.RiskLegend.titleImageAccLabel,
							   accessibilityIdentifier: AccessibilityIdentifiers.RiskLegend.titleImageAccLabel,
							   height: 200),
				footer: .space(height: 32),
				cells: [
					.icon(UIImage(named: "Icons_Ueberblick_1"), text: .string(AppStrings.RiskLegend.legend1Title), style: .title2) { _, cell, _ in cell.accessibilityTraits = .header },
					.body(
						text: AppStrings.RiskLegend.legend1Text,
						accessibilityIdentifier: AccessibilityIdentifiers.RiskLegend.legend1Text)
				]
			),
			.section(
				footer: .space(height: 32),
				cells: [
					.icon(UIImage(named: "Icons_Ueberblick_2"), text: .string(AppStrings.RiskLegend.legend2Title), style: .title2) { _, cell, _ in cell.accessibilityTraits = .header },
					.body(
						text: AppStrings.RiskLegend.legend2Text,
						accessibilityIdentifier: AccessibilityIdentifiers.RiskLegend.legend2Text),
					.space(height: 8),
					.headline(
						text: AppStrings.RiskLegend.legend2RiskLevels,
						accessibilityIdentifier: AccessibilityIdentifiers.RiskLegend.legend2RiskLevels),
					.space(height: 8),
					.dotBodyCell(
						color: .enaColor(for: .riskHigh),
						text: AppStrings.RiskLegend.legend2High,
						accessibilityLabelColor: AppStrings.ExposureDetection.highColorName,
						accessibilityIdentifier: AccessibilityIdentifiers.RiskLegend.legend2High),
					.dotBodyCell(
						color: .enaColor(for: .riskLow),
						text: AppStrings.RiskLegend.legend2Low,
						accessibilityLabelColor: AppStrings.ExposureDetection.lowColorName,
						accessibilityIdentifier: AccessibilityIdentifiers.RiskLegend.legend2LowColor)
				]
			),
			.section(
				footer: .separator(color: .enaColor(for: .hairline), insets: UIEdgeInsets(top: 32, left: 0, bottom: 32, right: 0)),
				cells: [
					.icon(UIImage(named: "Icons_Ueberblick_3"), text: .string(AppStrings.RiskLegend.legend3Title), style: .title2) { _, cell, _ in cell.accessibilityTraits = .header },
					.body(
						text: AppStrings.RiskLegend.legend3Text,
						accessibilityIdentifier: AccessibilityIdentifiers.RiskLegend.legend3Text)
				]
			),
			.section(
				footer: .space(height: 8),
				cells: [
					.title2(
						text: AppStrings.RiskLegend.definitionsTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.RiskLegend.definitionsTitle)
				]
			),
			.section(
				cells: [
					.headlineWithoutBottomInset(
						text: AppStrings.RiskLegend.storeTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.RiskLegend.storeTitle),
					.body(
						text: AppStrings.RiskLegend.storeText,
						accessibilityIdentifier: AccessibilityIdentifiers.RiskLegend.storeText)
				]
			),
			.section(
				header: .space(height: 16),
				cells: [
					.headlineWithoutBottomInset(
						text: AppStrings.RiskLegend.checkTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.RiskLegend.checkTitle),
					.body(
						text: AppStrings.RiskLegend.checkText,
						accessibilityIdentifier: AccessibilityIdentifiers.RiskLegend.checkText)
				]
			),
			.section(
				header: .space(height: 16),
				cells: [
					.headlineWithoutBottomInset(
						text: AppStrings.RiskLegend.contactTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.RiskLegend.contactTitle),
					.body(
						text: AppStrings.RiskLegend.contactText,
						accessibilityIdentifier: AccessibilityIdentifiers.RiskLegend.contactText)
				]
			),
			.section(
				header: .space(height: 16),
				cells: [
					.headlineWithoutBottomInset(
						text: AppStrings.RiskLegend.notificationTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.RiskLegend.notificationTitle),
					.body(
						text: AppStrings.RiskLegend.notificationText,
						accessibilityIdentifier:AccessibilityIdentifiers.RiskLegend.notificationText)
				]
			),
			.section(
				header: .space(height: 16),
				cells: [
					.headlineWithoutBottomInset(
						text: AppStrings.RiskLegend.randomTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.RiskLegend.randomTitle),
					.body(
						text: AppStrings.RiskLegend.randomText,
						accessibilityIdentifier: AccessibilityIdentifiers.RiskLegend.randomText)
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

	static func dotBodyCell(color: UIColor, text: String, accessibilityLabelColor: String, accessibilityIdentifier: String?) -> Self {
		.identifier(RiskLegendViewController.CellReuseIdentifier.dotBody) { _, cell, _ in
			guard let cell = cell as? RiskLegendDotBodyCell else { return }
			cell.dotView.backgroundColor = color
			cell.label.text = text
			cell.accessibilityLabel = "\(text)\n\n\(accessibilityLabelColor)"
			cell.accessibilityIdentifier = accessibilityIdentifier
		}
	}
}
