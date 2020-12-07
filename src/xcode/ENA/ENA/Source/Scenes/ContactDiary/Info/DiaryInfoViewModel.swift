//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct DiaryInfoViewModel {

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		var model = DynamicTableViewModel([])

		// Ihr Einverständnis
		model.add(
			.section(
			   header: .image(
				   UIImage(imageLiteralResourceName: "Illu_Appinfo_Datenschutz_2"),
				   accessibilityLabel: AppStrings.ExposureSubmissionQRInfo.imageDescription,
				   accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.accImageDescription,
				   height: 250
			   ),
			   cells: [
				.body(text: AppStrings.ExposureSubmissionQRInfo.titleDescription)
			])
		)

		// Testergebnis abrufen
		model.add(
			.section(cells: [
				.headline(
					text: AppStrings.ExposureSubmissionQRInfo.headerSection1,
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionQRInfo.headerSection1
				),
				.body(text: AppStrings.ExposureSubmissionQRInfo.bodySection1),
				.icon(
					UIImage(imageLiteralResourceName: "Icons - FaceID"),
					text: .string(AppStrings.ExposureSubmissionQRInfo.instruction1)
				),
				.icon(
					UIImage(imageLiteralResourceName: "Icons - Once"),
					text: .string(AppStrings.ExposureSubmissionQRInfo.instruction2)
				)
			])
		)

		// Helfen Sie mit, …
		model.add(
			.section(cells: [
				.title2(text: AppStrings.ExposureSubmissionQRInfo.headerSection2,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionQRInfo.headerSection2),
				.body(text: AppStrings.ExposureSubmissionQRInfo.bodySection2)
			])
		)

		// Ihr Einverständnis
		model.add(
			.section(cells: [
				.acknowledgement(title: NSAttributedString(string: AppStrings.ExposureSubmissionQRInfo.acknowledgementTitle),
								 description: NSAttributedString(string: AppStrings.ExposureSubmissionQRInfo.acknowledgementBody),
								 bulletPoints: bulletPoints,
								 accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionQRInfo.acknowledgementTitle),
				.bulletPoint(text: AppStrings.ExposureSubmissionQRInfo.acknowledgement3, alignment: .legal),
				.bulletPoint(text: AppStrings.ExposureSubmissionQRInfo.acknowledgement4, alignment: .legal),
				.bulletPoint(text: AppStrings.ExposureSubmissionQRInfo.acknowledgement5, alignment: .legal),
				.bulletPoint(text: AppStrings.ExposureSubmissionQRInfo.acknowledgement6, alignment: .legal)
			])
		)

		// Even more info
		model.add(
			.section(separators: .all, cells: [
				.body(
					text: AppStrings.AutomaticSharingConsent.dataProcessingDetailInfo,
					style: DynamicCell.TextCellStyle.label,
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionQRInfo.dataProcessingDetailInfo,
					accessibilityTraits: UIAccessibilityTraits.link,
					action: .push(model: AppInformationModel.privacyModel, withTitle: AppStrings.AppInformation.privacyTitle),
					configure: { _, cell, _ in
						cell.accessoryType = .disclosureIndicator
						cell.selectionStyle = .default
					})
			])
		)

		return model
	}

	// MARK: - Private

	private var bulletPoints: [NSAttributedString] {
		var points = [NSAttributedString]()

		// highlighted texts
		let attributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.preferredFont(forTextStyle: .headline)
		]

		// Don't forget the tab for all paragraphs after the first!
		let ack1 = NSMutableAttributedString(string: "\(AppStrings.ExposureSubmissionQRInfo.acknowledgement1_1)\n\t\(AppStrings.ExposureSubmissionQRInfo.acknowledgement1_2)")
		ack1.addAttributes(attributes, range: NSRange(location: 0, length: AppStrings.ExposureSubmissionQRInfo.acknowledgement1_1.count))

		let ack2 = NSMutableAttributedString(string: "\(AppStrings.ExposureSubmissionQRInfo.acknowledgement2_1)\n\t\(AppStrings.ExposureSubmissionQRInfo.acknowledgement2_2)")
		ack2.addAttributes(attributes, range: NSRange(location: 0, length: AppStrings.ExposureSubmissionQRInfo.acknowledgement2_1.count))

		points.append(ack1)
		points.append(ack2)

		return points
	}
}
