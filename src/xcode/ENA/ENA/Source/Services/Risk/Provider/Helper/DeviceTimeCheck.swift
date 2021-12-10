//
// 🦠 Corona-Warn-App
//

import Foundation

protocol DeviceTimeChecking {
	func updateDeviceTimeFlags(serverTime: Date, deviceTime: Date, configUpdateSuccessful: Bool)
	func resetDeviceTimeFlags(configUpdateSuccessful: Bool)

	var isDeviceTimeCorrect: Bool { get }
}

final class DeviceTimeCheck: DeviceTimeChecking {

	// MARK: - Init

	init(
		store: AppConfigCaching & DeviceTimeCheckStoring,
		appFeatureProvider: AppFeatureProviding
	) {
		self.store = store
		self.appFeatureProvider = appFeatureProvider
	}

	// MARK: - Protocol DeviceTimeChecking

	var isDeviceTimeCorrect: Bool {
		return store.deviceTimeCheckResult == .correct || store.deviceTimeCheckResult == .assumedCorrect
	}

	func updateDeviceTimeFlags(serverTime: Date, deviceTime: Date, configUpdateSuccessful: Bool) {
		let oldState = store.deviceTimeCheckResult
		store.deviceTimeCheckResult = isDeviceTimeCorrect(
			serverTime: serverTime,
			deviceTime: deviceTime,
			configUpdateSuccessful: configUpdateSuccessful
		)
		// store change date only if a state change was detected
		if oldState != store.deviceTimeCheckResult {
			store.deviceTimeLastStateChange = Date()
		}

		if store.deviceTimeCheckResult == .correct {
			store.wasDeviceTimeErrorShown = false
		}
	}

	func resetDeviceTimeFlags(configUpdateSuccessful: Bool) {
		store.deviceTimeCheckResult = configUpdateSuccessful ? .correct : .assumedCorrect
		store.deviceTimeLastStateChange = Date()
		store.wasDeviceTimeErrorShown = false
	}

	// MARK: - Internal

	enum TimeCheckResult: Int, Codable {
		case correct
		case assumedCorrect
		case incorrect
	}

	// MARK: - Private

	private let store: AppConfigCaching & DeviceTimeCheckStoring
	private let appFeatureProvider: AppFeatureProviding

	private func isDeviceTimeCorrect(serverTime: Date, deviceTime: Date, configUpdateSuccessful: Bool) -> TimeCheckResult {

		let killSwitchActive = appFeatureProvider.boolValue(for: .disableDeviceTimeCheck)
		guard !killSwitchActive,
			  configUpdateSuccessful else {
			return .assumedCorrect
		}
		let twoHourIntervall: Double = 2 * 60 * 60
		let serverTimeMinus2Hours = serverTime.addingTimeInterval(-twoHourIntervall)
		let serverTimePlus2Hours = serverTime.addingTimeInterval(twoHourIntervall)
		return (serverTimeMinus2Hours ... serverTimePlus2Hours).contains(deviceTime) ? .correct : .incorrect
	}
}
