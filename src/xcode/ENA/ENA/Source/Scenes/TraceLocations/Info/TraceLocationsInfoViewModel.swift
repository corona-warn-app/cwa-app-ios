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
		setUpBulletPointCells()
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
					)
				]
			),
			// Legal text
			.section(cells: [
				.legalExtendedDataDonation(
					title: NSAttributedString(string: AppStrings.TraceLocations.Information.legalHeadline_1),
					description: NSAttributedString(string: AppStrings.TraceLocations.Information.legalSubHeadline_1),
					bulletPoints: [
						NSAttributedString(string: AppStrings.TraceLocations.Information.legalText_1),
						NSAttributedString(string: AppStrings.TraceLocations.Information.legalText_2),
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
	private let boldTextAttribute: [NSAttributedString.Key: Any] = [
		NSAttributedString.Key.font: UIFont.enaFont(for: .body, weight: .bold)
	]
	private let normalTextAttribute: [NSAttributedString.Key: Any] = [
		NSAttributedString.Key.font: UIFont.enaFont(for: .body)
	]
	private var bulletPointCellWithBoldHeadline: [DynamicCell] = []
	
	private func setUpBulletPointCells() {
//		bulletPointCellWithBoldHeadline.append(
//			.bulletPoint(
//				attributedText: bulletPointCellText(
//					title: AppStrings.TraceLocation.Information.bullet1_title,
//					text: AppStrings.TraceLocation.Information.bullet1_text)
//			)
//		)
//		bulletPointCellWithBoldHeadline.append(
//			.bulletPoint(
//				attributedText: bulletPointCellText(
//					title: AppStrings.TraceLocation.Information.bullet2_title,
//					text: AppStrings.TraceLocation.Information.bullet2_text)
//			)
//		)
	}
	
	private func bulletPointCellText(title: String, text: String) -> NSMutableAttributedString {
		let bulletPoint = NSMutableAttributedString(string: "\(title)" + "\n\t", attributes: boldTextAttribute)
		bulletPoint.append(NSAttributedString(string: text, attributes: normalTextAttribute))
		bulletPoint.append(NSAttributedString(string: "\n", attributes: normalTextAttribute))
		return bulletPoint
	}
	
}
