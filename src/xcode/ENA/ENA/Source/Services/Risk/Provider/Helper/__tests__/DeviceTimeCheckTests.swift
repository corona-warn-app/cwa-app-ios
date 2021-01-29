//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class DeviceTimeCheckTest: XCTestCase {

	func test_WHEN_CorrectDeviceTime_THEN_DeviceTimeIsCorrectIsSavedToStore() {
		let fakeStore = MockTestStore()
		fakeStore.appConfigMetadata = makeAppConfig(killSwitchIsOn: false)

		let serverTime = Date()
		let deviceTime = Date()

		let deviceTimeCheck = DeviceTimeCheck(store: fakeStore)
		deviceTimeCheck.updateDeviceTimeFlags(
			serverTime: serverTime,
			deviceTime: deviceTime,
			configUpdateSuccessful: true
		)

		XCTAssertEqual(fakeStore.deviceTimeCheckResult, .correct)
		XCTAssertFalse(fakeStore.wasDeviceTimeErrorShown)
	}

	func test_WHEN_DeviceTimeIs2HoursInThePast_THEN_DeviceTimeIsCorrectIsSavedToStore() {
		let fakeStore = MockTestStore()
		fakeStore.appConfigMetadata = makeAppConfig(killSwitchIsOn: false)
		let twoHourIntevall: Double = 2 * 60 * 60

		let serverTime = Date()
		let deviceTime = serverTime.addingTimeInterval(-twoHourIntevall)

		let deviceTimeCheck = DeviceTimeCheck(store: fakeStore)
		deviceTimeCheck.updateDeviceTimeFlags(
			serverTime: serverTime,
			deviceTime: deviceTime,
			configUpdateSuccessful: true
		)

		XCTAssertEqual(fakeStore.deviceTimeCheckResult, .correct)
		XCTAssertFalse(fakeStore.wasDeviceTimeErrorShown)
	}

	func test_WHEN_DeviceTimeIsOn2HoursInTheFuture_THEN_DeviceTimeIsCorrectIsSavedToStore() {
		let fakeStore = MockTestStore()
		fakeStore.appConfigMetadata = makeAppConfig(killSwitchIsOn: false)
		let twoHourIntevall: Double = 2 * 60 * 60

		let serverTime = Date()
		let deviceTime = serverTime.addingTimeInterval(twoHourIntevall)

		let deviceTimeCheck = DeviceTimeCheck(store: fakeStore)
		deviceTimeCheck.updateDeviceTimeFlags(
			serverTime: serverTime,
			deviceTime: deviceTime,
			configUpdateSuccessful: true
		)

		XCTAssertEqual(fakeStore.deviceTimeCheckResult, .correct)
		XCTAssertFalse(fakeStore.wasDeviceTimeErrorShown)
	}

	func test_WHEN_DeviceTimeMoreThen2HoursInThePast_THEN_DeviceTimeIsNOTCorrectIsSavedToStore() {
		let fakeStore = MockTestStore()
		fakeStore.appConfigMetadata = makeAppConfig(killSwitchIsOn: false)
		let twoHourOneSecondIntevall: Double = 2 * 60 * 60 + 1

		let serverTime = Date()
		let deviceTime = serverTime.addingTimeInterval(-twoHourOneSecondIntevall)

		let deviceTimeCheck = DeviceTimeCheck(store: fakeStore)
		deviceTimeCheck.updateDeviceTimeFlags(
			serverTime: serverTime,
			deviceTime: deviceTime,
			configUpdateSuccessful: true
		)

		XCTAssertEqual(fakeStore.deviceTimeCheckResult, .incorrect)
		XCTAssertFalse(fakeStore.wasDeviceTimeErrorShown)
	}

	func test_WHEN_DeviceTimeMoreThen2HoursInTheFuture_THEN_DeviceTimeIsNOTCorrectIsSavedToStore() {
		let fakeStore = MockTestStore()
		fakeStore.appConfigMetadata = makeAppConfig(killSwitchIsOn: false)
		let twoHourOneSecondIntevall: Double = 2 * 60 * 60 + 1

		let serverTime = Date()
		let deviceTime = serverTime.addingTimeInterval(twoHourOneSecondIntevall)

		let deviceTimeCheck = DeviceTimeCheck(store: fakeStore)
		deviceTimeCheck.updateDeviceTimeFlags(
			serverTime: serverTime,
			deviceTime: deviceTime,
			configUpdateSuccessful: true
		)

		XCTAssertEqual(fakeStore.deviceTimeCheckResult, .incorrect)
		XCTAssertFalse(fakeStore.wasDeviceTimeErrorShown)
	}

	func test_WHEN_DeviceTimeMoreThen2HoursInTheFuture_AND_KillSwitchIsActive_THEN_DeviceTimeIsCorrectIsSavedToStore() {
		let fakeStore = MockTestStore()
		fakeStore.appConfigMetadata = makeAppConfig(killSwitchIsOn: true)

		let serverTime = Date()
		guard let deviceTime = Calendar.current.date(byAdding: .minute, value: 121, to: serverTime) else {
			XCTFail("Could not create date.")
			return
		}

		let deviceTimeCheck = DeviceTimeCheck(store: fakeStore)
		deviceTimeCheck.updateDeviceTimeFlags(
			serverTime: serverTime,
			deviceTime: deviceTime,
			configUpdateSuccessful: true
		)

		XCTAssertEqual(fakeStore.deviceTimeCheckResult, .assumedCorrect)
		XCTAssertFalse(fakeStore.wasDeviceTimeErrorShown)
	}

	func test_WHEN_ResetDeviceTimeFlagsToDefault_THEN_DeviceTimeIsCorrectIsSavedToStore() {
		let fakeStore = MockTestStore()
		fakeStore.deviceTimeCheckResult = .incorrect
		fakeStore.wasDeviceTimeErrorShown = true

		let deviceTimeCheck = DeviceTimeCheck(store: fakeStore)
		deviceTimeCheck.resetDeviceTimeFlags(configUpdateSuccessful: true)

		XCTAssertEqual(fakeStore.deviceTimeCheckResult, .correct)
		XCTAssertFalse(fakeStore.wasDeviceTimeErrorShown)
	}

	private func makeAppConfig(killSwitchIsOn: Bool) -> AppConfigMetadata {
		var killSwitchFeature = SAP_Internal_V2_AppFeature()
		killSwitchFeature.label = "disable-device-time-check"
		killSwitchFeature.value = killSwitchIsOn ? 1 : 0

		var fakeAppFeatures = SAP_Internal_V2_AppFeatures()
		fakeAppFeatures.appFeatures = [killSwitchFeature]

		var fakeAppConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		fakeAppConfig.appFeatures = fakeAppFeatures

		let configMetadata = AppConfigMetadata(lastAppConfigETag: "\"SomeETag\"", lastAppConfigFetch: Date(), appConfig: fakeAppConfig)

		return configMetadata
	}
}
