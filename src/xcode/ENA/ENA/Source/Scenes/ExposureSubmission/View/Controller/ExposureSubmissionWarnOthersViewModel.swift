//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct ExposureSubmissionWarnOthersViewModel {

	private let countries: [Country]
	private let acknowledgementString: NSAttributedString = {
		let boldText = AppStrings.ExposureSubmissionWarnOthers.acknowledgement_1_1
		let normalText = AppStrings.ExposureSubmissionWarnOthers.acknowledgement_1_2
		let string = NSMutableAttributedString(string: "\(boldText) \(normalText)")

		// highlighted text
		let attributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.preferredFont(forTextStyle: .headline)
		]
		string.addAttributes(attributes, range: NSRange(location: 0, length: boldText.count))

		return string
	}()

	init(supportedCountries: [Country]) {
		countries = supportedCountries
	}

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		var model = DynamicTableViewModel([])

		// Andere Warnen
		model.add(
			.section(
				header: .image(
					UIImage(named: "Illu_Submission_AndereWarnen"),
					accessibilityLabel: AppStrings.ExposureSubmissionWarnOthers.accImageDescription,
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.accImageDescription,
					height: 250
				),
				cells: [
					.headline(
						text: AppStrings.ExposureSubmissionWarnOthers.sectionTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.sectionTitle
					),
					.body(
						text: AppStrings.ExposureSubmissionWarnOthers.description,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.description
					),
					.space(height: 12),
					.body(
						text: AppStrings.ExposureSubmissionWarnOthers.supportedCountriesTitle,
						accessibilityIdentifier: nil
					),
					.space(height: 12)
				]
			)
		)

		// 'Flags'
		model.add(
			.section(separators: .all, cells: [
				.countries(countries: countries, accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionQRInfo.countryList),
				.space(height: 8)
			])
		)

		// Ihr Einverständnis
		model.add(
			.section(cells: [
				.legal(title: NSAttributedString(string: AppStrings.ExposureSubmissionQRInfo.acknowledgementTitle),
					   description: NSAttributedString(string: AppStrings.ExposureSubmissionQRInfo.acknowledgementBody),
					   textBlocks: [
						acknowledgementString,
						NSAttributedString(string: AppStrings.ExposureSubmissionWarnOthers.acknowledgement_footer)
					   ],
					   accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionQRInfo.acknowledgementTitle),
				.bulletPoint(text: AppStrings.ExposureSubmissionQRInfo.acknowledgement3, alignment: .legal),
				.bulletPoint(text: AppStrings.ExposureSubmissionQRInfo.acknowledgement5, alignment: .legal),
				.bulletPoint(text: AppStrings.ExposureSubmissionQRInfo.acknowledgement6, alignment: .legal),
				.space(height: 16)
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
					}),
				.space(height: 12)
			])
		)

		return model
	}
}

extension DynamicCell {
	static func legal(
		title: NSAttributedString,
		description: NSAttributedString?,
		textBlocks: [NSAttributedString],
		accessibilityIdentifier: String? = nil,
		configure: CellConfigurator? = nil
	) -> Self {
		.identifier(ExposureSubmissionQRInfoViewController.ReuseIdentifiers.legal) { viewController, cell, indexPath in
			guard let cell = cell as? DynamicAcknowledgementCell else {
				fatalError("could not initialize cell of type `DynamicAcknowledgementCell`")
			}
			cell.configure(title: title, description: description, textBlocks: textBlocks, accessibilityIdentifier: accessibilityIdentifier)
			configure?(viewController, cell, indexPath)
		}
	}
}
