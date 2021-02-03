//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct DiaryInfoViewModel {

	init(
		presentDisclaimer: @escaping () -> Void
	) {
		self.presentDisclaimer = presentDisclaimer
	}

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([

			// Illustration with information text
			.section(
				header:
					.image(
						UIImage(
							imageLiteralResourceName: "Illu_ContactDiary-Information"
						),
						accessibilityLabel: AppStrings.ContactDiary.Information.imageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.ContactDiaryInformation.imageDescription
					),
				cells: [
					.title2(
						text: AppStrings.ContactDiary.Information.descriptionTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.ContactDiaryInformation.descriptionTitle
					),
					.subheadline(
						text: AppStrings.ContactDiary.Information.descriptionSubHeadline,
						accessibilityIdentifier: AccessibilityIdentifiers.ContactDiaryInformation.descriptionSubHeadline
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Contact"),
						text: .string(AppStrings.ContactDiary.Information.itemPersonTitle),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Location"),
						text: .string(AppStrings.ContactDiary.Information.itemContactTitle),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Lock"),
						text: .string(AppStrings.ContactDiary.Information.itemLockTitle),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Diary_Deleted_Automatically"),
						text: .string(AppStrings.ContactDiary.Information.deletedAutomatically),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Diary_Export_Textformat"),
						text: .string(AppStrings.ContactDiary.Information.exportTextformat),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Attention_high_small"),
						text: .string(AppStrings.ContactDiary.Information.exposureHistory),
						alignment: .top
					)
				]
			),
			// Legal text
			.section(cells: [
				.legalExtended(
					title: NSAttributedString(string: AppStrings.ContactDiary.Information.legalHeadline_1),
					subheadline1: NSAttributedString(string: AppStrings.ContactDiary.Information.legalSubHeadline_1),
					bulletPoints1: [
						NSAttributedString(string: AppStrings.ContactDiary.Information.legalText_1),
						NSAttributedString(string: AppStrings.ContactDiary.Information.legalText_2)
						],
					subheadline2: NSAttributedString(string: AppStrings.ContactDiary.Information.legalSubHeadline_2),
					bulletPoints2: [
						NSAttributedString(string: AppStrings.ContactDiary.Information.legalText_3),
						NSAttributedString(string: AppStrings.ContactDiary.Information.legalText_4)
						],
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionQRInfo.acknowledgementTitle,
					configure: { _, cell, _ in
						cell.backgroundColor = .enaColor(for: .background)
					}
				)
			]),
			// Disclaimer cell
			.section(
				separators: .all,
				cells: [
					.body(
						text: AppStrings.ContactDiary.Information.dataPrivacyTitle,
						style: DynamicCell.TextCellStyle.label,
						accessibilityIdentifier: AccessibilityIdentifiers.ContactDiaryInformation.dataPrivacyTitle,
						accessibilityTraits: UIAccessibilityTraits.link,
						action: .execute { _, _ in
							presentDisclaimer()
						},
						configure: { _, cell, _ in
							cell.accessoryType = .disclosureIndicator
							cell.selectionStyle = .default
						})
				]
			)
		])
	}

	// MARK: - Private

	private let presentDisclaimer: () -> Void

}

extension DynamicCell {

	/// A `DynamicLegalExtendedCell` to display legal text
	/// - Parameters:
	///   - title: The title/header for the legal foo.
	///   - subheadline1: Optional description text.
	///   - bulletPoints1: A list of strings to be prefixed with bullet points.
	///   - subheadline2: Optional description text.
	///   - bulletPoints2: A list of strings to be prefixed with bullet points.
	///   - accessibilityIdentifier: Optional, but highly recommended, accessibility identifier.
	///   - configure: Optional custom cell configuration
	/// - Returns: A `DynamicCell` to display legal texts
	static func legalExtended(
		title: NSAttributedString,
		subheadline1: NSAttributedString?,
		bulletPoints1: [NSAttributedString]? =  nil,
		subheadline2: NSAttributedString?,
		bulletPoints2: [NSAttributedString]? =  nil,
		accessibilityIdentifier: String? = nil,
		configure: CellConfigurator? = nil
	) -> Self {
		.identifier(DiaryInfoViewController.ReuseIdentifiers.legalExtended) { viewController, cell, indexPath in
			guard let cell = cell as? DynamicLegalExtendedCell else {
				fatalError("could not initialize cell of type `DynamicLegalExtendedCell`")
			}
			cell.configure(title: title, subheadline1: subheadline1, bulletPoints1: bulletPoints1, subheadline2: subheadline2, bulletPoints2: bulletPoints2, accessibilityIdentifier: accessibilityIdentifier)
			
			configure?(viewController, cell, indexPath)
		}
	}

}
