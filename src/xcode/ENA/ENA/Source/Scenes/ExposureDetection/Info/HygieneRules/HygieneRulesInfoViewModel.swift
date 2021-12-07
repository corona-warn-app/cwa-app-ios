//
// 🦠 Corona-Warn-App
//

import UIKit

struct HygieneRulesInfoViewModel {
	
	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				cells: [
					.headlineWithImage(
						headerText: AppStrings.ExposureDetection.hygieneRulesTitle,
						image: UIImage(imageLiteralResourceName: "Illu_Distanz"),
						imageAccessibilityLabel: AppStrings.ExposureDetection.hygieneRulesTitleImageDescription,
						imageAccessibilityIdentifier: AccessibilityIdentifiers.ExposureDetection.hygieneRulesTitle
					)
				]
			),
			.section(
				cells: [
					.space(height: 30),
					.icon(
						UIImage(imageLiteralResourceName: "Icons - Mundschutz"),
						text: .string(AppStrings.ExposureDetection.hygieneRulesPoint1),
						tintColor: .enaColor(for: .riskHigh)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons - Abstand"),
						text: .string(AppStrings.ExposureDetection.hygieneRulesPoint2),
						tintColor: .enaColor(for: .riskHigh)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons - Niesen"),
						text: .string(AppStrings.ExposureDetection.hygieneRulesPoint3),
						tintColor: .enaColor(for: .riskHigh)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons - Hands"),
						text: .string(AppStrings.ExposureDetection.hygieneRulesPoint4),
						tintColor: .enaColor(for: .riskHigh)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons - Ventilation"),
						text: .string(AppStrings.ExposureDetection.hygieneRulesPoint5),
						tintColor: .enaColor(for: .riskHigh)
					)
				]
			)
		])
	}
}
