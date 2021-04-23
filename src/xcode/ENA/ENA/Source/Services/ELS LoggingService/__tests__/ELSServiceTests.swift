////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ELSServiceTests: XCTestCase {
	
	func testGIVEN_ELSService_WHEN_UploadIsTriggered_THEN_HappyCaseAllSucceeds() throws {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		
		let testExpectation = expectation(description: "Test should success expectation")
		
		#if targetEnvironment(simulator)
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
		#else
		let deviceCheck = PPACDeviceCheck()
		#endif
		let ppacService = PPACService(
			store: store,
			deviceCheck: deviceCheck
		)
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(
			store: store,
			client: client,
			riskProvider: riskProvider
		)
		
		let elsService = ErrorLogSubmissionService(
			client: client,
			store: store,
			ppacService: ppacService,
			otpService: otpService
		)
		
		var expectedResponse: LogUploadResponse?
		
		// WHEN
		elsService.submit(completion: { result in
			switch result {
			case let .success(response):
				expectedResponse = response
				testExpectation.fulfill()
			case let .failure(error):
				XCTFail("Test should not fail with error: \(error)")
			}
		})
		
		waitForExpectations(timeout: .medium)
		
		// THEN
		guard let response = expectedResponse else {
			XCTFail("expectedResponse should not be nil")
			return
		}
		XCTAssertNotNil(response.id)
		XCTAssertNotNil(response.hash)
	}
	
	func testGIVEN_ELSService_WHEN_UploadIsTriggered_THEN_PPACErrorIsReturned() throws {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		
		let testExpectation = expectation(description: "Test should fail expectation")

		let deviceCheck = PPACDeviceCheckMock(false, deviceToken: "iPhone")
		
		let ppacService = PPACService(
			store: store,
			deviceCheck: deviceCheck
		)
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(
			store: store,
			client: client,
			riskProvider: riskProvider
		)
		
		let elsService = ErrorLogSubmissionService(
			client: client,
			store: store,
			ppacService: ppacService,
			otpService: otpService
		)
		var expectedError: ELSError?

		// WHEN
		elsService.submit(completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not success")
			case let .failure(error):
				expectedError = error
				testExpectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: .medium)
		
		// THEN
		guard let error = expectedError else {
			XCTFail("expectedError should not be nil")
			return
		}
		XCTAssertEqual(ELSError.ppacError(.generationFailed), error)
	}
	
	func testGIVEN_ELSService_WHEN_UploadIsTriggered_THEN_OTPErrorIsReturned() throws {
		
		let store = MockTestStore()
		let client = ClientMock()
		client.onGetOTPEls = { _, _, completion in
			completion(.failure(OTPError.otherServerError))
		}
		
		let testExpectation = expectation(description: "Test should fail expectation")

		#if targetEnvironment(simulator)
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
		#else
		let deviceCheck = PPACDeviceCheck()
		#endif
		
		let ppacService = PPACService(
			store: store,
			deviceCheck: deviceCheck
		)
		let riskProvider = MockRiskProvider()
		let otpService = OTPService(
			store: store,
			client: client,
			riskProvider: riskProvider
		)
		
		let elsService = ErrorLogSubmissionService(
			client: client,
			store: store,
			ppacService: ppacService,
			otpService: otpService
		)
		var expectedError: ELSError?

		// WHEN
		elsService.submit(completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not success")
			case let .failure(error):
				expectedError = error
				testExpectation.fulfill()
			}
		})
		
		waitForExpectations(timeout: .medium)
		
		// THEN
		guard let error = expectedError else {
			XCTFail("expectedError should not be nil")
			return
		}
		XCTAssertEqual(ELSError.otpError(.otherServerError), error)
	}
	
	func testGIVEN_ELSService_WHEN_UploadIsTriggered_THEN_CouldNotReadLogfileIsReturned() throws {
//		XCTAssertEqual(ELSError.couldNotReadLogfile(""), error)
	}
	
	func testGIVEN_ELSService_WHEN_UploadIsTriggered_THEN_EmptyLogFileIsReturned() throws {
//		XCTAssertEqual(ELSError.emptyLogFile, error)
	}
}
