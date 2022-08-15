////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ELSServiceTests: CWATestCase {
	
	func testGIVEN_ELSService_WHEN_UploadIsTriggered_THEN_HappyCaseAllSucceeds() throws {
		// GIVEN
		let restServiceProvider = RestServiceProviderStub(
			loadResources: [
				LoadResource(
					result: .success(SubmitELSReceiveModel(id: "", hash: "")),
					willLoadResource: nil
				)
			],
			cacheResources: [],
			isFakeResourceLoadingActive: false
		)

		let elsService = createELSService(restService: restServiceProvider)
		// need at least no empty log file
		elsService.startLogging()
		let testExpectation = expectation(description: "Test should success expectation")
		var expectedResponse: SubmitELSReceiveModel?
		
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
		let elsService = createELSService(ppacSucceeds: false)
		// need at least no empty log file
		elsService.startLogging()
		let testExpectation = expectation(description: "Test should fail expectation")
		var expectedError: ELSError?

		// WHEN
		elsService.submit(completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not succeed")
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
	// TO DO Related to OPT refactoring part
//	func testGIVEN_ELSService_WHEN_UploadIsTriggered_THEN_OTPErrorIsReturned() throws {
//		// GIVEN
//		let restServiceProvider = RestServiceProviderStub(
//			loadResources: [
//				LoadResource(
//					result: .failure(.restServiceError(ServiceError<SubmitELSResource.CustomError>.transportationError(ELSError.otpError(.otherServerError)))),
//					willLoadResource: nil
//				)
//			],
//			cacheResources: [],
//			isFakeResourceLoadingActive: false
//		)
//
//		let elsService = createELSService(restService: restServiceProvider)
//		// need at least no empty log file
//		elsService.startLogging()
//		let testExpectation = expectation(description: "Test should fail expectation")
//		
//		var expectedError: ELSError?
//
//		// WHEN
//		elsService.submit(completion: { result in
//			switch result {
//			case .success:
//				XCTFail("Test should not succeed")
//			case let .failure(error):
//				expectedError = error
//				testExpectation.fulfill()
//			}
//		})
//		
//		waitForExpectations(timeout: .medium)
//		
//		// THEN
//		guard let error = expectedError else {
//			XCTFail("expectedError should not be nil")
//			return
//		}
//		XCTAssertEqual(ELSError.otpError(.otherServerError), error)
//	}
	
//	func testGIVEN_ELSService_WHEN_UploadIsTriggered_THEN_ServerErrorIsReturned() throws {
//		// GIVEN
//		let restServiceProvider = RestServiceProviderStub(
//			loadResources: [
//				LoadResource(
//					result: .failure(.serviceError(.transportationError(.network))),
//					willLoadResource: nil
//				)
//			],
//			cacheResources: [],
//			isFakeResourceLoadingActive: false
//		)
//		let elsService = createELSService(restService: restServiceProvider)
//		// need at least no empty log file
//		elsService.startLogging()
//		let testExpectation = expectation(description: "Test should fail expectation")
//
//		var expectedError: ELSError?
//
//		// WHEN
//		elsService.submit(completion: { result in
//			switch result {
//			case .success:
//				XCTFail("Test should not succeed")
//			case let .failure(error):
//				expectedError = error
//				testExpectation.fulfill()
//			}
//		})
//
//		waitForExpectations(timeout: .medium)
//
//		// THEN
//		guard let error = expectedError else {
//			XCTFail("expectedError should not be nil")
//			return
//		}
//		XCTAssertEqual(serverFailure, error)
//	}
	
//	func testGIVEN_ELSService_WHEN_UploadIsTriggered_THEN_EmptyLogFileIsReturned() throws {
//		let elsService = createELSService()
//		// need at least no empty log file
//		elsService.startLogging()
//		// we don't care about the result, just ensuring 'clean' logs
//		try? elsService.stopAndDeleteLog()
//
//		XCTAssertNil(elsService.fetchExistingLog())
//
//		elsService.submit { result in
//			switch result {
//			case .success:
//				XCTFail("Test should not succeed")
//			case .failure(let error):
//				XCTAssertEqual(ELSError.emptyLogFile, error)
//			}
//		}
//	}
	
	func testLogFetching() throws {
		let elsService = createELSService()

		// we don't care about the result, just ensuring 'clean' logs
		try? elsService.stopAndDeleteLog()
		// No log? No LogItem!
		XCTAssertNil(elsService.fetchExistingLog())

		elsService.startLogging()
		Log.debug("Test", log: .default)
		XCTAssertNotNil(elsService.fetchExistingLog())
	}

	// MARK: - Helpers

	// This thing currently doesn't handle all customizations
	private func createELSService(
		store: Store & PPAnalyticsData = MockTestStore(),
		restService: RestServiceProviding = RestServiceProviderStub(),
		ppacSucceeds: Bool = true
	) -> ErrorLogSubmissionService {

		#if targetEnvironment(simulator)
		let deviceCheck = PPACDeviceCheckMock(ppacSucceeds, deviceToken: "iPhone")
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
			client: ClientMock(), // might fail
			riskProvider: riskProvider
		)
		let elsService = ErrorLogSubmissionService(
			restServicerProvider: restService,
			store: store,
			ppacService: ppacService,
			otpService: otpService
		)
		return elsService
	}
}
