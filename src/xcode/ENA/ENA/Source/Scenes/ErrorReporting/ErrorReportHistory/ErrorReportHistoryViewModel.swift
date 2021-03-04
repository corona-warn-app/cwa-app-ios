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
						.bodyWithoutTopInset(text: AppStrings.ErrorReport.historyDescription, style: .textView([]), accessibilityIdentifier: AccessibilityIdentifiers.ErrorReport.historyDescription)
					]
				)
			)
			$0.add(
				.section(
					separators: .all,
					cells: buildHistoryCells()
				)
			)
		}
	}
	
	var numberOfHistoryCells: Int {
		return ids.count
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
									// TO DO: placeholder text should be replaced
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
