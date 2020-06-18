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

final class SettingsViewModel {
	// MARK: Properties
	var tracing: Main
	var notifications: Main
	var reset: String

	// MARK: Creating a Settings View Model
	init(
		tracing: Main = .tracing,
		notifications: Main = .notifications,
		reset: String = AppStrings.Settings.resetLabel
	) {
		self.tracing = tracing
		self.notifications = notifications
		self.reset = reset
	}
}

extension SettingsViewModel {
	struct Main {
		let icon: String
		let description: String
		var state: String?
		let stateActive: String
		let stateInactive: String
		let accessibilityIdentifier: String?
	}
}

extension SettingsViewModel.Main {
	static let tracing = SettingsViewModel.Main(
		icon: "Icons_Settings_Risikoermittlung",
		description: AppStrings.Settings.tracingLabel,
		stateActive: AppStrings.Settings.trackingStatusActive,
		stateInactive: AppStrings.Settings.trackingStatusInactive,
		accessibilityIdentifier: AccessibilityIdentifiers.Settings.tracingLabel
	)

	static let notifications = SettingsViewModel.Main(
		icon: "Icons_Settings_Mitteilungen",
		description: AppStrings.Settings.notificationLabel,
		stateActive: AppStrings.Settings.notificationStatusActive,
		stateInactive: AppStrings.Settings.notificationStatusInactive,
		accessibilityIdentifier: AccessibilityIdentifiers.Settings.notificationLabel
	)

	mutating func setState(state newState: Bool) {
		state = newState ? stateActive : stateInactive
	}
}
