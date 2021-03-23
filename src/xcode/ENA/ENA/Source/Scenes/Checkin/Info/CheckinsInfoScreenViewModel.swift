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
							imageLiteralResourceName: "Illu_Event_Attendee"
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
						UIImage(imageLiteralResourceName: "Icons_Risikoermittlung_12"),
						text: .string(AppStrings.Checkin.Information.itemRiskStatusTitle),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Diary_Deleted_Automatically"),
						text: .string(AppStrings.Checkin.Information.itemTimeTitle),
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
						bulletPointCellWithBoldHeadline(title: AppStrings.Checkin.Information.legalText_1_bold, text: AppStrings.Checkin.Information.legalText_1_normal),
						bulletPointCellWithBoldText(text: AppStrings.Checkin.Information.legalText_2),
						bulletPointCellWithBoldText(text: AppStrings.Checkin.Information.legalText_3)
						],
					subheadline2: NSAttributedString(string: AppStrings.Checkin.Information.legalSubHeadline_2),
					accessibilityIdentifier: AccessibilityIdentifiers.CheckinInformation.acknowledgementTitle,
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
						text: AppStrings.Checkin.Information.dataPrivacyTitle,
						style: DynamicCell.TextCellStyle.label,
						accessibilityIdentifier: AccessibilityIdentifiers.CheckinInformation.dataPrivacyTitle,
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

	private func bulletPointCellWithBoldText(text: String) -> NSMutableAttributedString {
		return NSMutableAttributedString(string: "\(text)", attributes: boldTextAttribute)
	}
	
}
