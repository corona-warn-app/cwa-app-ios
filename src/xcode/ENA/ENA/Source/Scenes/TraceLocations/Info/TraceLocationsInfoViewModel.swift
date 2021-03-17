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
						UIImage(imageLiteralResourceName: "Icons_Checkin_QR"),
						text: .string(AppStrings.TraceLocations.Information.itemCheckinTitle),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Diary_Export_Textformat"),
						text: .string(AppStrings.TraceLocations.Information.itemContactTitle),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					)
				]
			),
			// Legal text
			.section(cells: [
				.legalExtendedDataDonation(
					title: NSAttributedString(string: AppStrings.TraceLocations.Information.legalHeadline),
					description: NSAttributedString(string: AppStrings.TraceLocations.Information.legalText_1),
					bulletPoints: [
						NSAttributedString(string: AppStrings.TraceLocations.Information.legalText_2),
						NSAttributedString(string: AppStrings.TraceLocations.Information.legalText_3),
						NSAttributedString(string: AppStrings.TraceLocations.Information.legalText_4),
						NSAttributedString(string: AppStrings.TraceLocations.Information.legalText_5)
						],
					accessibilityIdentifier: AccessibilityIdentifiers.TraceLocation.acknowledgementTitle,
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
