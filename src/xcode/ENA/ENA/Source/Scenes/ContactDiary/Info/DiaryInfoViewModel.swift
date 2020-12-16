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
					)
				]
			),
			// Legal text
			.section(cells: [
				.acknowledgement(
					title: NSAttributedString(string: AppStrings.ContactDiary.Information.legalHeadline_1),
					description: NSAttributedString(string: AppStrings.ContactDiary.Information.legalText_1),
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
