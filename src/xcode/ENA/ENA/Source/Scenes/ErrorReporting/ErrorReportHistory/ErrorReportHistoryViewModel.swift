//
// 🦠 Corona-Warn-App
//

import UIKit

final class ErrorReportHistoryViewModel {

	// MARK: - Init

	init(historyItems: [ErrorLogUploadReceipt]) {
		self.items = historyItems
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

	// MARK: - Private

	let items: [ErrorLogUploadReceipt]

	private func buildHistoryCells() -> [DynamicCell] {
		var cells: [DynamicCell] = []
		for item in items {
			cells.append(.custom(
				withIdentifier: ErrorReportHistoryViewController.CustomCellReuseIdentifiers.historyCell,
						 configure: { _, cell, _ in
							 guard let cell = cell as? ErrorReportHistoryCell else { return }
							 cell.configure(
								dateTimeLabel: NSMutableAttributedString(
									// TO DO: placeholder date should be replaced
									string: ENAFormatter.getDateTimeString(date: Date())
								),
								idLabel: NSMutableAttributedString(
									string: String(format: AppStrings.ErrorReport.historyCellID, item.id)
								))
						 }
					 ))
		}
		return cells
	}
}
