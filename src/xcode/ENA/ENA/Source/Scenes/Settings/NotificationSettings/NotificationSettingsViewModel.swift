//
// 🦠 Corona-Warn-App
//

import UIKit

class NotificationSettingsViewModel {
	
	// MARK: - Init
	
	init() {
		
	}
	
	// MARK: - Internal
	
	var dynamicTableViewModelNotificationOn: DynamicTableViewModel {
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
						.footnote(
							text: AppStrings.NotificationSettings.settingsDescription
						)
					]
				)
			)
			$0.add(
				.section(
					separators: .all,
					cells: [
						.body(
							text: AppStrings.NotificationSettings.notifications,
							accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.notifications,
							accessibilityTraits: .staticText
						),
						.space(height: 8)
					]
				)
			)
			
			$0.add(
				.section(
					background: .greyBoxed,
					cells: [
						
						// Add headline with image
						.body(
							text: AppStrings.NotificationSettings.bulletDescOn,
							accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.bulletDescOn
						),
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
						),
						.space(height: 8),
						.textWithLinks(
							text: String(
								format: AppStrings.NotificationSettings.bulletDesc2,
								AppStrings.NotificationSettings.bulletDesc2FAQText),
							links: [AppStrings.NotificationSettings.bulletDesc2FAQText: AppStrings.Links.notificationSettingsFAQ],
							accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.bulletDesc2
						),
						.custom(
							withIdentifier: NotificationSettingsViewController.ReuseIdentifiers.buttonCell,
							configure: { _, cell, _ in
								guard let cell = cell as? DynamicTableViewRoundedCell else { return }
								cell.configure(
									title: NSMutableAttributedString(
										string: ""
									),
									body: NSMutableAttributedString(
										string: ""
									),
									textColor: .textContrast,
									bgColor: .cellBackground,
									buttonTitle: AppStrings.NotificationSettings.openSystemSettings,
									buttonTapped: {
										LinkHelper.open(urlString: UIApplication.openSettingsURLString)
									}
								)
							}
						)
						// Add Button
					]
				)
			)
		}
	}
	
	var dynamicTableViewModelNotificationOff: DynamicTableViewModel {
		DynamicTableViewModel([
		
		
		])
	}
	
	// MARK: - Private

}
