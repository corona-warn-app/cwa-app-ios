//
// 🦠 Corona-Warn-App
//

@testable import ENA
import ExposureNotification
import XCTest

class FakeRequestServiceTests: CWATestCase {

	/// The fake registration token needs to comply to a format that is checked by the server.
	func testFakeRegistrationTokenFormat() throws {
		let str = FakeRequestService.fakeRegistrationToken
		let pattern = #"^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89aAbB][a-f0-9]{3}-[a-f0-9]{12}$"#
		let regex = try NSRegularExpression(pattern: pattern, options: [])

		XCTAssertNotNil(regex.firstMatch(in: str, options: [], range: .init(location: 0, length: str.count)))
	}

	func testFakeRequest() {
		// Counter to track the execution order.
		var count = 0
		
		let expectation = self.expectation(description: "execute all callbacks")
		expectation.expectedFulfillmentCount = 3

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: MockTestStore(), deviceCheck: deviceCheck)
		
		// Initialize.

		let restServiceProvider = RestServiceProviderStub(
			loadResources: [
				LoadResource(
					result: .success(
						RegistrationTokenReceiveModel(submissionTAN: "fake")
					),
					willLoadResource: { resource in
						guard let resource = resource as? RegistrationTokenResource else {
							XCTFail("RegistrationTokenResource expected.")
							return
						}
						
						expectation.fulfill()
						XCTAssertTrue(resource.locator.isFake)
						count += 1
					}),
				LoadResource(
					result: .success(
						RegistrationTokenReceiveModel(submissionTAN: "fake")
					),
					willLoadResource: { resource in
						guard let resource = resource as? RegistrationTokenResource else {
							XCTFail("RegistrationTokenResource expected.")
							return
						}
						
						expectation.fulfill()
						XCTAssertTrue(resource.locator.isFake)
						count += 1
					}),
				// Key submission result.
				LoadResource(
					result: .success(()),
					willLoadResource: { resource in
						guard let submissionResource = resource as? KeySubmissionResource else {
							XCTFail("KeySubmissionResource expected.")
							return
						}
						expectation.fulfill()
						XCTAssertTrue(submissionResource.locator.isFake)
						XCTAssertEqual(count, 2)
						count += 1
					}
				)
			],
			isFakeResourceLoadingActive: true
		)

		let fakeRequestService = FakeRequestService(restServiceProvider: restServiceProvider, ppacService: ppacService)

		// Run test.

		fakeRequestService.fakeRequest()

		waitForExpectations(timeout: .short)
	}

	func testFakeVerificationServerRequest() {
		let expectation = self.expectation(description: "onGetTANForExposureSubmit called")
		
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: MockTestStore(), deviceCheck: deviceCheck)
		
		// Initialize.

		let restServiceProvider = RestServiceProviderStub(
			loadResources: [
				LoadResource(
					result: .success(
						RegistrationTokenReceiveModel(submissionTAN: "fake")
					),
					willLoadResource: { resource in
						guard let resource = resource as? RegistrationTokenResource  else {
							XCTFail("RegistrationTokenResource expected.")
							return
						}
						
						expectation.fulfill()
						XCTAssertTrue(resource.locator.isFake)
					}),
				LoadResource(
					result: .success(
						RegistrationTokenReceiveModel(submissionTAN: "fake")
					),
					willLoadResource: { resource in
						guard let resource = resource as? RegistrationTokenResource  else {
							XCTFail("RegistrationTokenResource expected.")
							return
						}
						
						expectation.fulfill()
						XCTAssertTrue(resource.locator.isFake)
					})
				
			],
			isFakeResourceLoadingActive: true
		)

		let fakeRequestService = FakeRequestService(restServiceProvider: restServiceProvider, ppacService: ppacService)

		// Run test.

		fakeRequestService.fakeVerificationServerRequest()

		waitForExpectations(timeout: .short)
	}

	func testFakeSubmissionServerRequest() {
		let expectation = self.expectation(description: "Execute fake submission.")

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: MockTestStore(), deviceCheck: deviceCheck)
		
		// Initialize.
		
		let restServiceProvider = RestServiceProviderStub(
			loadResources: [
				// Key submission result.
				LoadResource(
					result: .success(()),
					willLoadResource: { resource in
						guard let submissionResource = resource as? KeySubmissionResource else {
							XCTFail("KeySubmissionResource expected.")
							return
						}
						XCTAssertTrue(submissionResource.locator.isFake)
						expectation.fulfill()
					}
				)
			],
			isFakeResourceLoadingActive: true
		)
	
		let fakeRequestService = FakeRequestService(restServiceProvider: restServiceProvider, ppacService: ppacService)

		// Run test.

		fakeRequestService.fakeSubmissionServerRequest()
		waitForExpectations(timeout: .short)
	}

	func testFakeSRSOTPServerRequest() {
		let expectation = self.expectation(description: "Execute fake SRS OTP request.")

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: MockTestStore(), deviceCheck: deviceCheck)
		
		// Initialize.
		
		let restServiceProvider = RestServiceProviderStub(
			loadResources: [
				LoadResource(
					result: .success(()),
					willLoadResource: { resource in
						guard let otpAuthorizationForSRSResource = resource as? OTPAuthorizationForSRSResource else {
							XCTFail("OTPAuthorizationForSRSResource expected.")
							return
						}
						XCTAssertTrue(otpAuthorizationForSRSResource.locator.isFake)
						expectation.fulfill()
					}
				)
			],
			isFakeResourceLoadingActive: true
		)
	
		let fakeRequestService = FakeRequestService(restServiceProvider: restServiceProvider, ppacService: ppacService)

		// Run test.

		fakeRequestService.fakeSRSOTPServerRequest()
		waitForExpectations(timeout: .short)
	}
	
	func testFakeVerificationAndSubmissionServerRequest() {
		// Counter to track the execution order.
		var count = 0
		
		let expectation = self.expectation(description: "execute all callbacks")
		expectation.expectedFulfillmentCount = 2
		
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: MockTestStore(), deviceCheck: deviceCheck)
		
		// Initialize.
		let restServiceProvider = RestServiceProviderStub(
			loadResources: [
				LoadResource(
					result: .success(
						RegistrationTokenReceiveModel(submissionTAN: "fake")
					),
					willLoadResource: { resource in
						guard let resource = resource as? RegistrationTokenResource  else {
							XCTFail("RegistrationTokenResource expected.")
							return
						}
						
						expectation.fulfill()
						XCTAssertTrue(resource.locator.isFake)
						count += 1
					}),
				// Key submission result.
				LoadResource(
					result: .success(()),
					willLoadResource: { resource in
						guard let submissionResource = resource as? KeySubmissionResource else {
							XCTFail("KeySubmissionResource expected.")
							return
						}
						expectation.fulfill()
						XCTAssertTrue(submissionResource.locator.isFake)
						XCTAssertEqual(count, 1)
						count += 1
					}
				)
				
			],
			isFakeResourceLoadingActive: true
		)

		let fakeRequestService = FakeRequestService(restServiceProvider: restServiceProvider, ppacService: ppacService)

		// Run test.

		fakeRequestService.fakeVerificationAndSubmissionServerRequest()

		waitForExpectations(timeout: .short)
	}

}
