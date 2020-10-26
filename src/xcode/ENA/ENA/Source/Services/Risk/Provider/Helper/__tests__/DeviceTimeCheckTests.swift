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

import XCTest
@testable import ENA

final class DeviceTimeCheckTest: XCTestCase {

	func test_WHEN_CorrectDeviceTime_THEN_DeviceTimeIsCorrectIsSavedToStore() {
		let fakeStore = MockTestStore()
		fakeStore.appConfig = makeAppConfig(killSwitchIsOn: false)

		let serverTime = Date()
		let deviceTime = Date()

		let deviceTimeCheck = DeviceTimeCheck(store: fakeStore)
		deviceTimeCheck.checkAndPersistDeviceTimeFlags(
			serverTime: serverTime,
			deviceTime: deviceTime
		)

		XCTAssertTrue(fakeStore.deviceTimeIsCorrect)
		XCTAssertFalse(fakeStore.deviceTimeErrorWasShown)
	}

	func test_WHEN_DeviceTimeIs2HoursInThePast_THEN_DeviceTimeIsCorrectIsSavedToStore() {
		let fakeStore = MockTestStore()
		fakeStore.appConfig = makeAppConfig(killSwitchIsOn: false)

		let serverTime = Date()
		guard let deviceTime = Calendar.current.date(byAdding: .hour, value: -2, to: serverTime) else {
			XCTFail("Could not create date.")
			return
		}

		let deviceTimeCheck = DeviceTimeCheck(store: fakeStore)
		deviceTimeCheck.checkAndPersistDeviceTimeFlags(
			serverTime: serverTime,
			deviceTime: deviceTime
		)

		XCTAssertTrue(fakeStore.deviceTimeIsCorrect)
		XCTAssertFalse(fakeStore.deviceTimeErrorWasShown)
	}

	func test_WHEN_DeviceTimeIsOn2HoursInTheFuture_THEN_DeviceTimeIsCorrectIsSavedToStore() {
		let fakeStore = MockTestStore()
		fakeStore.appConfig = makeAppConfig(killSwitchIsOn: false)

		let serverTime = Date()
		guard let deviceTime = Calendar.current.date(byAdding: .hour, value: 2, to: serverTime) else {
			XCTFail("Could not create date.")
			return
		}

		let deviceTimeCheck = DeviceTimeCheck(store: fakeStore)
		deviceTimeCheck.checkAndPersistDeviceTimeFlags(
			serverTime: serverTime,
			deviceTime: deviceTime
		)

		XCTAssertTrue(fakeStore.deviceTimeIsCorrect)
		XCTAssertFalse(fakeStore.deviceTimeErrorWasShown)
	}

	func test_WHEN_DeviceTimeMoreThen2HoursInThePast_THEN_DeviceTimeIsNOTCorrectIsSavedToStore() {
		let fakeStore = MockTestStore()
		fakeStore.appConfig = makeAppConfig(killSwitchIsOn: false)

		let serverTime = Date()
		guard let deviceTime = Calendar.current.date(byAdding: .minute, value: -121, to: serverTime) else {
			XCTFail("Could not create date.")
			return
		}

		let deviceTimeCheck = DeviceTimeCheck(store: fakeStore)
		deviceTimeCheck.checkAndPersistDeviceTimeFlags(
			serverTime: serverTime,
			deviceTime: deviceTime
		)

		XCTAssertFalse(fakeStore.deviceTimeIsCorrect)
		XCTAssertFalse(fakeStore.deviceTimeErrorWasShown)
	}

	func test_WHEN_DeviceTimeMoreThen2HoursInTheFuture_THEN_DeviceTimeIsNOTCorrectIsSavedToStore() {
		let fakeStore = MockTestStore()
		fakeStore.appConfig = makeAppConfig(killSwitchIsOn: false)

		let serverTime = Date()
		guard let deviceTime = Calendar.current.date(byAdding: .minute, value: 121, to: serverTime) else {
			XCTFail("Could not create date.")
			return
		}

		let deviceTimeCheck = DeviceTimeCheck(store: fakeStore)
		deviceTimeCheck.checkAndPersistDeviceTimeFlags(
			serverTime: serverTime,
			deviceTime: deviceTime
		)

		XCTAssertFalse(fakeStore.deviceTimeIsCorrect)
		XCTAssertFalse(fakeStore.deviceTimeErrorWasShown)
	}

	func test_WHEN_DeviceTimeMoreThen2HoursInTheFuture_AND_KillSwitchIsActive_THEN_DeviceTimeIsCorrectIsSavedToStore() {
		let fakeStore = MockTestStore()
		fakeStore.appConfig = makeAppConfig(killSwitchIsOn: true)

		let serverTime = Date()
		guard let deviceTime = Calendar.current.date(byAdding: .minute, value: 121, to: serverTime) else {
			XCTFail("Could not create date.")
			return
		}

		let deviceTimeCheck = DeviceTimeCheck(store: fakeStore)
		deviceTimeCheck.checkAndPersistDeviceTimeFlags(
			serverTime: serverTime,
			deviceTime: deviceTime
		)

		XCTAssertTrue(fakeStore.deviceTimeIsCorrect)
		XCTAssertFalse(fakeStore.deviceTimeErrorWasShown)
	}

	func test_WHEN_ResetDeviceTimeFlagsToDefault_THEN_DeviceTimeIsCorrectIsSavedToStore() {
		let fakeStore = MockTestStore()
		fakeStore.deviceTimeIsCorrect = false
		fakeStore.deviceTimeErrorWasShown = true

		let deviceTimeCheck = DeviceTimeCheck(store: fakeStore)
		deviceTimeCheck.resetDeviceTimeFlagsToDefault()

		XCTAssertTrue(fakeStore.deviceTimeIsCorrect)
		XCTAssertFalse(fakeStore.deviceTimeErrorWasShown)
	}

	private func makeAppConfig(killSwitchIsOn: Bool) -> SAP_ApplicationConfiguration {
		var killSwitchFeature = SAP_AppFeature()
		killSwitchFeature.label = "disable-device-time-check"
		killSwitchFeature.value = killSwitchIsOn ? 1 : 0

		var fakeAppFeatures = SAP_AppFeatures()
		fakeAppFeatures.appFeatures = [killSwitchFeature]

		var fakeAppConfig = SAP_ApplicationConfiguration()
		fakeAppConfig.appFeatures = fakeAppFeatures

		return fakeAppConfig
	}
}
