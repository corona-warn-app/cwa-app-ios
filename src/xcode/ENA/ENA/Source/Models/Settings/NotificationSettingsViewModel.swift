// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import Foundation

class NotificationSettingsViewModel {
	let notificationsOn: Bool
	let image: String
	let title: String
	let description: String
	let sections: [Section]

	private init(notificationsOn: Bool, image: String, title: String, description: String, sections: [Section]) {
		self.notificationsOn = notificationsOn
		self.image = image
		self.title = title
		self.description = description
		self.sections = sections
	}

	static func notificationsOn(_ store: Store) -> NotificationSettingsViewModel {
		NotificationSettingsViewModel(
			notificationsOn: true,
			image: "Illu_Mitteilungen_On",
			title: AppStrings.NotificationSettings.onTitle,
			description: AppStrings.NotificationSettings.onDescription,
			sections: [
				.settingsOn(
					title: AppStrings.NotificationSettings.onSectionTitle,
					cells: [
						.riskChanges(.init(
							description: AppStrings.NotificationSettings.riskChanges,
							state: store.allowRiskChangesNotification,
							updateState: { store.allowRiskChangesNotification = $0 }
						)),
						.testsStatus(.init(
							description: AppStrings.NotificationSettings.testsStatus,
							state: store.allowTestsStatusNotification,
							updateState: { store.allowTestsStatusNotification = $0 }
						))
					]
				)
			]
		)
	}

	static func notificationsOff() -> NotificationSettingsViewModel {
		NotificationSettingsViewModel(
			notificationsOn: false,
			image: "Illu_Mitteilungen_Off",
			title: AppStrings.NotificationSettings.offTitle,
			description: AppStrings.NotificationSettings.offDescription,
			sections: [
				.settingsOff(
					cells: [
						.navigateSettings(.init(
							icon: "Icons_iOS_Settings",
							description: AppStrings.NotificationSettings.navigateSettings
						)),
						.pickNotifications(.init(
							icon: "Icons_iOS_Mitteilungen",
							description: AppStrings.NotificationSettings.pickNotifications
						)),
						.enableNotifications(.init(
							icon: "Icons_iOS_Mitteilungen",
							description: AppStrings.NotificationSettings.enableNotifications
						))
					]
				),
				.openSettings(
					cell: .openSettings(title: AppStrings.NotificationSettings.openSettings)
				)
			]
		)
	}
}

extension NotificationSettingsViewModel {
	enum SettingsItems {
		case riskChanges(SettingsOnItem)
		case testsStatus(SettingsOnItem)

		case navigateSettings(SettingsOffItem)
		case pickNotifications(SettingsOffItem)
		case enableNotifications(SettingsOffItem)
		case openSettings(identifier: String = "openSettings", title: String)
	}

	struct SettingsOnItem {
		let identifier = "notificationsOn"
		let description: String
		var state: Bool {
			didSet {
				updateState(state)
			}
		}

		let updateState: (Bool) -> Void
	}

	struct SettingsOffItem {
		let identifier = "notificationsOff"
		let icon: String
		let description: String
	}
}

extension NotificationSettingsViewModel {
	enum Section {
		case settingsOn(title: String, cells: [SettingsItems])
		case settingsOff(cells: [SettingsItems])
		case openSettings(cell: SettingsItems)
	}
}
