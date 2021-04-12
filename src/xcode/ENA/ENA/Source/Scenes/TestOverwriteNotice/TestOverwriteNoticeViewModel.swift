////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct TestOverwriteNoticeViewModel {

	// MARK: - Init

	init(_ testType: CoronaTestType) {
		self.title = AppStrings.ExposureSubmission.OverwriteNotice.title

		switch testType {
		case .pcr:
			self.headline = AppStrings.ExposureSubmission.OverwriteNotice.Pcr.headline
			self.headlineAccessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmission.OverwriteNotice.Pcr.headline
			self.text = AppStrings.ExposureSubmission.OverwriteNotice.Pcr.text
			self.textAccessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmission.OverwriteNotice.Pcr.text

		case .antigen:
			self.headline = AppStrings.ExposureSubmission.OverwriteNotice.Antigen.headline
			self.headlineAccessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmission.OverwriteNotice.Antigen.headline
			self.text = AppStrings.ExposureSubmission.OverwriteNotice.Antigen.text
			self.textAccessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmission.OverwriteNotice.Antigen.text
		}
	}

	// MARK: - Public

	// MARK: - Internal

	let title: String

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([

			// Illustration with information text and bullet icons with text
			.section(
				header:
					.image(
						UIImage(imageLiteralResourceName: "Illu_Overwrite_Notice"),
						accessibilityLabel: AppStrings.ExposureSubmission.OverwriteNotice.imageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmission.OverwriteNotice.imageDescription,
						height: 182.0
					),
				cells: [
					.title2(
						text: headline,
						accessibilityIdentifier: headlineAccessibilityIdentifier
					),
					.body(
						text: text,
						accessibilityIdentifier: textAccessibilityIdentifier
					)
				]
			)
		]
		)
	}

	// MARK: - Private

	private	let headline: String
	private	let headlineAccessibilityIdentifier: String
	private	let text: String
	private	let textAccessibilityIdentifier: String

}
