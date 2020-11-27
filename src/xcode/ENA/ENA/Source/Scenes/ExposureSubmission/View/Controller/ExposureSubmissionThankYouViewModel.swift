//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct ExposureSubmissionThankYouViewModel {
	
	// MARK: - Internal
	
	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					header: .image(
						UIImage(imageLiteralResourceName: "Illu_Submission_VielenDank"),
						accessibilityLabel: AppStrings.ExposureSubmissionQRInfo.imageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionWarnOthers.accImageDescription
					), cells: [
						.body(text: "Vielen Dank: Subtitle"),
						.body(text: "Vielen Dank: Body1"),
						.body(text: "Vielen Dank: Body2")
					]
				)
			)
		}
	}
	
}
