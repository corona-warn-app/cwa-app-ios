//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct ExposureSubmissionQRInfoViewModel {

	init(supportedCountries: [Country]) {
		countries = supportedCountries.sorted { $0.localizedName.localizedCompare($1.localizedName) == .orderedAscending }
	}

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

		// 'Flags'
		model.add(
			.section(separators: .all, cells: [
				.countries(countries: countries, accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionQRInfo.countryList)
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

	private let countries: [Country]

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
