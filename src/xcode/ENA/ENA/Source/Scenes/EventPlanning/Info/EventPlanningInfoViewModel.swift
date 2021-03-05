//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct EventPlanningInfoViewModel {

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

			// Illustration with information text
			.section(
				header:
					.image(
						UIImage(
							imageLiteralResourceName: "Illu_EventPlanning-Information"
						),
						accessibilityLabel: AppStrings.EventPlanning.Information.imageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.EventPlanning.imageDescription
					),
				cells: [
					.title2(
						text: AppStrings.EventPlanning.Information.descriptionTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.EventPlanning.descriptionTitle
					),
					.subheadline(
						text: AppStrings.EventPlanning.Information.descriptionSubHeadline,
						accessibilityIdentifier: AccessibilityIdentifiers.EventPlanning.descriptionSubHeadline
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Contact"),
						text: .string(AppStrings.EventPlanning.Information.itemPersonTitle),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Location"),
						text: .string(AppStrings.EventPlanning.Information.itemContactTitle),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Lock"),
						text: .string(AppStrings.EventPlanning.Information.itemLockTitle),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Diary_Deleted_Automatically"),
						text: .string(AppStrings.EventPlanning.Information.deletedAutomatically),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Diary_Export_Textformat"),
						text: .string(AppStrings.EventPlanning.Information.exportTextformat),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Attention_high_small"),
						text: .string(AppStrings.EventPlanning.Information.exposureHistory),
						alignment: .top
					)
				]
			),
			// Legal text
			.section(cells: [
				.legalExtended(
					title: NSAttributedString(string: AppStrings.EventPlanning.Information.legalHeadline_1),
					subheadline1: NSAttributedString(string: AppStrings.EventPlanning.Information.legalSubHeadline_1),
					bulletPoints1: [
						NSAttributedString(string: AppStrings.EventPlanning.Information.legalText_1),
						NSAttributedString(string: AppStrings.EventPlanning.Information.legalText_2)
						],
					subheadline2: NSAttributedString(string: AppStrings.EventPlanning.Information.legalSubHeadline_2),
					bulletPoints2: [
						NSAttributedString(string: AppStrings.EventPlanning.Information.legalText_3),
						NSAttributedString(string: AppStrings.EventPlanning.Information.legalText_4)
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
						text: AppStrings.EventPlanning.Information.dataPrivacyTitle,
						style: DynamicCell.TextCellStyle.label,
						accessibilityIdentifier: AccessibilityIdentifiers.EventPlanning.dataPrivacyTitle,
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
