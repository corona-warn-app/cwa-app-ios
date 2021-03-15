//
// 🦠 Corona-Warn-App
//

import UIKit

struct TraceLocationsInfoViewModel {

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
							imageLiteralResourceName: "Illu_TraceLocations-Information"
						),
						accessibilityLabel: AppStrings.TraceLocations.Information.imageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.TraceLocation.imageDescription
					),
				cells: [
					.title2(
						text: AppStrings.TraceLocations.Information.descriptionTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.TraceLocation.descriptionTitle
					),
					.subheadline(
						text: AppStrings.TraceLocations.Information.descriptionSubHeadline,
						accessibilityIdentifier: AccessibilityIdentifiers.TraceLocation.descriptionSubHeadline
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Contact"),
						text: .string(AppStrings.TraceLocations.Information.itemPersonTitle),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Location"),
						text: .string(AppStrings.TraceLocations.Information.itemContactTitle),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Lock"),
						text: .string(AppStrings.TraceLocations.Information.itemLockTitle),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Diary_Deleted_Automatically"),
						text: .string(AppStrings.TraceLocations.Information.deletedAutomatically),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Diary_Export_Textformat"),
						text: .string(AppStrings.TraceLocations.Information.exportTextformat),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Attention_high_small"),
						text: .string(AppStrings.TraceLocations.Information.exposureHistory),
						alignment: .top
					)
				]
			),
			// Legal text
			.section(cells: [
				.legalExtended(
					title: NSAttributedString(string: AppStrings.TraceLocations.Information.legalHeadline_1),
					subheadline1: NSAttributedString(string: AppStrings.TraceLocations.Information.legalSubHeadline_1),
					bulletPoints1: [
						NSAttributedString(string: AppStrings.TraceLocations.Information.legalText_1),
						NSAttributedString(string: AppStrings.TraceLocations.Information.legalText_2)
						],
					subheadline2: NSAttributedString(string: AppStrings.TraceLocations.Information.legalSubHeadline_2),
					bulletPoints2: [
						NSAttributedString(string: AppStrings.TraceLocations.Information.legalText_3),
						NSAttributedString(string: AppStrings.TraceLocations.Information.legalText_4)
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
						text: AppStrings.TraceLocations.Information.dataPrivacyTitle,
						style: DynamicCell.TextCellStyle.label,
						accessibilityIdentifier: AccessibilityIdentifiers.TraceLocation.dataPrivacyTitle,
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
