////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct HealthCertificateValidationPassedViewModel: HealthCertificateValidationResultViewModel {

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([

			.section(
				header:
					.image(
						UIImage(imageLiteralResourceName: "Illu_Overwrite_Notice"),
						accessibilityLabel: AppStrings.ExposureSubmission.OverwriteNotice.imageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmission.OverwriteNotice.imageDescription,
						height: 182.0
					),
				cells: [
				]
			)
		]
		)
	}

}
