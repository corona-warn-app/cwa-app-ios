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
						accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.DeltaOnboarding.imageOn,
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
						.doubleLabels(
							text1: AppStrings.NotificationSettings.notifications,
							text2: AppStrings.NotificationSettings.notificationsOn,
							style: .body,
							accessibilityIdentifier1: AccessibilityIdentifiers.NotificationSettings.notifications,
							accessibilityIdentifier2: AccessibilityIdentifiers.NotificationSettings.notificationsOn,
							accessibilityTraits1: .staticText,
							accessibilityTraits2: .staticText
						),
						.space(height: 16)
					]
				)
			)
			
			$0.add(
				.section(
					background: .greyBoxed,
					cells: [
						.icon(
							UIImage(imageLiteralResourceName: "Icons_iOS_Mitteilungen"),
							imageAlignment: .right,
							text: .string(AppStrings.NotificationSettings.bulletHeadlineOn),
							style: .title2
						),
						.body(
							text: AppStrings.NotificationSettings.bulletDescOn,
							accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.bulletDescOn
						),
						.space(height: 8),
						.bulletPoint(
							text: AppStrings.NotificationSettings.bulletPoint1,
							spacing: .large,
							accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.bulletPoint1
						),
						.space(height: 8),
						.bulletPoint(
							text: AppStrings.NotificationSettings.bulletPoint2,
							spacing: .large,
							accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.bulletPoint2
						),
						.space(height: 8),
						.bulletPoint(
							text: AppStrings.NotificationSettings.bulletPoint3,
							spacing: .large,
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
									textColor: .textContrast,
									bgColor: .cellBackground3,
									buttonTitle: AppStrings.NotificationSettings.openSystemSettings,
									buttonTapped: {
										LinkHelper.open(urlString: UIApplication.openSettingsURLString)
									},
									buttonAccessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.openSystemSettings
								)
							}
						)
					]
				)
			)
		}
	}
	
	var dynamicTableViewModelNotificationOff: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					header: .image(
						UIImage(named: "Illu_Mitteilungen_Off"),
						accessibilityLabel: AppStrings.NotificationSettings.imageDescriptionOff,
						accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.DeltaOnboarding.imageOff,
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
						.doubleLabels(
							text1: AppStrings.NotificationSettings.notifications,
							text2: AppStrings.NotificationSettings.notificationsOff,
							style: .body,
							accessibilityIdentifier1: AccessibilityIdentifiers.NotificationSettings.notifications,
							accessibilityIdentifier2: AccessibilityIdentifiers.NotificationSettings.notificationsOff,
							accessibilityTraits1: .staticText,
							accessibilityTraits2: .staticText
						),
						.space(height: 16)
					]
				)
			)
			
			$0.add(
				.section(
					background: .greyBoxed,
					cells: [
						.space(height: 5),
						.icon(
							UIImage(imageLiteralResourceName: "Icons_iOS_Mitteilungen"),
							imageAlignment: .right,
							text: .string(AppStrings.NotificationSettings.bulletHeadlineOn),
							style: .title2
						),
						.body(
							text: AppStrings.NotificationSettings.bulletDescOff,
							accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.bulletDescOff
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
									bgColor: .cellBackground3,
									buttonTitle: AppStrings.NotificationSettings.openSystemSettings,
									buttonTapped: {
										LinkHelper.open(urlString: UIApplication.openSettingsURLString)
									},
									buttonAccessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.openSystemSettings
								)
							}
						)
					]
				)
			)
		}
	}
}
