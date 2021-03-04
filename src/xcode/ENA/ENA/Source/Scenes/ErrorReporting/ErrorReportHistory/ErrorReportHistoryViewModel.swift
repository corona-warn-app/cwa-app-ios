//
// 🦠 Corona-Warn-App
//

import UIKit

final class ErrorReportHistoryViewModel {

	// MARK: - Init

	init() {
		// TO DO: should be replaced by Ids
		self.ids = ["001", "002", "003", "004", "005"]
	}

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					separators: .none,
					cells: [
						.title1(text: AppStrings.ErrorReport.historyTitle, accessibilityIdentifier: AccessibilityIdentifiers.ErrorReport.historyTitle),
						.subheadline(text: AppStrings.ErrorReport.historyDescription, accessibilityIdentifier: AccessibilityIdentifiers.ErrorReport.historyDescription)
					]
				)
			)
			$0.add(
				.section(
					separators: .inBetween,
					cells: buildHistoryCells()
				)
			)
		}
	}

	// MARK: - Private

	private let ids: [String]

	private func buildHistoryCells() -> [DynamicCell] {
		var cells: [DynamicCell] = []
		for id in ids {
			cells.append(.custom(
				withIdentifier: ErrorReportHistoryViewController.CustomCellReuseIdentifiers.historyCell,
						 configure: { _, cell, _ in
							 guard let cell = cell as? ErrorReportHistoryCell else { return }
							 cell.configure(
								dateTimeLabel: NSMutableAttributedString(
									// TO DO: Adding date and time in dateTimeLabel
								    string: String(format: AppStrings.ErrorReport.historyCellDateTime, "22.02.22", "09:32")
								),
								idLabel: NSMutableAttributedString(
									string: String(format: AppStrings.ErrorReport.historyCellID, id)
								))
						 }
					 ))
		}
		return cells
	}
}
