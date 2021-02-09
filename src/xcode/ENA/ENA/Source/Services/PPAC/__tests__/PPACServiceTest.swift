////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class PPACServiceTest: XCTestCase {

	func testGIVEN_DeviceTimeIsIncorract_WHEN_InitPPACService_THEN_FailWithError() {
		// GIVEN
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
		store.deviceTimeCheckResult = .incorrect
		let failedExpectation = expectation(description: "Init failed")

		// WHEN
		do {
			_ = try PPACService(store: store, deviceCheck: deviceCheck)
		} catch PPACError.timeIncorrect {
			failedExpectation.fulfill()
		} catch {
			XCTFail("unexpected error")
		}

		// THEN
		wait(for: [failedExpectation], timeout: .medium)
	}

	func testGIVEN_DeviceTimeIsAssumeCorrect_WHEN_InitPPACService_THEN_FailWithError() {
		// GIVEN
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
		store.deviceTimeCheckResult = .assumedCorrect
		let failedExpectation = expectation(description: "Init failed")

		// WHEN
		do {
			_ = try PPACService(store: store, deviceCheck: deviceCheck)
		} catch PPACError.timeUnverified {
			failedExpectation.fulfill()
		} catch {
			XCTFail("unexpected error")
		}

		// THEN
		wait(for: [failedExpectation], timeout: .medium)
	}

	func testGIVEN_DeviceTimeIsCorrect_WHEN_InitPPACService_THEN_Success() throws {
		// GIVEN
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
		store.deviceTimeCheckResult = .correct

		// WHEN
		let ppacService = try PPACService(store: store, deviceCheck: deviceCheck)
		// THEN
		XCTAssertNotNil(ppacService)

	}

	func testGIVEN_DeviceIsNotSupported_WHEN_PPACService_THEN_ErrorDeviceNotSupported() {
		// GIVEN
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(false, deviceToken: "iPhone")
		store.deviceTimeCheckResult = .correct
		let failedExpectation = expectation(description: "device not supported")

		// WHEN
		do {
			let ppacService = try PPACService(store: store, deviceCheck: deviceCheck)
			// THEN
			XCTAssertNotNil(ppacService)

		} catch PPACError.deviceNotSupported {
			failedExpectation.fulfill()
		} catch {
			XCTFail("unexpected error")
		}

		// THEN
		wait(for: [failedExpectation], timeout: .medium)
	}

	func testGIVEN_StoreHasNoAPIToken_WHEN_getPPACToken_THEN_APITokenIsInStore() throws {
		// GIVEN
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")

		store.deviceTimeCheckResult = .correct
		let ppacExpectation = expectation(description: "Init failed")

		// WHEN
		let ppacService = try PPACService(store: store, deviceCheck: deviceCheck)
		ppacService.getPPACToken({ result in
			switch result {
			case let .success(ppaToken):
				ppacExpectation.fulfill()
				XCTAssertNotNil(store.ppacApiToken)
				XCTAssertEqual(store.ppacApiToken?.token, ppaToken.apiToken)

			case .failure:
				XCTFail("Unexpected error happend")
			}
		})

		// THEN
		wait(for: [ppacExpectation], timeout: .long)
	}

	func testGIVEN_NoStoredAPIToken_WHEN_generateAPIToken_THEN_NewTokenCreatedAndStored() throws {
		// GIVEN
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")

		// WHEN
		let ppacService = try PPACService(store: store, deviceCheck: deviceCheck)
		let timestampedToken = ppacService.generateNewAPIToken()

		// THEN
		XCTAssertNotNil(store.ppacApiToken)
		XCTAssertEqual(timestampedToken.timestamp, store.ppacApiToken?.timestamp)
		XCTAssertEqual(timestampedToken.token, store.ppacApiToken?.token)
	}

	func testGIVEN_ValidStoredAPIToken_WHEN_generateAPITokenb_THEN_NewTokenCreatedAndStored() throws {
		// GIVEN
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")

		let uuid = UUID().uuidString
		let today = Date()
		store.ppacApiToken = TimestampedToken(token: uuid, timestamp: today)

		// WHEN
		let ppacService = try PPACService(store: store, deviceCheck: deviceCheck)
		let timestampedToken = ppacService.generateNewAPIToken()

		// THEN
		XCTAssertNotNil(store.ppacApiToken)
		XCTAssertNotEqual(timestampedToken.timestamp, today)
		XCTAssertNotEqual(timestampedToken.token, uuid)
		XCTAssertEqual(timestampedToken.timestamp, store.ppacApiToken?.timestamp)
		XCTAssertEqual(timestampedToken.token, store.ppacApiToken?.token)
	}

}
