//
// 🦠 Corona-Warn-App
//

import Foundation

class NotificationSettingsViewModel {
	let notificationsOn: Bool
	let image: String
	let imageDescription: String
	let title: String?
	let sections: [Section]
	let openSettings: OpenSettings?

	private init(
		notificationsOn: Bool,
		image: String,
		imageDescription: String,
		title: String?,
		sections: [Section],
		openSettings: OpenSettings?,
		accessibilityLabel: String?,
		accessibilityIdentifier: String?
	) {
		self.notificationsOn = notificationsOn
		self.image = image
		self.imageDescription = imageDescription
		self.title = title
		self.sections = sections
		self.openSettings = openSettings
	}

	static func notificationsOn(_ store: Store) -> NotificationSettingsViewModel {
		NotificationSettingsViewModel(
			notificationsOn: true,
			image: "Illu_Mitteilungen_On",
			imageDescription: AppStrings.NotificationSettings.onImageDescription,
			title: AppStrings.NotificationSettings.onTitle,
			sections: [
				.settingsOn(
					title: AppStrings.NotificationSettings.onSectionTitle,
					cells: [
						.riskChanges(.init(
							description: AppStrings.NotificationSettings.riskChanges,
							state: store.allowRiskChangesNotification,
							updateState: { store.allowRiskChangesNotification = $0 },
							accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.riskChanges
						)),
						.testsStatus(.init(
							description: AppStrings.NotificationSettings.testsStatus,
							state: store.allowTestsStatusNotification,
							updateState: { store.allowTestsStatusNotification = $0 },
							accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.testsStatus
						))
					]
				)
			],
			openSettings: nil,
			accessibilityLabel: AppStrings.NotificationSettings.onTitle,
			accessibilityIdentifier: AccessibilityIdentifiers.NotificationSettings.onTitle
		)
	}

	static func notificationsOff() -> NotificationSettingsViewModel {
		NotificationSettingsViewModel(
			notificationsOn: false,
			image: "Illu_Mitteilungen_Off",
			imageDescription: AppStrings.NotificationSettings.offImageDescription,
			title: nil,
			sections: [
				.settingsOff(
					title: AppStrings.NotificationSettings.offSectionTitle,
					cells: [
						.enableNotifications(.init(
							description: AppStrings.NotificationSettings.enableNotifications,
							state: AppStrings.NotificationSettings.statusInactive
						))
					]
				)
			],
			openSettings: OpenSettings(
				title: AppStrings.NotificationSettings.infoTitle,
				icon: "Icons_iOS_Mitteilungen",
				description: AppStrings.NotificationSettings.infoDescription,
				openSettings: AppStrings.NotificationSettings.openSettings
			),
			accessibilityLabel: nil,
			accessibilityIdentifier: nil
		)
	}
}

extension NotificationSettingsViewModel {
	enum SettingsItems {
		case riskChanges(SettingsOnItem)
		case testsStatus(SettingsOnItem)

		case enableNotifications(SettingsOffItem)
	}

	struct SettingsOnItem {
		let identifier = NotificationSettingsViewController.ReuseIdentifier.notificationsOn
		let description: String
		var state: Bool {
			didSet {
				updateState(state)
			}
		}

		let updateState: (Bool) -> Void
		let accessibilityIdentifier: String?

	}

	struct SettingsOffItem {
		let identifier = NotificationSettingsViewController.ReuseIdentifier.notificationsOff
		let description: String
		let state: String
	}

	struct OpenSettings {
		let title: String
		let icon: String
		let description: String
		let openSettings: String
	}
}

extension NotificationSettingsViewModel {
	enum Section {
		case settingsOn(title: String, cells: [SettingsItems])
		case settingsOff(title: String, cells: [SettingsItems])
	}
}
