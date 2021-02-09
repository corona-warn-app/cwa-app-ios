////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class DataDonationViewModel {

	// MARK: - Init

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	var country: String?
	var region: String?
	var age: String?
	
	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			
			$0.add(
				.section(
					header: .image(
						UIImage(named: "Illu_DataDonation"),
						accessibilityLabel: "AppStrings.DataDonation.Info.accImageDescription",
						accessibilityIdentifier: "AccessibilityIdentifiers.DataDonation.accImageDescription",
						height: 250
					),
					cells: [
						.title1(text: AppStrings.DataDonation.Info.title, accessibilityIdentifier: "AppStrings.DataDonation.Info.title"),
						.headline(text: AppStrings.DataDonation.Info.description)
					]
				)
			)
			$0.add(
				.section(
					cells: [
						.headline(text: AppStrings.DataDonation.Info.subHeadState),
						.headline(text: AppStrings.DataDonation.Info.subHeadState)
					]
				)
			)
			
			$0.add(
				.section(
					cells: [
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
					]
				)
			)
			
		}
	}

	// MARK: - Private
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
}
