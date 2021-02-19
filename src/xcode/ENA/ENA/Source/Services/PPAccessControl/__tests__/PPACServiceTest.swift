////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class PPACServiceTest: XCTestCase {

	func testGIVEN_DeviceTimeIsIncorract_WHEN_getPPACToken_THEN_FailWithError() {
		// GIVEN
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
		store.deviceTimeCheckResult = .incorrect
		let failedExpectation = expectation(description: "getPPACToken failed")

		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		ppacService.getPPACToken { result in
			switch result {
			case .failure(let error):
				XCTAssertEqual(.timeIncorrect, error)
				failedExpectation.fulfill()
			case .success:
				XCTFail("Success was not expected.")
			}
		}

		// THEN
		wait(for: [failedExpectation], timeout: .medium)
	}

	func testGIVEN_DeviceTimeIsAssumeCorrect_WHEN_getPPACToken_THEN_FailWithError() {
		// GIVEN
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
		store.deviceTimeCheckResult = .assumedCorrect
		let failedExpectation = expectation(description: "getPPACToken failed")

		// WHEN
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		ppacService.getPPACToken { result in
			switch result {
			case .failure(let error):
				XCTAssertEqual(.timeUnverified, error)
				failedExpectation.fulfill()
			case .success:
				XCTFail("Success was not expected.")
			}
		}

		// THEN
		wait(for: [failedExpectation], timeout: .medium)
	}

	func testGIVEN_DeviceTimeIsCorrect_WHEN_getPPACToken_THEN_Success() throws {
		// GIVEN
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
		store.deviceTimeCheckResult = .correct
		let successExpectation = expectation(description: "getPPACToken succeeded")

		// WHEN
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		ppacService.getPPACToken { result in
			switch result {
			case .failure:
				XCTFail("Failure not expected.")
			case .success:
				successExpectation.fulfill()
			}
		}

		// THEN
		wait(for: [successExpectation], timeout: .medium)
	}

	func testGIVEN_DeviceIsNotSupported_WHEN_getPPACToken_THEN_ErrorDeviceNotSupported() {
		// GIVEN
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(false, deviceToken: "iPhone")
		store.deviceTimeCheckResult = .correct
		let failedExpectation = expectation(description: "device not supported")

		// WHEN
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		ppacService.getPPACToken { result in
			switch result {
			case .failure(let error):
				XCTAssertEqual(.deviceNotSupported, error)
				failedExpectation.fulfill()
			case .success:
				XCTFail("Success was not expected.")
			}
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
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
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
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
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
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let timestampedToken = ppacService.generateNewAPIToken()

		// THEN
		XCTAssertNotNil(store.ppacApiToken)
		XCTAssertNotEqual(timestampedToken.timestamp, today)
		XCTAssertNotEqual(timestampedToken.token, uuid)
		XCTAssertEqual(timestampedToken.timestamp, store.ppacApiToken?.timestamp)
		XCTAssertEqual(timestampedToken.token, store.ppacApiToken?.token)
	}

}
