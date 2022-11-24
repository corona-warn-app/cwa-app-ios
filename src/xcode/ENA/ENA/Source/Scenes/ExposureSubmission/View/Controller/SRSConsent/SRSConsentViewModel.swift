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
					text: .string(String(
						format: AppStrings.SRSConsentScreen.instruction2,
						"90" // to.do fetch the number from app config
			        )),
					alignment: .top
				)
			])
		)

		// Legal text
		model.add(
			.section(cells: [
				.legalExtendedDataDonation(
					title: NSAttributedString(string: AppStrings.SRSConsentScreen.legalHeadline),
					description: NSAttributedString(
						string: AppStrings.SRSConsentScreen.legalDescription,
						attributes: [.font: UIFont.preferredFont(forTextStyle: .body)]
					),
					bulletPoints: bulletPoints,
					accessibilityIdentifier: AccessibilityIdentifiers.SRSConsentScreen.acknowledgementTitle,
					configure: { _, cell, _ in
						cell.backgroundColor = .enaColor(for: .background)
					}
				),
				.bulletPoint(text: AppStrings.SRSConsentScreen.acknowledgement1, alignment: .legal),
				.space(height: 8.0),
				.bulletPoint(text: AppStrings.SRSConsentScreen.acknowledgement2, alignment: .legal),
				.space(height: 8.0),
				.bulletPoint(text: AppStrings.SRSConsentScreen.acknowledgement3, alignment: .legal),
				.space(height: 8.0),
				.bulletPoint(text: AppStrings.SRSConsentScreen.acknowledgement4, alignment: .legal),
				.space(height: 8.0),
				.bulletPoint(text: AppStrings.SRSConsentScreen.acknowledgement5, alignment: .legal),
				.space(height: 8.0),
				.body(text: AppStrings.SRSConsentScreen.acknowledgement6)
			])
		)

		// Even more info
		model.add(
			.section(separators: .all, cells: [
				.body(
					text: AppStrings.SRSConsentScreen.dataProcessingDetailInfo,
					style: DynamicCell.TextCellStyle.label,
					accessibilityIdentifier: AccessibilityIdentifiers.SRSConsentScreen.dataProcessingDetailInfoButton,
					accessibilityTraits: UIAccessibilityTraits.link,
					action: .push(viewController: SRSDataProcessingInfoViewController()),
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
		ack2.addAttributes(attributes, range: NSRange(location: AppStrings.SRSConsentScreen.legalBulletPoint02prefix.count, length: AppStrings.SRSConsentScreen.legalBulletPoint02highlighted.count))

		let ack3 = NSMutableAttributedString(string: "\(AppStrings.SRSConsentScreen.legalBulletPoint03)")
		ack3.addAttributes(attributes, range: NSRange(location: 0, length: AppStrings.SRSConsentScreen.legalBulletPoint03.count))
		
		points.append(ack1)
		points.append(ack2)
		points.append(ack3)

		return points
	}
}
