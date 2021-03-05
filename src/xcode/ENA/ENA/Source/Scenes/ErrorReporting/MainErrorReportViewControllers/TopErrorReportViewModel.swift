////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class TopErrorReportViewModel {
	
	// MARK: - Init
	
	init(didPressHistoryCell: @escaping () -> Void) {
		self.didPressHistoryCell = didPressHistoryCell
	}
	
	// MARK: - Internal
	
	func updateViewModel(isHistorySectionIncluded: Bool = false) {
		var dynamic = DynamicTableViewModel([])
		dynamic.add(
			.section(cells: [
				.body(text: AppStrings.ErrorReport.description1),
				.link(text: AppStrings.ErrorReport.faq, url: URL(string: "https://example.com"), accessibilityIdentifier: AccessibilityIdentifiers.ErrorReport.faq) // TO DO: get correct link!
			])
		)
		dynamic.add(
			.section(cells: [
				.acknowledgement(
					title: NSAttributedString(string: AppStrings.ErrorReport.Legal.dataPrivacy_Headline),
					description: nil,
					bulletPoints: [
						NSMutableAttributedString(string: AppStrings.ErrorReport.Legal.dataPrivacy_Bullet1),
						NSMutableAttributedString(string: AppStrings.ErrorReport.Legal.dataPrivacy_Bullet2),
						NSMutableAttributedString(string: AppStrings.ErrorReport.Legal.dataPrivacy_Bullet3),
						NSMutableAttributedString(string: AppStrings.ErrorReport.Legal.dataPrivacy_Bullet4),
						NSMutableAttributedString(string: AppStrings.ErrorReport.Legal.dataPrivacy_Bullet5)
					],
					accessibilityIdentifier: "TODO ACCESSABILITY IDENTIFIER")
			])
		)
		if isHistorySectionIncluded {
			dynamic.add(
				.section(
					separators: .all,
					cells: [
						.custom(
							withIdentifier: ErrorReportHistoryViewController.CustomCellReuseIdentifiers.historyCell,
							action: .execute(block: { [weak self] _, _ in
								self?.didPressHistoryCell()
							}),
							configure: { _, cell, _ in
								guard let cell = cell as? ErrorReportHistoryCell else { return }
								cell.accessoryType = .disclosureIndicator
								cell.selectionStyle = .default
								cell.configure(
									dateTimeLabel: NSMutableAttributedString(string: AppStrings.ErrorReport.historyTitle),
									idLabel: NSMutableAttributedString(string: AppStrings.ErrorReport.historyTitle))
							}
						)
					])
			)
		}
		dynamic.add(
			.section(
				separators: .all,
				cells: [
					.body(
						text: AppStrings.ErrorReport.privacyInformation,
						accessibilityIdentifier: AccessibilityIdentifiers.ErrorReport.privacyInformation,
						accessibilityTraits: .link,
						action: .none /* TO DO: .push model or view controller */,
						configure: { _, cell, _ in
							cell.accessoryType = .disclosureIndicator
						})
				])
		)
		dynamicTableViewModel = dynamic
	}
	
	@OpenCombine.Published var dynamicTableViewModel: DynamicTableViewModel = DynamicTableViewModel([])
	
	// MARK: - Private

	private let didPressHistoryCell: () -> Void
}
