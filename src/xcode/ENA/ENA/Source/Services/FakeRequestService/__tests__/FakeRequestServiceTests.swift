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

		// Initialize.

		let client = ClientMock()

		client.onGetTANForExposureSubmit = { _, isFake, completion in
			expectation.fulfill()
			XCTAssertTrue(isFake)
			count += 1
			completion(.failure(.fakeResponse))
		}

		client.onSubmitCountries = { _, isFake, completion in
			expectation.fulfill()
			XCTAssertTrue(isFake)
			XCTAssertEqual(count, 2)
			count += 1
			completion(.success(()))
		}

		let fakeRequestService = FakeRequestService(client: client)

		// Run test.

		fakeRequestService.fakeRequest()

		waitForExpectations(timeout: .short)
	}

	func testFakeVerificationServerRequest() {
		let expectation = self.expectation(description: "onGetTANForExposureSubmit called")

		// Initialize.

		let client = ClientMock()

		client.onGetTANForExposureSubmit = { _, isFake, _ in
			XCTAssertTrue(isFake)
			expectation.fulfill()
		}

		let fakeRequestService = FakeRequestService(client: client)

		// Run test.

		fakeRequestService.fakeVerificationServerRequest()

		waitForExpectations(timeout: .short)
	}

	func testFakeSubmissionServerRequest() {
		let expectation = self.expectation(description: "onSubmitCountries called")

		// Initialize.

		let client = ClientMock()

		client.onSubmitCountries = { _, isFake, _ in
			XCTAssertTrue(isFake)
			expectation.fulfill()
		}

		let fakeRequestService = FakeRequestService(client: client)

		// Run test.

		fakeRequestService.fakeSubmissionServerRequest()

		waitForExpectations(timeout: .short)
	}

	func testFakeVerificationAndSubmissionServerRequest() {
		// Counter to track the execution order.
		var count = 0

		let expectation = self.expectation(description: "execute all callbacks")
		expectation.expectedFulfillmentCount = 2

		// Initialize.

		let client = ClientMock()

		client.onGetTANForExposureSubmit = { _, isFake, completion in
			expectation.fulfill()
			XCTAssertTrue(isFake)
			count += 1
			completion(.failure(.fakeResponse))
		}

		client.onSubmitCountries = { _, isFake, completion in
			expectation.fulfill()
			XCTAssertTrue(isFake)
			XCTAssertEqual(count, 1)
			count += 1
			completion(.success(()))
		}

		let fakeRequestService = FakeRequestService(client: client)

		// Run test.

		fakeRequestService.fakeVerificationAndSubmissionServerRequest()

		waitForExpectations(timeout: .short)
	}

}
