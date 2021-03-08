////
// 🦠 Corona-Warn-App
//

import UIKit

class SendErrorLogsViewModel {
	
	// MARK: - Init
	
	init(didPressDetailsButton: @escaping () -> Void) {
		self.didPressDetailsButton = didPressDetailsButton
	}
	
	// MARK: - Private
	
	var sendErrorLogsDynamicViewModel: DynamicTableViewModel {
		var model = DynamicTableViewModel([])
		
		model.add(
			.section(cells: [
				.body(text: AppStrings.ErrorReport.sendReportsParagraph)
			])
		)
		model.add(
			.section(cells: [
				.legalExtendedParagraph(
					title: NSAttributedString(string: AppStrings.ErrorReport.Legal.sendReports_Headline),
					subheadline1: NSAttributedString(
						string: AppStrings.ErrorReport.Legal.sendReports_Subline,
						attributes: [
							.font: UIFont.preferredFont(forTextStyle: .body)
						]
					),
					bulletPoints: bulletPoints,
					subheadline2: NSAttributedString(
						string: AppStrings.ErrorReport.Legal.sendReports_Paragraph,
						attributes: [
							.font: UIFont.preferredFont(forTextStyle: .body)
						]
					),
					accessibilityIdentifier: "",
					spacing: 10
				)
			])
		)
		model.add(
			.section(separators: .all,
					 cells: [
				.body(
					text: AppStrings.ErrorReport.sendReportsDetails,
					style: DynamicCell.TextCellStyle.label,
					accessibilityIdentifier: "TODO ACCESSABILITY IDENTIFIER",
					accessibilityTraits: UIAccessibilityTraits.link,
					action: .execute(block: { [weak self] _, _ in
						self?.didPressDetailsButton()
					}),
					configure: { _, cell, _ in
						cell.accessoryType = .disclosureIndicator
						cell.selectionStyle = .default
					})
			])
		)
		return model
	}
	
	private var bulletPoints: [NSAttributedString] {
		var points = [NSAttributedString]()

		// highlighted texts
		let attributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.preferredFont(forTextStyle: .headline)
		]

		let bullet1 = NSMutableAttributedString(string: "\(AppStrings.ErrorReport.Legal.sendReports_Bullet1_Part1)\(AppStrings.ErrorReport.Legal.sendReports_Bullet1_Part2)")
		bullet1.addAttributes(attributes, range: NSRange(location: 0, length: AppStrings.ErrorReport.Legal.sendReports_Bullet1_Part1.count))
		
		let bullet2 = NSMutableAttributedString(string: AppStrings.ErrorReport.Legal.sendReports_Bullet2)

		points.append(bullet1)
		points.append(bullet2)

		return points
	}
	
	private let didPressDetailsButton: () -> Void
}

extension DynamicCell {

	/// A `DynamicLegalExtendedCell` to display legal text
	/// - Parameters:
	///   - title: The title/header for the legal foo.
	///   - subheadline1: Optional description text.
	///   - bulletPoints: A list of strings to be prefixed with bullet points.
	///   - subheadline2: Optional description text.
	///   - accessibilityIdentifier: Optional, but highly recommended, accessibility identifier.
	///   - configure: Optional custom cell configuration
	/// - Returns: A `DynamicCell` to display legal texts
	static func legalExtendedParagraph(
		title: NSAttributedString,
		subheadline1: NSAttributedString?,
		bulletPoints: [NSAttributedString]? =  nil,
		subheadline2: NSAttributedString?,
		accessibilityIdentifier: String? = nil,
		configure: CellConfigurator? = nil,
		spacing: CGFloat
	) -> Self {
		.identifier(DiaryInfoViewController.ReuseIdentifiers.legalExtended) { viewController, cell, indexPath in
			guard let cell = cell as? DynamicLegalExtendedCell else {
				fatalError("could not initialize cell of type `DynamicLegalExtendedCell`")
			}
			cell.configure(title: title, subheadline1: subheadline1, bulletPoints: bulletPoints, subheadline2: subheadline2, spacing: spacing)
			
			configure?(viewController, cell, indexPath)
		}
	}

}
