//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct ExposureSubmissionQRInfoViewModel {

	init(supportedCountries: [Country]) {
		countries = supportedCountries.sortedByLocalizedName
	}

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		var model = DynamicTableViewModel([])
		
		// Ihr Einverständnis Section
		model.add(
			.section(
			   header: .image(
				   UIImage(imageLiteralResourceName: "Illu_Appinfo_Datenschutz_2"),
				   accessibilityLabel: AppStrings.ExposureSubmissionQRInfo.imageDescription,
				   accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.accImageDescription,
				   height: 250
			   ),
			   cells: [
				.title2(
					text: AppStrings.ExposureSubmissionQRInfo.headerSection1,
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionQRInfo.headerSection1
				)
			])
		)

		// Testergebnis abrufen
		model.add(
			.section(cells: [
				.body(text: AppStrings.ExposureSubmissionQRInfo.titleDescription),
				.icon(
					UIImage(imageLiteralResourceName: "Icons_QR5"),
					text: .string(AppStrings.ExposureSubmissionQRInfo.instruction1)
				),
				.icon(
					UIImage(imageLiteralResourceName: "Icons - Once"),
					text: .string(AppStrings.ExposureSubmissionQRInfo.instruction2)
				),
				.icon(
					UIImage(imageLiteralResourceName: "Icons_Certificates_01"),
					text: .string(AppStrings.ExposureSubmissionQRInfo.instruction2a)
				)
			])
		)

		// Helfen Sie mit, …
		model.add(
			.section(cells: [
				.title2(
					text: AppStrings.ExposureSubmissionQRInfo.headerSection2,
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionQRInfo.headerSection2
				),
				.body(text: AppStrings.ExposureSubmissionQRInfo.bodySection2)
			])
		)

		// 'Flags'
		model.add(
			.section(separators: .all, cells: [
				.countries(countries: countries, accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionQRInfo.countryList)
			])
		)
		
		// Check-Ins
		model.add(
			.section(cells: [
				.body(text: AppStrings.ExposureSubmissionQRInfo.bodySection3)
			])
		)

		// Ihr Einverständnis – legal text
		model.add(
			.section(cells: [
				.acknowledgement2(
					title: NSAttributedString(string: AppStrings.ExposureSubmissionQRInfo.acknowledgementTitle),
					description: NSAttributedString(string: AppStrings.ExposureSubmissionQRInfo.acknowledgementBody),
					description2: NSAttributedString(string: AppStrings.ExposureSubmissionQRInfo.acknowledgementWithdrawConsent),
					bulletPoints: bulletPoints,
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionQRInfo.acknowledgementTitle
				),
				.bulletPoint(text: AppStrings.ExposureSubmissionQRInfo.acknowledgement3, alignment: .legal),
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

	private let countries: [Country]

	private var bulletPoints: [NSAttributedString] {
		var points = [NSAttributedString]()

		// highlighted texts
		let attributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.preferredFont(forTextStyle: .headline)
		]

		// Don't forget the tab for all paragraphs after the first!
		let ack1 = NSMutableAttributedString(string: "\(AppStrings.ExposureSubmissionQRInfo.acknowledgementBullet1_1)\n\t\(AppStrings.ExposureSubmissionQRInfo.acknowledgementBullet1_2)")
		ack1.addAttributes(attributes, range: NSRange(location: 0, length: AppStrings.ExposureSubmissionQRInfo.acknowledgementBullet1_1.count))

		let ack2 = NSMutableAttributedString(string: "\(AppStrings.ExposureSubmissionQRInfo.acknowledgementBullet2)")
		ack2.addAttributes(attributes, range: NSRange(location: 0, length: AppStrings.ExposureSubmissionQRInfo.acknowledgementBullet2.count))

		let ack3 = NSMutableAttributedString(string: "\(AppStrings.ExposureSubmissionQRInfo.acknowledgementBullet3)")
		ack3.addAttributes(attributes, range: NSRange(location: 0, length: AppStrings.ExposureSubmissionQRInfo.acknowledgementBullet3.count))
		
		points.append(ack1)
		points.append(ack2)
		points.append(ack3)

		return points
	}
}

extension DynamicCell {

	/// A `DynamicLegalCell` to display a list of acknowledgements the user is informed about.
	/// - Parameters:
	///   - title: The title/header for the legal foo.
	///   - description: Optional description text.
	///   - bulletPoints: A list of strings to be prefixed with bullet points.
	///   - accessibilityIdentifier: Optional, but highly recommended, accessibility identifier.
	///   - configure: Optional custom cell configuration
	/// - Returns: A `DynamicCell` to display legal texts
	static func acknowledgement(
		title: NSAttributedString,
		description: NSAttributedString?,
		bulletPoints: [NSAttributedString]? =  nil,
		accessibilityIdentifier: String? = nil,
		configure: CellConfigurator? = nil
	) -> Self {
		.identifier(ExposureSubmissionQRInfoViewController.ReuseIdentifiers.legal) { viewController, cell, indexPath in
			guard let cell = cell as? DynamicLegalCell else {
				fatalError("could not initialize cell of type `DynamicLegalCell`")
			}
			cell.configure(title: title, description: description, bulletPoints: bulletPoints, accessibilityIdentifier: accessibilityIdentifier)
			configure?(viewController, cell, indexPath)
		}
	}

	static func acknowledgement2(
		title: NSAttributedString,
		description: NSAttributedString?,
		description2: NSAttributedString?,
		bulletPoints: [NSAttributedString]? =  nil,
		accessibilityIdentifier: String? = nil,
		configure: CellConfigurator? = nil
	) -> Self {
		.identifier(ExposureSubmissionQRInfoViewController.ReuseIdentifiers.legalExtended) { viewController, cell, indexPath in
			guard let cell = cell as? DynamicLegalExtendedCell else {
				fatalError("could not initialize cell of type `DynamicLegalExtendedCell`")
			}
			cell.configure(title: title, description: description, description2: description2, bulletPoints: bulletPoints, accessibilityIdentifier: accessibilityIdentifier)
			configure?(viewController, cell, indexPath)
		}
	}

	/// A `LabelledCountriesCell` that displays a list of country flags and their localized names as simple list below.
	/// - Parameters:
	///   - countries: The countries to display
	///   - accessibilityIdentifier: Optional, but highly recommended, accessibility identifier.
	///   - configure: Optional custom cell configuration
	/// - Returns: A `DynamicCell` to display country flags and names
	static func countries(
		countries: [Country],
		accessibilityIdentifier: String? = nil,
		configure: CellConfigurator? = nil
	) -> Self {
		.identifier(ExposureSubmissionQRInfoViewController.ReuseIdentifiers.countries) { viewController, cell, indexPath in
			guard let cell = cell as? LabeledCountriesCell else {
				fatalError("could not initialize cell of type `LabeledCountriesCell`")
			}
			cell.configure(countriesList: countries, accessibilityIdentifier: accessibilityIdentifier)
			configure?(viewController, cell, indexPath)
		}
	}
}
