//
// 🦠 Corona-Warn-App
//

import UIKit

struct HygieneRulesInfoViewModel {
	
	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		var model = DynamicTableViewModel([])
		
		model.add(
			.section(
			   header: .image(
				   UIImage(imageLiteralResourceName: "Illu_Distanz"),
				   accessibilityLabel: AppStrings.ExposureDetection.hygieneRulesTitleImageDescription,
				   accessibilityIdentifier: AccessibilityIdentifiers.ExposureDetection.hygieneRulesTitle,
				   height: 250
			   ),
			   cells: [
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
		)

		return model
	}
}
