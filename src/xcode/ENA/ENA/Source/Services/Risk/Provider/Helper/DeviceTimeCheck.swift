//
// 🦠 Corona-Warn-App
//

import Foundation

protocol DeviceTimeCheckProtocol {
	func updateDeviceTimeFlags(serverTime: Date, deviceTime: Date)
	func resetDeviceTimeFlags()

	var isDeviceTimeCorrect: Bool { get }
	var wasDeviceTimeErrorShown: Bool { get }
}

final class DeviceTimeCheck: DeviceTimeCheckProtocol {

	// MARK: - Init

	init(store: Store) {
		self.store = store
	}

	// MARK: - Protocol DeviceTimeCheckProtocol

	// MARK: - Internal

	var isDeviceTimeCorrect: Bool {
		store.isDeviceTimeCorrect
	}

	var wasDeviceTimeErrorShown: Bool {
		store.isDeviceTimeCorrect
	}

	func updateDeviceTimeFlags(serverTime: Date, deviceTime: Date) {
		self.persistDeviceTimeCheckFlags(
			isDeviceTimeCorrect: self.isDeviceTimeCorrect(
				serverTime: serverTime,
				deviceTime: deviceTime
			),
			isDeviceTimeCheckKillSwitchActive: self.isDeviceTimeCheckKillSwitchActive(
				config: self.store.appConfigMetadata?.appConfig
			)
		)
	}

	func resetDeviceTimeFlags() {
		store.isDeviceTimeCorrect = true
		store.wasDeviceTimeErrorShown = false
	}

	// MARK: - Private

	private let store: Store

	private func persistDeviceTimeCheckFlags(
		isDeviceTimeCorrect: Bool,
		isDeviceTimeCheckKillSwitchActive: Bool
	) {
		store.isDeviceTimeCorrect = isDeviceTimeCheckKillSwitchActive ? true : isDeviceTimeCorrect
		if store.isDeviceTimeCorrect {
			store.wasDeviceTimeErrorShown = false
		}
	}

	private func isDeviceTimeCorrect(serverTime: Date, deviceTime: Date) -> Bool {
		let twoHourIntevall: Double = 2 * 60 * 60
		let serverTimeMinus2Hours = serverTime.addingTimeInterval(-twoHourIntevall)
		let serverTimePlus2Hours = serverTime.addingTimeInterval(twoHourIntevall)
		return (serverTimeMinus2Hours ... serverTimePlus2Hours).contains(deviceTime)
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
