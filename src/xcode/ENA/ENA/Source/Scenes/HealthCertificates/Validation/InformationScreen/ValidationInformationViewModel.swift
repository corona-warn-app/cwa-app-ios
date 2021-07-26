////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct ValidationInformationViewModel {

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([

			// Illustration with information text and bullet icons with text
			.section(
				header:
					.image(
						UIImage(
							imageLiteralResourceName: "Illu_Europe_Card"
						),
						title: AppStrings.HealthCertificate.Validation.Info.title,
						accessibilityLabel: AppStrings.HealthCertificate.Validation.Info.imageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.HealthCertificate.Validation.Info.imageDescription,
						accessibilityTraits: .image
					),
				cells: [
					.space(height: 24.0),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Car"),
						text: .string(AppStrings.HealthCertificate.Validation.Info.byCar),
						alignment: .top
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Plane"),
						text: .string(AppStrings.HealthCertificate.Validation.Info.byPlane),
						alignment: .top
					)
				]
			)
		])
	}

}
