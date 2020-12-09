//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct DiaryInfoViewModel {

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
						accessibilityLabel: AppStrings.ContactDiaryInformation.imageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.ContactDiaryInformation.imageDescription
					),
				cells: [
					.title2(
						text: AppStrings.ContactDiaryInformation.descriptionTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.ContactDiaryInformation.descriptionTitle
					),
					.subheadline(
						text: AppStrings.ContactDiaryInformation.descriptionSubHeadline,
						accessibilityIdentifier: AccessibilityIdentifiers.ContactDiaryInformation.descriptionSubHeadline
					),
					.space(
						height: 15.0
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Contact"),
						text: .string(AppStrings.ContactDiaryInformation.itemPersonTitle)
					),
					.space(
						height: 15.0
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Location"),
						text: .string(AppStrings.ContactDiaryInformation.itemContactTitle)
					),
					.space(
						height: 15.0
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Lock"),
						text: .string(AppStrings.ContactDiaryInformation.itemLockTitle)
					)
				]
			),
			// Legal text
			.section(cells: [
				.acknowledgement(
					title: NSAttributedString(string: AppStrings.ContactDiaryInformation.legalHeadline_1),
					description: NSAttributedString(string: AppStrings.ContactDiaryInformation.legalText_1),
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionQRInfo.acknowledgementTitle
				)
			]),
			// Disclaimer cell
			.section(
				separators: .all,
				cells: [
					.body(
						text: AppStrings.ContactDiaryInformation.dataPrivacyTitle,
						style: DynamicCell.TextCellStyle.label,
						accessibilityIdentifier: AccessibilityIdentifiers.ContactDiaryInformation.dataPrivacyTitle,
						accessibilityTraits: UIAccessibilityTraits.link,
						action: .push(
							model: AppInformationModel.privacyModel,
							withTitle: AppStrings.AppInformation.privacyTitle
						),
						configure: { _, cell, _ in
							cell.accessoryType = .disclosureIndicator
							cell.selectionStyle = .default
						})
				]
			)
		])
	}

	// MARK: - Private

}
