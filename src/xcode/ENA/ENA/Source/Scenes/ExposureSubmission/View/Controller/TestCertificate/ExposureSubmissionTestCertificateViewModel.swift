////
// 🦠 Corona-Warn-App
//

import UIKit

struct ExposureSubmissionTestCertificateViewModel {

	// MARK: - Init

	init(
		presentDisclaimer: @escaping () -> Void
	) {
		self.presentDisclaimer = presentDisclaimer
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

//	let section01ImageName = "Icons_Certificates_01"
//	let section02ImageName = "Icons_Certificates_02"

	enum ReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case legalExtended = "DynamicLegalExtendedCell"
	}

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			// Illustration with information text
			.section(
				header:
					.image(
						UIImage(
							imageLiteralResourceName: "Illu_Test_Certificate"
						),
						accessibilityLabel: AppStrings.ContactDiary.Information.imageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.ContactDiaryInformation.imageDescription,
						height: 161
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
