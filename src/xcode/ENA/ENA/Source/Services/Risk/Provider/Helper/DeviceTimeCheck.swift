//
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
				config: self.store.appConfig
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
		guard let config = config else {
			return false
		}

		let killSwitchFeature = config.appFeatures.appFeatures.first {
			$0.label == "disable-device-time-check"
		}
		return killSwitchFeature?.value == 1
	}
}
