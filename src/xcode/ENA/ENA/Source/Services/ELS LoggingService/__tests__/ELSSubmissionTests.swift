////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ELSSubmissionTests: XCTestCase {
	
	func testGIVEN_ELSService_WHEN_UploadIsTriggered_THEN_HappyCaseAllSucceeds() throws {
		// GIVEN
		let store = MockTestStore()
		let dummyTestFile = Data(bytes: [0xA, 0xB] as [UInt8], count: 2)

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
		
		elsService.submit(log: dummyTestFile, completion: { result in
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
}
