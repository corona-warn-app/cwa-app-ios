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
	func checkAndPersistDeviceTimeFlags(serverTime: Date, deviceTime: Date)
	func resetDeviceTimeFlagsToDefault()
}

final class DeviceTimeCheck: DeviceTimeCheckProtocol {

	private let store: AppConfigCaching

	init(store: AppConfigCaching) {
		self.store = store
	}

	func checkAndPersistDeviceTimeFlags(serverTime: Date, deviceTime: Date) {
		self.persistDeviceTimeCheckFlags(
			deviceTimeIsCorrect: self.isDeviceTimeCorrect(
				serverTime: serverTime,
				deviceTime: deviceTime
			),
			deviceTimeCheckKillSwitchIsActive: self.isDeviceTimeCheckKillSwitchActive(
				config: self.store.appConfig
			)
		)
	}

	func resetDeviceTimeFlagsToDefault() {
		store.deviceTimeIsCorrect = true
		store.deviceTimeErrorWasShown = false
	}

	private func persistDeviceTimeCheckFlags(
		deviceTimeIsCorrect: Bool,
		deviceTimeCheckKillSwitchIsActive: Bool
	) {
		store.deviceTimeIsCorrect = deviceTimeCheckKillSwitchIsActive ? true : deviceTimeIsCorrect
		if deviceTimeIsCorrect {
			store.deviceTimeErrorWasShown = false
		}
	}

	private func isDeviceTimeCorrect(serverTime: Date, deviceTime: Date) -> Bool {
		if let serverTimeMinus2Hours = Calendar.current.date(byAdding: .hour, value: -2, to: serverTime),
		   let serverTimePlus2Hours = Calendar.current.date(byAdding: .hour, value: 2, to: serverTime) {
			return (serverTimeMinus2Hours ... serverTimePlus2Hours).contains(deviceTime)
		} else {
			return true
		}
	}

	private func isDeviceTimeCheckKillSwitchActive(config: SAP_ApplicationConfiguration?) -> Bool {
		if let config = config {
			let killSwitchFeature = config.appFeatures.appFeatures.first {
				$0.label == "disable-device-time-check"
			}
			return killSwitchFeature?.value == 1
		} else {
			return false
		}
	}
}
