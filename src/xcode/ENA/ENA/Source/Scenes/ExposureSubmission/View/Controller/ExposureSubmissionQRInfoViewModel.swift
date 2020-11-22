//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct ExposureSubmissionQRInfoViewModel {

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
				.title2(text: AppStrings.ExposureSubmissionQRInfo.headerSection1,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionQRInfo.headerSection1),
				.body(text: AppStrings.ExposureSubmissionQRInfo.bodySection1),
				.icon(
					UIImage(imageLiteralResourceName: "Icons_QR1"),
					text: .string(AppStrings.ExposureSubmissionQRInfo.instruction1)
				),
				.icon(
					UIImage(imageLiteralResourceName: "Icons_QR2"),
					text: .attributedString(
						AppStrings.ExposureSubmissionQRInfo.instruction2
							.inserting(emphasizedString: AppStrings.ExposureSubmissionQRInfo.instruction2HighlightedPhrase)
					)
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
				.body(text: "TODO: flags")
			])
		)

		// Ihr Einverständnis
		model.add(
			.section(cells: [
				.acknowledgement(title: NSAttributedString(string: AppStrings.ExposureSubmissionQRInfo.acknowledgementTitle),
								 description: NSAttributedString(string: "TODO"),
								 bulletPoints: bulletPoints,
								 accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionQRInfo.acknowledgementTitle)
			])
		)

		// Even more info
		model.add(
			.section(separators: .all, cells: [
				.body(text: "TODO: data privacy statement")
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

		// simpler strings
		points.append(NSAttributedString(string: AppStrings.ExposureSubmissionQRInfo.acknowledgement3))
		points.append(NSAttributedString(string: AppStrings.ExposureSubmissionQRInfo.acknowledgement4))
		points.append(NSAttributedString(string: AppStrings.ExposureSubmissionQRInfo.acknowledgement5))
		points.append(NSAttributedString(string: AppStrings.ExposureSubmissionQRInfo.acknowledgement6))
		return points
	}
}

extension DynamicCell {
	
	static func acknowledgement(
		title: NSAttributedString,
		description: NSAttributedString?,
		bulletPoints: [NSAttributedString],
		accessibilityIdentifier: String? = nil,
		configure: CellConfigurator? = nil
	) -> Self {
		.identifier(ExposureSubmissionQRInfoViewController.ReuseIdentifiers.acknowledgement) { viewController, cell, indexPath in
			guard let cell = cell as? DynamicAcknowledgementCell else {
				fatalError("could not initialize cell of type `ExposureSubmissionQRAcknowledgementCell`")
			}
			cell.configure(title: title, description: description, bulletPoints: bulletPoints, accessibilityIdentifier: accessibilityIdentifier)
			configure?(viewController, cell, indexPath)
		}
	}
}
