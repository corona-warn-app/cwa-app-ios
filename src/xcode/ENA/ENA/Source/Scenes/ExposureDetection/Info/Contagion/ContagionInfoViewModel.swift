//
// 🦠 Corona-Warn-App
//

import UIKit

struct ContagionInfoViewModel {
	
	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				cells: [
					.headlineWithImage(
						headerText: AppStrings.ExposureDetection.contagionTitle,
						image: UIImage(imageLiteralResourceName: "Illu_Couch"),
						imageAccessibilityLabel: AppStrings.ExposureDetection.contagionTitleImageDescription,
						imageAccessibilityIdentifier: AccessibilityIdentifiers.ExposureDetection.contagionTitle
					)
				]
			),
			.section(
				cells: [
					.body(text: AppStrings.ExposureDetection.contagionImageTitle)
				]
			),
			.section(
				cells: [
					.icon(
						UIImage(imageLiteralResourceName: "NoMeetup"),
						text: .string(AppStrings.ExposureDetection.contagionPoint1),
						tintColor: .enaColor(for: .riskHigh),
						alignment: .top
					),
					.icon(
						UIImage(imageLiteralResourceName: "Home Office"),
						text: .string(AppStrings.ExposureDetection.contagionPoint2),
						tintColor: .enaColor(for: .riskHigh),
						alignment: .top
					),
					.icon(
						UIImage(imageLiteralResourceName: "Public Transport"),
						text: .string(AppStrings.ExposureDetection.contagionPoint3),
						tintColor: .enaColor(for: .riskHigh),
						alignment: .top
					)
				]
			),
			.section(
				cells: [
					.textWithLinks(
						text: AppStrings.ExposureDetection.contagionFooter,
						links: [
							AppStrings.ExposureDetection.contagionFooterLinkText: AppStrings.Links.selfQuarantineFAQ
						]
					),
					.space(height: 40)
				]
			)
		]
		)
	}
}
