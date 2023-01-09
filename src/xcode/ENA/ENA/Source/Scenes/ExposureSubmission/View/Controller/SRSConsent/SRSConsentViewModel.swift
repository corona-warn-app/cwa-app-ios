//
// 🦠 Corona-Warn-App
//

import OpenCombine
import UIKit

class SRSConsentViewModel {
	
	// MARK: - Init
	
	init(appConfiguration: AppConfigurationProviding) {
		self.appConfiguration = appConfiguration
		
		appConfiguration.appConfiguration()
			.sink { [weak self] config in
				self?.timeBetweenSubmissionsInDays = Int(config.selfReportParameters.common.timeBetweenSubmissionsInDays)
			}
			.store(in: &subscriptions)
	}
	
	// MARK: - Internal

	var refreshTableView: CompletionVoid?

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
						String(timeBetweenSubmissionsInDays)
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
						attributes: [.font: UIFont.enaFont(for: .body)]
					),
					bulletPoints: legalExtendedDataDonationBulletPoints,
					accessibilityIdentifier: AccessibilityIdentifiers.SRSConsentScreen.acknowledgementTitle,
					configure: { _, cell, _ in
						cell.backgroundColor = .enaColor(for: .background)
					}
				),
				acknowledgementBulletPoint(for: AppStrings.SRSConsentScreen.acknowledgement1),
				acknowledgementBulletPoint(for: AppStrings.SRSConsentScreen.acknowledgement2),
				acknowledgementBulletPoint(for: AppStrings.SRSConsentScreen.acknowledgement3),
				acknowledgementBulletPoint(for: AppStrings.SRSConsentScreen.acknowledgement4),
				acknowledgementBulletPoint(for: AppStrings.SRSConsentScreen.acknowledgement5),
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

	private var legalExtendedDataDonationBulletPoints: [NSAttributedString] {
		var points = [NSAttributedString]()
		
		// For normal texts
		let fontRegularAttributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.enaFont(for: .body)
		]
		
		// For highlight texts
		let fontBoldAttributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.enaFont(for: .body, weight: .bold)
		]

		// Don't forget the tab for all paragraphs after the first!
		let ack1 = NSMutableAttributedString(
			string: AppStrings.SRSConsentScreen.legalBulletPoint01,
			attributes: fontBoldAttributes
		)
		
		let ack2 = NSMutableAttributedString(
			string: AppStrings.SRSConsentScreen.legalBulletPoint02,
			attributes: fontRegularAttributes
		)
		ack2.setAttributes(
			fontBoldAttributes,
			range: NSRange(
				location: AppStrings.SRSConsentScreen.legalBulletPoint02prefix.count,
				length: AppStrings.SRSConsentScreen.legalBulletPoint02highlighted.count
			)
		)
		
		let ack3 = NSMutableAttributedString(
			string: AppStrings.SRSConsentScreen.legalBulletPoint03,
			attributes: fontBoldAttributes
		)

		points.append(ack1)
		points.append(ack2)
		points.append(ack3)

		return points
	}
	
	private let appConfiguration: AppConfigurationProviding
	
	private var timeBetweenSubmissionsInDays: Int = 90 {
		didSet {
			refreshTableView?()
		}
	}
	
	private var subscriptions = Set<AnyCancellable>()
	
	private func acknowledgementBulletPoint(for text: String) -> DynamicCell {
		.bulletPoint(
			attributedText: NSMutableAttributedString(
				string: text,
				attributes: [
					.font: UIFont.enaFont(for: .body, weight: .regular)
				]
			),
			spacing: .large,
			alignment: .legal
		)
	}
}
