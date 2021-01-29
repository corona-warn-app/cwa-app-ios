//
// 🦠 Corona-Warn-App
//

import Foundation

protocol DeviceTimeCheckProtocol {
	func updateDeviceTimeFlags(serverTime: Date, deviceTime: Date)
	func resetDeviceTimeFlags()

	var isDeviceTimeCorrect: Bool { get }
}

final class DeviceTimeCheck: DeviceTimeCheckProtocol {

	// MARK: - Init

	init(store: Store) {
		self.store = store
	}

	// MARK: - Protocol DeviceTimeCheckProtocol

	// MARK: - Internal

	enum TimeCheckResult: Int, Codable {
		case correct
		case assumedCorrect
		case incorrect
	}

	var isDeviceTimeCorrect: Bool {
		return store.deviceTimeCheckResult == .correct
	}

	func updateDeviceTimeFlags(serverTime: Date, deviceTime: Date) {
		let oldState = store.deviceTimeCheckResult
		store.deviceTimeCheckResult = isDeviceTimeCorrect(
            serverTime: serverTime,
            deviceTime: deviceTime
        )
		// store change date only if a state change was detected
		if oldState != store.deviceTimeCheckResult {
			store.deviceTimeLastStateChange = Date()
		}

        if store.deviceTimeCheckResult == .correct {
            store.wasDeviceTimeErrorShown = false
        }
	}

	func resetDeviceTimeFlags() {
		store.deviceTimeCheckResult = .correct
		store.deviceTimeLastStateChange = Date()
		store.wasDeviceTimeErrorShown = false
	}

	// MARK: - Private

	private let store: Store

	private func isDeviceTimeCorrect(serverTime: Date, deviceTime: Date) -> TimeCheckResult {
        let killSwitchActive = isDeviceTimeCheckKillSwitchActive(config: store.appConfigMetadata?.appConfig)
		guard !killSwitchActive else {
            return .assumedCorrect
        }
		let twoHourIntevall: Double = 2 * 60 * 60
		let serverTimeMinus2Hours = serverTime.addingTimeInterval(-twoHourIntevall)
		let serverTimePlus2Hours = serverTime.addingTimeInterval(twoHourIntevall)
		return (serverTimeMinus2Hours ... serverTimePlus2Hours).contains(deviceTime) ? .correct : .incorrect
	}

	private func isDeviceTimeCheckKillSwitchActive(config: SAP_Internal_V2_ApplicationConfigurationIOS?) -> Bool {
		#if !RELEASE
		if store.dmKillDeviceTimeCheck {
			return true
		}
		#endif
		guard let config = config else {
			return false
		}

		let killSwitchFeature = config.appFeatures.appFeatures.first {
			$0.label == "disable-device-time-check"
		}
		return killSwitchFeature?.value == 1
	}
}
