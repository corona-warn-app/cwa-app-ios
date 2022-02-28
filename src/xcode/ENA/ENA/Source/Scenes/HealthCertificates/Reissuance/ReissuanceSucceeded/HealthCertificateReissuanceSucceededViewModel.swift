//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct HealthCertificateReissuanceSucceededViewModel {

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				cells: [
					.headlineWithImage(
						headerText: AppStrings.HealthCertificate.Reissuance.Succeeded.title,
						image: UIImage(imageLiteralResourceName: "Illu_Replace_Success"),
						imageAccessibilityIdentifier: AccessibilityIdentifiers.HealthCertificate.Person.UpdateSucceeded.image
					),
					.title2(text: AppStrings.HealthCertificate.Reissuance.Succeeded.headline),

					.body(
						text: AppStrings.HealthCertificate.Reissuance.Succeeded.body
					)
				]
			)
		])
	}
}
