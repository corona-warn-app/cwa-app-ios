//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct OnBehalfThankYouViewModel {
	
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
						.space(height: 12),
						.body(text: AppStrings.OnBehalfCheckinSubmission.ThankYou.description)
					]
				)
			)
		}
	}
	
}
