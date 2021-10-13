//
// 🦠 Corona-Warn-App
//

import UIKit

struct DeltaOnboardingNotificationReworkViewModel {
			
	// MARK: - Internal
	
	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					header: .image(
						UIImage(named: "Illu_Mitteilungen_On"),
						accessibilityLabel: AppStrings.NotificationSettings.imageDescriptionOn,
						accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.DeltaOnboarding.imageOn,
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
							links: [AppStrings.NotificationSettings.bulletDesc2FAQText: AppStrings.Links.notificationSettingsFAQ],
							accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.bulletDesc2
						),
						.space(height: 8)
					]
				)
			)
		}
	}
}
