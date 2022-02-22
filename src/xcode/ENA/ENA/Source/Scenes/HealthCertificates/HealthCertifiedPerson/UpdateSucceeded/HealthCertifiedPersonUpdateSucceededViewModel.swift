//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

/// ViewModel is a dummy for the moment to construct the flow for the moment
/// needed to get replaced in later tasks
///

struct HealthCertifiedPersonUpdateSucceededViewModel {

	// MARK: - Protocol TicketValidationResultViewModel

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				cells: [
					.headlineWithImage(
						headerText: AppStrings.HealthCertificate.Person.UpdateSucceeded.title,
						image: UIImage(imageLiteralResourceName: "Illu_Replace_Success"),
						imageAccessibilityIdentifier: AccessibilityIdentifiers.HealthCertificate.Person.UpdateSucceeded.image
					),
					.title2(text: AppStrings.HealthCertificate.Person.UpdateSucceeded.headline),

					.body(
						text: AppStrings.HealthCertificate.Person.UpdateSucceeded.body
					)
				]
			)
		])
	}
}
