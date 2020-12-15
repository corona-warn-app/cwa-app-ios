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
						text: .string(AppStrings.ContactDiary.Information.itemPersonTitle)
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Location"),
						text: .string(AppStrings.ContactDiary.Information.itemContactTitle)
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Lock"),
						text: .string(AppStrings.ContactDiary.Information.itemLockTitle)
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Diary_Deleted_Automatically"),
						text: .string(AppStrings.ContactDiary.Information.deletedAutomatically)
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Diary_Export_Textformat"),
						text: .string(AppStrings.ContactDiary.Information.exportTextformat)
					)
				]
			),
			// Legal text
			.section(cells: [
				.acknowledgement(
					title: NSAttributedString(string: AppStrings.ContactDiary.Information.legalHeadline_1), // larger font required
					description: NSAttributedString(string: AppStrings.ContactDiary.Information.legalSubHeadline_1),   // should be BOLD
					bulletPoints: [
						NSAttributedString(string: AppStrings.ContactDiary.Information.legalText_1),
						NSAttributedString(string: AppStrings.ContactDiary.Information.legalText_2)
						],
//					description: NSAttributedString(string: AppStrings.ContactDiary.Information.legalSubHeadline_2),   // should be BOLD
//					bulletPoints: [
//						NSAttributedString(string: AppStrings.ContactDiary.Information.legalText_3),
//						NSAttributedString(string: AppStrings.ContactDiary.Information.legalText_4)
//						],

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
