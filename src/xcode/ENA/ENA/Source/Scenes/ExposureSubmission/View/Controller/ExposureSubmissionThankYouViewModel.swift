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
						UIImage(named: "Illu_Submission_ThankYou"),
						accessibilityLabel: AppStrings.ThankYouScreen.accImageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.ThankYouScreen.accImageDescription
					), cells: [
						.title1(text: AppStrings.ThankYouScreen.subTitle, accessibilityIdentifier: nil),
						.headline(text: AppStrings.ThankYouScreen.description1),
						.body(text: AppStrings.ThankYouScreen.description2)
					]
				)
			)
		}
	}
	
}
