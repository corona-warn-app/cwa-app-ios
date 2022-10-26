////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class TopErrorReportViewModel {
	
	// MARK: - Init
	
	init(
		didPressHistoryCell: @escaping () -> Void,
		didPressPrivacyInformationCell: @escaping () -> Void
		) {
		self.didPressHistoryCell = didPressHistoryCell
		self.didPressPrivacyInformationCell = didPressPrivacyInformationCell
	}
	
	// MARK: - Internal
	
	func updateViewModel(isHistorySectionIncluded: Bool) {
		var dynamic = DynamicTableViewModel([])
		dynamic.add(
			.section(cells: [
				.body(
					text: AppStrings.ErrorReport.description1,
					accessibilityIdentifier: AccessibilityIdentifiers.ErrorReport.topBody
				),
				.link(
					placeholder: AppStrings.ErrorReport.faq,
					link: AppStrings.ErrorReport.faqURL,
					font: .subheadline,
					style: .subheadline,
					accessibilityIdentifier: AccessibilityIdentifiers.ErrorReport.faq
				)
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
					accessibilityIdentifier: AccessibilityIdentifiers.ErrorReport.privacyNavigation)
			])
		)
		if isHistorySectionIncluded {
			dynamic.add(
				.section(
					header: .separator(
						color: .enaColor(for: .hairline),
						insets: .init(top: 0, left: 16, bottom: 0, right: 16)
					),
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
								cell.accessibilityIdentifier = AccessibilityIdentifiers.ErrorReport.historyNavigation
								cell.configure(
									dateTimeLabel: NSMutableAttributedString(string: AppStrings.ErrorReport.historyTitle),
									idLabel: NSMutableAttributedString(string: AppStrings.ErrorReport.historyNavigationSubline))
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
						action: .execute(block: { [weak self] _, _ in
							self?.didPressPrivacyInformationCell()
						}),
						configure: { _, cell, _ in
							cell.accessoryType = .disclosureIndicator
							cell.accessibilityIdentifier = AccessibilityIdentifiers.ErrorReport.privacyInformation
						})
				])
		)
		dynamicTableViewModel = dynamic
	}
	
	@OpenCombine.Published var dynamicTableViewModel: DynamicTableViewModel = DynamicTableViewModel([])
	
	// MARK: - Private

	private let didPressHistoryCell: () -> Void
	private let didPressPrivacyInformationCell: () -> Void
}
