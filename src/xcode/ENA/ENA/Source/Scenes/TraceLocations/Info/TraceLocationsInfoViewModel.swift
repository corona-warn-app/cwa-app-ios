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
					.body(
						text: AppStrings.TraceLocations.Information.descriptionSubHeadline,
						accessibilityIdentifier: AccessibilityIdentifiers.TraceLocation.descriptionSubHeadline
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_CheckInRiskStatus"),
						text: .string(AppStrings.TraceLocations.Information.itemCheckinRiskStatus),
						alignment: .top
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
						UIImage(imageLiteralResourceName: "Icons_Diary_Deleted_Automatically"),
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
					description: NSAttributedString(string: AppStrings.TraceLocations.Information.legalText01),
					bulletPoints: [
						bulletPointCellWithBoldHeadline(
							title: AppStrings.TraceLocations.Information.legalText02bold,
							text: AppStrings.TraceLocations.Information.legalText02
						),
						bulletPointCellWithBoldHeadline(
							title: AppStrings.TraceLocations.Information.legalText03bold,
							text: AppStrings.TraceLocations.Information.legalText03
						),
						NSAttributedString(string: AppStrings.TraceLocations.Information.legalText04),
						NSAttributedString(string: AppStrings.TraceLocations.Information.legalText05)
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
	private let boldTextAttribute: [NSAttributedString.Key: Any] = [
		NSAttributedString.Key.font: UIFont.enaFont(for: .body, weight: .bold)
	]
	private let normalTextAttribute: [NSAttributedString.Key: Any] = [
		NSAttributedString.Key.font: UIFont.enaFont(for: .body)
	]
	
	private func bulletPointCellWithBoldHeadline(title: String, text: String) -> NSMutableAttributedString {
		let bulletPoint = NSMutableAttributedString(string: "\(title)" + "\n\t", attributes: boldTextAttribute)
		bulletPoint.append(NSAttributedString(string: text, attributes: normalTextAttribute))
		return bulletPoint
	}

}
