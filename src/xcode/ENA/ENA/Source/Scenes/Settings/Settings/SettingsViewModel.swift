//
// 🦠 Corona-Warn-App
//

import Foundation

final class SettingsViewModel {
	// MARK: Properties
	var tracing: CellModel = .tracing
	var notifications: CellModel = .notifications
	var backgroundAppRefresh: CellModel = .backgroundAppRefresh
	var reset: String = AppStrings.Settings.resetLabel
	var datadonation: CellModel = .dataDonation
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

	static let dataDonation = SettingsViewModel.CellModel(
		icon: "Icons_Settings_Datenspende",
		description: AppStrings.Settings.Datadonation.label,
		stateActive: AppStrings.Settings.Datadonation.statusActive,
		stateInactive: AppStrings.Settings.Datadonation.statusInactive,
		accessibilityIdentifier: AccessibilityIdentifiers.Settings.dataDonation
	)

	mutating func setState(state newState: Bool) {
		state = newState ? stateActive : stateInactive
	}
}
