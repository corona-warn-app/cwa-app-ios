//
// 🦠 Corona-Warn-App
//

import UIKit

struct DeltaOnboardingNotificationReworkViewModel {
	
	// MARK: - Init
	
	init(
	) {
		
	}
		
	// MARK: - Internal
	
	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					header: .image(
						UIImage(named: "Illu_Mitteilungen_On"),
						accessibilityLabel: AppStrings.NotificationSettings.imageDescriptionOn,
						accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.DeltaOnboarding.image,
						height: 250
					),
					cells: [
						.body(
							text: AppStrings.NotificationSettings.DeltaOnboarding.description,
							accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.DeltaOnboarding.description
						),
						.body(
							text: AppStrings.NotificationSettings.bulletDescOn,
							accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.bulletDescOn
						)
					]
				)
			)
			$0.add(
				.section(
					cells: [
						.space(height: 8),
						.bulletPoint(
							text: AppStrings.NotificationSettings.bulletPoint1,
							accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.bulletPoint1
						),
						.space(height: 8),
						.bulletPoint(
							text: AppStrings.NotificationSettings.bulletPoint2,
							accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.bulletPoint2
						),
						.space(height: 8),
						.bulletPoint(
							text: AppStrings.NotificationSettings.bulletPoint3,
							accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.bulletPoint3
						)
					]
				)
			)
			$0.add(
				.section(
					cells: [
						.textWithLinks(
							text: String(
								format: AppStrings.NotificationSettings.bulletDesc2,
								AppStrings.NotificationSettings.bulletDesc2FAQText),
							links: [AppStrings.NotificationSettings.bulletDesc2FAQText: AppStrings.Links.notificationSettingsFAQ]
						),
						.space(height: 8)
					]
				)
			)
		}
	}
	
	// MARK: - Private
	
	private func createBulletDesc2Text() -> NSAttributedString {
		let rawString = String(format: AppStrings.NotificationSettings.bulletDesc2, AppStrings.NotificationSettings.bulletDesc2FAQText)
		let string = NSMutableAttributedString(string: rawString)
		let range = string.mutableString.range(of: AppStrings.NotificationSettings.bulletDesc2FAQText)
		if range.location != NSNotFound {
			// Links don't work in UILabels so we fake it here. Link handling in done in view controller on cell tap.
			string.addAttribute(.foregroundColor, value: UIColor.enaColor(for: .textTint), range: range)
			string.addAttribute(.underlineColor, value: UIColor.clear, range: range)
		}
		return string
	}
		
}
