////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class PPACServiceTest: CWATestCase {

	func testGIVEN_DeviceTimeIsIncorrect_WHEN_getPPACTokenEdus_THEN_FailWithError() {
		// GIVEN
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
		store.deviceTimeCheckResult = .incorrect
		let failedExpectation = expectation(description: "getPPACToken failed")

		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		ppacService.getPPACTokenEDUS { result in
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

	func testGIVEN_DeviceTimeIsAssumeCorrect_WHEN_getPPACTokenEdus_THEN_FailWithError() {
		// GIVEN
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
		store.deviceTimeCheckResult = .assumedCorrect
		let failedExpectation = expectation(description: "getPPACToken failed")

		// WHEN
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		ppacService.getPPACTokenEDUS { result in
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

	func testGIVEN_DeviceTimeIsCorrect_WHEN_getPPACTokenEdus_THEN_Success() throws {
		// GIVEN
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
		store.deviceTimeCheckResult = .correct
		let successExpectation = expectation(description: "getPPACToken succeeded")

		// WHEN
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		ppacService.getPPACTokenEDUS { result in
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

	func testGIVEN_DeviceIsNotSupported_WHEN_getPPACTokenEdus_THEN_ErrorDeviceNotSupported() {
		// GIVEN
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(false, deviceToken: "iPhone")
		store.deviceTimeCheckResult = .correct
		let failedExpectation = expectation(description: "device not supported")

		// WHEN
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		ppacService.getPPACTokenEDUS { result in
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

	func testGIVEN_StoreHasNoAPIToken_WHEN_getPPACTokenEdus_THEN_APITokenIsInStore() throws {
		// GIVEN
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")

		store.deviceTimeCheckResult = .correct
		let ppacExpectation = expectation(description: "Init failed")

		// WHEN
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		ppacService.getPPACTokenEDUS({ result in
			switch result {
			case let .success(ppaToken):
				ppacExpectation.fulfill()
				XCTAssertNotNil(store.apiTokenPPAC)
				XCTAssertEqual(store.apiTokenPPAC?.token, ppaToken.apiToken)

			case .failure:
				XCTFail("Unexpected error happened")
			}
		})

		// THEN
		wait(for: [ppacExpectation], timeout: .long)
	}

	func testGIVEN_NoStoredAPIToken_WHEN_generateAPITokenEdus_THEN_NewTokenCreatedAndStored() throws {
		// GIVEN
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")

		// WHEN
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let timestampedToken = ppacService.generateNewAPITokenPPAC()

		// THEN
		XCTAssertNotNil(store.apiTokenPPAC)
		XCTAssertEqual(timestampedToken.timestamp, store.apiTokenPPAC?.timestamp)
		XCTAssertEqual(timestampedToken.token, store.apiTokenPPAC?.token)
	}

	func testGIVEN_ValidStoredAPIToken_WHEN_generateAPITokenEdus_THEN_NewTokenCreatedAndStored() throws {
		// GIVEN
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")

		let uuid = UUID().uuidString
		let today = Date()
		store.apiTokenPPAC = TimestampedToken(token: uuid, timestamp: today)

		// WHEN
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		let timestampedToken = ppacService.generateNewAPITokenPPAC()

		// THEN
		XCTAssertNotNil(store.apiTokenPPAC)
		XCTAssertNotEqual(timestampedToken.timestamp, today)
		XCTAssertNotEqual(timestampedToken.token, uuid)
		XCTAssertEqual(timestampedToken.timestamp, store.apiTokenPPAC?.timestamp)
		XCTAssertEqual(timestampedToken.token, store.apiTokenPPAC?.token)
	}
	
	// ELS
	
	func testGIVEN_NoStoredPPACToken_WHEN_getAPITokenPPAC_THEN_DeviceTokenIsReturned() {
		
		// GIVEN
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
		store.deviceTimeCheckResult = .incorrect
		let successExpectation = expectation(description: "getPPACToken succeeds")

		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		var expectedResponse: PPACToken?
		
		XCTAssertNil(store.apiTokenPPAC)
		
		// WHEN
		ppacService.getAPITokenPPAC { result in
			switch result {
			case let .success(token):
				expectedResponse = token
				successExpectation.fulfill()
			case .failure:
				XCTFail("Failure not expected.")
			}
		}

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertNotNil(expectedResponse)
	}
	
	func testGIVEN_StoredPPACToken_WHEN_getAPITokenPPAC_THEN_DeviceTokenIsReturned() {
		
		// GIVEN
		let store = MockTestStore()
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
		store.deviceTimeCheckResult = .incorrect
		let successExpectation = expectation(description: "getPPACToken succeeds")

		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let existingAPITokenPPAC = TimestampedToken(token: "FakeToken", timestamp: Date())
		store.apiTokenPPAC = existingAPITokenPPAC
		
		// WHEN
		ppacService.getAPITokenPPAC { result in
			switch result {
			case .success:
				successExpectation.fulfill()
			case .failure:
				XCTFail("Failure not expected.")
			}
		}

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(store.apiTokenPPAC?.token, existingAPITokenPPAC.token)
	}
}
