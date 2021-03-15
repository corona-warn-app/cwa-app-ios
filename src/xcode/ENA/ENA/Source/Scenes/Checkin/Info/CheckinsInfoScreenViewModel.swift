////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct CheckInsInfoScreenViewModel {

	init(
		presentDisclaimer: @escaping () -> Void,
		hidesCloseButton: Bool = false
	) {
		self.presentDisclaimer = presentDisclaimer
		self.hidesCloseButton = hidesCloseButton
	}

	// MARK: - Internal
	
	let hidesCloseButton: Bool

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([

			// Illustration with information text and bullet icons with text
			.section(
				header:
					.image(
						UIImage(
							imageLiteralResourceName: "Illu_Event_Checkin_Info"
							// TODO: dark mode illustration
						),
						accessibilityLabel: AppStrings.Checkin.Information.imageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.CheckinInformation.imageDescription
					),
				cells: [
					.title2(
						text: AppStrings.Checkin.Information.descriptionTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.CheckinInformation.descriptionTitle
					),
					.subheadline(
						text: AppStrings.Checkin.Information.descriptionSubHeadline,
						accessibilityIdentifier: AccessibilityIdentifiers.CheckinInformation.descriptionSubHeadline
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Contact"), // TODO change icon
						text: .string(AppStrings.Checkin.Information.itemPersonTitle), // TODO change text ID
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Location"),
						text: .string(AppStrings.Checkin.Information.itemContactTitle),
						alignment: .top
					)
				]
			),
			// Legal text
			.section(cells: [
				.legalExtended(
					title: NSAttributedString(string: AppStrings.Checkin.Information.legalHeadline_1),
					subheadline1: NSAttributedString(string: AppStrings.Checkin.Information.legalSubHeadline_1),
					bulletPoints1: [
						NSAttributedString(string: AppStrings.Checkin.Information.legalText_1),
						NSAttributedString(string: AppStrings.Checkin.Information.legalText_2)
						],
					subheadline2: NSAttributedString(string: AppStrings.Checkin.Information.legalSubHeadline_2),
					bulletPoints2: [
						NSAttributedString(string: AppStrings.Checkin.Information.legalText_3),
						NSAttributedString(string: AppStrings.Checkin.Information.legalText_4)
						],
					// TODO check accessibility identifier
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
