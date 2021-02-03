//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct ExposureDetectionSurveyCellModel {

	let title = AppStrings.ExposureDetection.surveyCardTitle
	let description = AppStrings.ExposureDetection.surveyCardBody
	let buttonTitle = AppStrings.ExposureDetection.surveyCardButton
	let image = UIImage(named: "Illu_Survey")
	let accessibilityIdentifier = AccessibilityIdentifiers.ExposureDetection.surveyCardCell
	let buttonAccessibilityIdentifier = AccessibilityIdentifiers.ExposureDetection.surveyCardButton

}
