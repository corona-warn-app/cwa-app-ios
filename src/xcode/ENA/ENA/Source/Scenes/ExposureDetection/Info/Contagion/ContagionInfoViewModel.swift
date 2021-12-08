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
						tintColor: .enaColor(for: .riskHigh)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Home Office"),
						text: .string(AppStrings.ExposureDetection.contagionPoint2),
						tintColor: .enaColor(for: .riskHigh)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Shoppiing"),
						text: .string(AppStrings.ExposureDetection.contagionPoint3),
						tintColor: .enaColor(for: .riskHigh)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Public Transport"),
						text: .string(AppStrings.ExposureDetection.contagionPoint4),
						tintColor: .enaColor(for: .riskHigh)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Travel"),
						text: .string(AppStrings.ExposureDetection.contagionPoint5),
						tintColor: .enaColor(for: .riskHigh)
					),
					.iconWithLinkText(
						UIImage(imageLiteralResourceName: "Qarantine"), text: AppStrings.ExposureDetection.contagionPoint6,
						links: [ENALinkedTextView.Link(text: AppStrings.ExposureDetection.contagionPoint6LinkText, link: AppStrings.Links.quarantineMeasuresFAQ)]
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
