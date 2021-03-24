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
						accessibilityLabel: AppStrings.Checkins.Information.imageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.CheckinInformation.imageDescription
					),
				cells: [
					.title2(
						text: AppStrings.Checkins.Information.descriptionTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.CheckinInformation.descriptionTitle
					),
					.subheadline(
						text: AppStrings.Checkins.Information.descriptionSubHeadline,
						accessibilityIdentifier: AccessibilityIdentifiers.CheckinInformation.descriptionSubHeadline
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_CheckInRiskStatus"),
						text: .string(AppStrings.Checkins.Information.itemRiskStatusTitle),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Diary_Deleted_Automatically"),
						text: .string(AppStrings.Checkins.Information.itemTimeTitle),
						alignment: .top
					)
				]
			),
			// Legal text
			.section(cells: [
				.legalExtended(
					title: NSAttributedString(string: AppStrings.Checkins.Information.legalHeadline01),
					subheadline1: NSAttributedString(string: AppStrings.Checkins.Information.legalSubHeadline01),
					bulletPoints1: [
						bulletPointCellWithBoldHeadline(title: AppStrings.Checkins.Information.legalText01bold, text: AppStrings.Checkins.Information.legalText01normal),
						bulletPointCellWithBoldText(text: AppStrings.Checkins.Information.legalText02),
						bulletPointCellWithBoldText(text: AppStrings.Checkins.Information.legalText03)
						],
					subheadline2: NSAttributedString(string: AppStrings.Checkins.Information.legalSubHeadline02),
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
						text: AppStrings.Checkins.Information.dataPrivacyTitle,
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
