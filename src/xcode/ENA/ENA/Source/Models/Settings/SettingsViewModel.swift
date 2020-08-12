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
	var tracing: CellModel = .tracing
	var notifications: CellModel = .notifications
	var backgroundAppRefresh: CellModel = .backgroundAppRefresh
	var reset: String = AppStrings.Settings.resetLabel
}

extension SettingsViewModel {
	struct CellModel {
		let icon: String
		let description: String
		var state: String?
		let stateActive: String
		let stateInactive: String
		let accessibilityIdentifier: String?
	}
}

extension SettingsViewModel.CellModel {
	static let tracing = SettingsViewModel.CellModel(
		icon: "Icons_Settings_Risikoermittlung",
		description: AppStrings.Settings.tracingLabel,
		stateActive: AppStrings.Settings.trackingStatusActive,
		stateInactive: AppStrings.Settings.trackingStatusInactive,
		accessibilityIdentifier: AccessibilityIdentifiers.Settings.tracingLabel
	)

	static let notifications = SettingsViewModel.CellModel(
		icon: "Icons_Settings_Mitteilungen",
		description: AppStrings.Settings.notificationLabel,
		stateActive: AppStrings.Settings.notificationStatusActive,
		stateInactive: AppStrings.Settings.notificationStatusInactive,
		accessibilityIdentifier: AccessibilityIdentifiers.Settings.notificationLabel
	)
	
	static let backgroundAppRefresh = SettingsViewModel.CellModel(
		icon: "Icons_Settings_Hintergrundaktualisierung",
		description: AppStrings.Settings.backgroundAppRefreshLabel,
		stateActive: AppStrings.Settings.backgroundAppRefreshStatusActive,
		stateInactive: AppStrings.Settings.backgroundAppRefreshStatusInactive,
		accessibilityIdentifier: AccessibilityIdentifiers.Settings.backgroundAppRefreshLabel
	)

	mutating func setState(state newState: Bool) {
		state = newState ? stateActive : stateInactive
	}
}
