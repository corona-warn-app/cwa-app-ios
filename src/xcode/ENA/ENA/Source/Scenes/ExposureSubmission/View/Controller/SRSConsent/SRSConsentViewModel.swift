//
// 🦠 Corona-Warn-App
//

import UIKit

struct SRSConsentViewModel {
	
	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		var model = DynamicTableViewModel([])
		
		// Ihr Einverständnis Section
		model.add(
			.section(
			   header: .image(
				   UIImage(imageLiteralResourceName: "Illu_Testresult_available"),
				   accessibilityLabel: AppStrings.ExposureSubmissionTestResultAvailable.accImageDescription,
				   accessibilityIdentifier: AccessibilityIdentifiers.SRSConsentScreen.accImageDescription,
				   height: 250
			   ),
			   cells: [
				.title2(
					text: AppStrings.SRSConsentScreen.headerSection1,
					accessibilityIdentifier: AccessibilityIdentifiers.SRSConsentScreen.headerSection1
				)
			])
		)

		// Andere Warnen
		model.add(
			.section(cells: [
				.body(text: AppStrings.SRSConsentScreen.titleDescription1),
				.icon(
					UIImage(imageLiteralResourceName: "SRS-Positive-icon"),
					text: .string(AppStrings.SRSConsentScreen.instruction1),
					alignment: .top
				),
				.icon(
					UIImage(imageLiteralResourceName: "SRS-Warn-Others-icon"),
					text: .string(AppStrings.SRSConsentScreen.instruction2),
					alignment: .top
				),
				.icon(
					UIImage(imageLiteralResourceName: "SRS-No-Certificate-icon"),
					text: .string(AppStrings.SRSConsentScreen.instruction3),
					alignment: .top
				)
			])
		)

		// Helfen Sie mit, …
		model.add(
			.section(cells: [
				.title2(
					text: AppStrings.SRSConsentScreen.headerSection2,
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionQRInfo.headerSection2
				),
				.body(text: AppStrings.SRSConsentScreen.titleDescription2)
			])
		)

		// Legal text
		model.add(
			.section(cells: [
				.legalExtendedDataDonation(
					title: NSAttributedString(string: AppStrings.SRSConsentScreen.legalHeadline),
					description: NSAttributedString(string: AppStrings.SRSConsentScreen.legalDescription),
					bulletPoints: bulletPoints,
					accessibilityIdentifier: AccessibilityIdentifiers.TraceLocation.acknowledgementTitle,
					configure: { _, cell, _ in
						cell.backgroundColor = .enaColor(for: .background)
					}
				),
				.bulletPoint(text: AppStrings.ExposureSubmissionQRInfo.acknowledgement4, alignment: .legal),
				.bulletPoint(text: AppStrings.ExposureSubmissionQRInfo.acknowledgement5, alignment: .legal),
				.bulletPoint(text: AppStrings.ExposureSubmissionQRInfo.acknowledgement6, alignment: .legal),
				.body(text: AppStrings.ExposureSubmissionQRInfo.acknowledgement7)
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
					action: .push(htmlModel: AppInformationModel.privacyModel, withTitle: AppStrings.AppInformation.privacyTitle),
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
		let ack1 = NSMutableAttributedString(string: "\(AppStrings.SRSConsentScreen.legalBulletPoint01)")
		ack1.addAttributes(attributes, range: NSRange(location: 0, length: AppStrings.SRSConsentScreen.legalBulletPoint01.count))

		let ack2 = NSMutableAttributedString(string: "\(AppStrings.SRSConsentScreen.legalBulletPoint02)")
		ack2.addAttributes(attributes, range: NSRange(location: 0, length: AppStrings.SRSConsentScreen.legalBulletPoint02.count))

		let ack3 = NSMutableAttributedString(string: "\(AppStrings.SRSConsentScreen.legalBulletPoint03)")
		ack3.addAttributes(attributes, range: NSRange(location: 0, length: AppStrings.SRSConsentScreen.legalBulletPoint03.count))
		
		points.append(ack1)
		points.append(ack2)
		points.append(ack3)

		return points
	}
}
