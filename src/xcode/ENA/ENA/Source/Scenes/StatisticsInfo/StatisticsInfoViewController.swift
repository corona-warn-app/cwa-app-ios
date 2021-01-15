//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class StatisticsInfoViewController: DynamicTableViewController {

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
		navigationItem.title = AppStrings.Statistics.Info.title

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
			UINib(nibName: String(describing: RiskLegendDotBodyCell.self), bundle: nil),
			forCellReuseIdentifier: RiskLegendViewController.CellReuseIdentifier.dotBody.rawValue
		)

		tableView.register(
			UINib(nibName: "ExposureDetectionLinkCell", bundle: nil),
			forCellReuseIdentifier: ExposureDetectionViewController.ReusableCellIdentifier.link.rawValue
		)
	}

	private var model: DynamicTableViewModel {
		DynamicTableViewModel([
			.navigationSubtitle(
				text: AppStrings.Statistics.Info.subtitle,
				accessibilityIdentifier: nil
			),
			.section(
				header: .image(UIImage(named: "Illu_StatisticsInfo"),
							   accessibilityLabel: AppStrings.Statistics.Info.titleImageAccLabel,
							   accessibilityIdentifier: nil,
							   height: 200),
				footer: .space(height: 16),
				cells: [
					.title2(
						text: AppStrings.Statistics.Info.infectionsTitle,
						accessibilityIdentifier: nil
					) { _, cell, _ in cell.accessibilityTraits = .header },
					.body(
						text: AppStrings.Statistics.Info.infectionsText,
						accessibilityIdentifier: nil
					)
				]
			),
			.section(
				footer: .space(height: 16),
				cells: [
					.title2(
						text: AppStrings.Statistics.Info.keySubmissionsTitle,
						accessibilityIdentifier: nil
					) { _, cell, _ in cell.accessibilityTraits = .header },
					.body(
						text: AppStrings.Statistics.Info.keySubmissionsText,
						accessibilityIdentifier: nil
					)
				]
			),
			.section(
				footer: .space(height: 16),
				cells: [
					.title2(
						text: AppStrings.Statistics.Info.incidenceTitle,
						accessibilityIdentifier: nil
					) { _, cell, _ in cell.accessibilityTraits = .header },
					.body(
						text: AppStrings.Statistics.Info.incidenceText,
						accessibilityIdentifier: nil
					)
				]
			),
			.section(
				footer: .space(height: 16),
				cells: [
					.title2(
						text: AppStrings.Statistics.Info.reproductionNumberTitle,
						accessibilityIdentifier: nil
					) { _, cell, _ in cell.accessibilityTraits = .header },
					.body(
						text: AppStrings.Statistics.Info.reproductionNumberText,
						accessibilityIdentifier: nil
					)
				]
			),
			.section(
				footer: .separator(color: .enaColor(for: .hairline), insets: UIEdgeInsets(top: 32, left: 0, bottom: 32, right: 0)),
				cells: [
					.body(
						text: AppStrings.Statistics.Info.faqLinkText,
						accessibilityIdentifier: nil
					),
					.link(
						text: AppStrings.Statistics.Info.faqLinkTitle,
						url: URL(string: AppStrings.Statistics.Info.faqLink)
					)
				]
			),
			.section(
				footer: .space(height: 8),
				cells: [
					.title2(
						text: AppStrings.Statistics.Info.definitionsTitle,
						accessibilityIdentifier: nil
					)
				]
			),
			.section(
				cells: [
					.headlineWithoutBottomInset(
						text: AppStrings.Statistics.Info.periodTitle,
						accessibilityIdentifier: nil
					),
					.space(height: 8),
					.headlineWithoutBottomInset(
						text: AppStrings.Statistics.Info.yesterdayTitle,
						color: .enaColor(for: .textPrimary2),
						accessibilityIdentifier: nil
					),
					.body(
						text: AppStrings.Statistics.Info.yesterdayText,
						accessibilityIdentifier: nil
					),
					.space(height: 8),
					.headlineWithoutBottomInset(
						text: AppStrings.Statistics.Info.meanTitle,
						color: .enaColor(for: .textPrimary2),
						accessibilityIdentifier: nil
					),
					.body(
						text: AppStrings.Statistics.Info.meanText,
						accessibilityIdentifier: nil
					),
					.space(height: 8),
					.headlineWithoutBottomInset(
						text: AppStrings.Statistics.Info.totalTitle,
						color: .enaColor(for: .textPrimary2),
						accessibilityIdentifier: nil
					),
					.body(
						text: AppStrings.Statistics.Info.totalText,
						accessibilityIdentifier: nil
					)
				]
			),
			.section(
				header: .space(height: 16),
				footer: .space(height: 16),
				cells: [
					.headlineWithoutBottomInset(
						text: AppStrings.Statistics.Info.trendTitle,
						accessibilityIdentifier: nil
					),
					.body(
						text: AppStrings.Statistics.Info.trendText,
						accessibilityIdentifier: nil
					),
					.space(height: 8),
					.headlineWithoutBottomInset(
						text: AppStrings.Statistics.Info.trendsTitle,
						accessibilityIdentifier: nil
					),
					.icon(UIImage(named: "Pfeil_steigend"), text: .string(AppStrings.Statistics.Info.trendsIncreasing), iconWidth: 19),
					.icon(UIImage(named: "Pfeil_sinkend"), text: .string(AppStrings.Statistics.Info.trendsDecreasing), iconWidth: 19),
					.icon(UIImage(named: "Pfeil_stabil"), text: .string(AppStrings.Statistics.Info.trendsStable), iconWidth: 19),
					.footnote(
						text: AppStrings.Statistics.Info.trendsFootnote,
						accessibilityIdentifier: nil
					)
				]
			)
		])
	}
}

private extension DynamicCell {
	static func headlineWithoutBottomInset(text: String, color: UIColor? = nil, accessibilityIdentifier: String?) -> Self {
		.headline(text: text, color: color, accessibilityIdentifier: accessibilityIdentifier) { _, cell, _ in
			cell.contentView.preservesSuperviewLayoutMargins = false
			cell.contentView.layoutMargins.bottom = 0
			cell.accessibilityIdentifier = accessibilityIdentifier
		}
	}

	static func dotBodyCell(color: UIColor, text: String, accessibilityLabelColor: String, accessibilityIdentifier: String?) -> Self {
		.identifier(RiskLegendViewController.CellReuseIdentifier.dotBody) { _, cell, _ in
			guard let cell = cell as? RiskLegendDotBodyCell else { return }
			cell.dotView.backgroundColor = color
			cell.textLabel?.text = text
			cell.accessibilityLabel = "\(text)\n\n\(accessibilityLabelColor)"
			cell.accessibilityIdentifier = accessibilityIdentifier
		}
	}
}
