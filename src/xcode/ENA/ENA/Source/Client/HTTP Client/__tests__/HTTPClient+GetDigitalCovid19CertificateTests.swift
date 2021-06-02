////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientGetDigitalCovid19CertificateTests: CWATestCase {
	
	func testGIVEN_RegistrationToken_WHEN_HappyCase_THEN_DCCResponseIsReturned() throws {
		// GIVEN
		let registrationToken = "someToken"
		
		let expectedResponse = DCCResponse(
			dek: "someKey",
			dcc: "someCOSE"
		)
		let jsonEncoder = JSONEncoder()
		let encoded = try jsonEncoder.encode(expectedResponse)
		
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: encoded
		)
		
		let expectation = self.expectation(description: "test should succeed with DCCResponse")
		var mockResponse: DCCResponse?
		
		// WHEN
		HTTPClient.makeWith(mock: stack).getDigitalCovid19Certificate(
			registrationToken: registrationToken,
			isFake: false,
			completion: { result in
					switch result {
					case let .success(response):
						mockResponse = response
					case let .failure(error):
						XCTFail("Test should not fail. Error: \(error.localizedDescription)")
					}
					expectation.fulfill()
			})
		
		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(expectedResponse, mockResponse ?? DCCResponse(dek: "FAIL", dcc: "FAIL"))
	}
	
	func testGIVEN_RegistrationToken_WHEN_SuccessWithEmptyData_THEN_JsonErrorIsReturned() {
		// GIVEN
		let registrationToken = "someToken"
		
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data()
		)
		let expectedFailure = DGCError.DigitalCovid19CertificateError.jsonError
		let expectation = self.expectation(description: "test should succeed with DCCResponse")
		var mockFailure: DGCError.DigitalCovid19CertificateError?
		
		// WHEN
		HTTPClient.makeWith(mock: stack).getDigitalCovid19Certificate(
			registrationToken: registrationToken,
			isFake: false,
			completion: { result in
					switch result {
					case .success:
						XCTFail("Test should not succeed.")
					case let .failure(error):
						mockFailure = error
					}
					expectation.fulfill()
			})
		
		// THEN
		waitForExpectations(timeout: .short)
		guard let failure = mockFailure else {
			XCTFail("MockFailure shall not be nil.")
			return
		}
		XCTAssertEqual(expectedFailure, failure)
	}
		
	func testGIVEN_RegistrationToken_WHEN_Failure_THEN_DccPendingIsReturned() {
		// GIVEN
		let registrationToken = "someToken"
		
		let stack = MockNetworkStack(
			httpStatus: 202,
			responseData: Data()
		)
		let expectedFailure = DGCError.DigitalCovid19CertificateError.dccPending
		let expectation = self.expectation(description: "test should succeed with DCCResponse")
		var mockFailure: DGCError.DigitalCovid19CertificateError?
		
		// WHEN
		HTTPClient.makeWith(mock: stack).getDigitalCovid19Certificate(
			registrationToken: registrationToken,
			isFake: false,
			completion: { result in
					switch result {
					case .success:
						XCTFail("Test should not succeed.")
					case let .failure(error):
						mockFailure = error
					}
					expectation.fulfill()
			})
		
		// THEN
		waitForExpectations(timeout: .short)
		guard let failure = mockFailure else {
			XCTFail("MockFailure shall not be nil.")
			return
		}
		XCTAssertEqual(expectedFailure, failure)
	}
	
	func testGIVEN_RegistrationToken_WHEN_Failure_THEN_BadRequestIsReturned() {
		// GIVEN
		let registrationToken = "someToken"
		
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: Data()
		)
		let expectedFailure = DGCError.DigitalCovid19CertificateError.badRequest
		let expectation = self.expectation(description: "test should succeed with DCCResponse")
		var mockFailure: DGCError.DigitalCovid19CertificateError?
		
		// WHEN
		HTTPClient.makeWith(mock: stack).getDigitalCovid19Certificate(
			registrationToken: registrationToken,
			isFake: false,
			completion: { result in
					switch result {
					case .success:
						XCTFail("Test should not succeed.")
					case let .failure(error):
						mockFailure = error
					}
					expectation.fulfill()
			})
		
		// THEN
		waitForExpectations(timeout: .short)
		guard let failure = mockFailure else {
			XCTFail("MockFailure shall not be nil.")
			return
		}
		XCTAssertEqual(expectedFailure, failure)
	}
	
	func testGIVEN_RegistrationToken_WHEN_Failure_THEN_TokenDoesNotExistIsReturned() {
		// GIVEN
		let registrationToken = "someToken"
		
		let stack = MockNetworkStack(
			httpStatus: 404,
			responseData: Data()
		)
		let expectedFailure = DGCError.DigitalCovid19CertificateError.tokenDoesNotExist
		let expectation = self.expectation(description: "test should succeed with DCCResponse")
		var mockFailure: DGCError.DigitalCovid19CertificateError?
		
		// WHEN
		HTTPClient.makeWith(mock: stack).getDigitalCovid19Certificate(
			registrationToken: registrationToken,
			isFake: false,
			completion: { result in
					switch result {
					case .success:
						XCTFail("Test should not succeed.")
					case let .failure(error):
						mockFailure = error
					}
					expectation.fulfill()
			})
		
		// THEN
		waitForExpectations(timeout: .short)
		guard let failure = mockFailure else {
			XCTFail("MockFailure shall not be nil.")
			return
		}
		XCTAssertEqual(expectedFailure, failure)
	}
	
	func testGIVEN_RegistrationToken_WHEN_Failure_THEN_DccAlreadyCleanedUpIsReturned() {
		// GIVEN
		let registrationToken = "someToken"
		
		let stack = MockNetworkStack(
			httpStatus: 410,
			responseData: Data()
		)
		let expectedFailure = DGCError.DigitalCovid19CertificateError.dccAlreadyCleanedUp
		let expectation = self.expectation(description: "test should succeed with DCCResponse")
		var mockFailure: DGCError.DigitalCovid19CertificateError?
		
		// WHEN
		HTTPClient.makeWith(mock: stack).getDigitalCovid19Certificate(
			registrationToken: registrationToken,
			isFake: false,
			completion: { result in
					switch result {
					case .success:
						XCTFail("Test should not succeed.")
					case let .failure(error):
						mockFailure = error
					}
					expectation.fulfill()
			})
		
		// THEN
		waitForExpectations(timeout: .short)
		guard let failure = mockFailure else {
			XCTFail("MockFailure shall not be nil.")
			return
		}
		XCTAssertEqual(expectedFailure, failure)
	}
	
	func testGIVEN_RegistrationToken_WHEN_Failure_THEN_TestResultNotYetReceivedIsReturned() {
		// GIVEN
		let registrationToken = "someToken"
		
		let stack = MockNetworkStack(
			httpStatus: 412,
			responseData: Data()
		)
		let expectedFailure = DGCError.DigitalCovid19CertificateError.testResultNotYetReceived
		let expectation = self.expectation(description: "test should succeed with DCCResponse")
		var mockFailure: DGCError.DigitalCovid19CertificateError?
		
		// WHEN
		HTTPClient.makeWith(mock: stack).getDigitalCovid19Certificate(
			registrationToken: registrationToken,
			isFake: false,
			completion: { result in
					switch result {
					case .success:
						XCTFail("Test should not succeed.")
					case let .failure(error):
						mockFailure = error
					}
					expectation.fulfill()
			})
		
		// THEN
		waitForExpectations(timeout: .short)
		guard let failure = mockFailure else {
			XCTFail("MockFailure shall not be nil.")
			return
		}
		XCTAssertEqual(expectedFailure, failure)
	}
	
	func testGIVEN_RegistrationToken_WHEN_Failure_THEN_InternalServerErrorIsReturned() {
		// GIVEN
		let registrationToken = "someToken"
		
		let stack = MockNetworkStack(
			httpStatus: 500,
			responseData: Data()
		)
		let expectedFailure = DGCError.DigitalCovid19CertificateError.internalServerError
		let expectation = self.expectation(description: "test should succeed with DCCResponse")
		var mockFailure: DGCError.DigitalCovid19CertificateError?
		
		// WHEN
		HTTPClient.makeWith(mock: stack).getDigitalCovid19Certificate(
			registrationToken: registrationToken,
			isFake: false,
			completion: { result in
					switch result {
					case .success:
						XCTFail("Test should not succeed.")
					case let .failure(error):
						mockFailure = error
					}
					expectation.fulfill()
			})
		
		// THEN
		waitForExpectations(timeout: .short)
		guard let failure = mockFailure else {
			XCTFail("MockFailure shall not be nil.")
			return
		}
		XCTAssertEqual(expectedFailure, failure)
	}
	
	func testGIVEN_RegistrationToken_WHEN_Failure_THEN_UnhandledResponseIsReturned() {
		// GIVEN
		let registrationToken = "someToken"
		
		let stack = MockNetworkStack(
			httpStatus: 999,
			responseData: Data()
		)
		let expectedFailure = DGCError.DigitalCovid19CertificateError.unhandledResponse(999)
		let expectation = self.expectation(description: "test should succeed with DCCResponse")
		var mockFailure: DGCError.DigitalCovid19CertificateError?
		
		// WHEN
		HTTPClient.makeWith(mock: stack).getDigitalCovid19Certificate(
			registrationToken: registrationToken,
			isFake: false,
			completion: { result in
					switch result {
					case .success:
						XCTFail("Test should not succeed.")
					case let .failure(error):
						mockFailure = error
					}
					expectation.fulfill()
			})
		
		// THEN
		waitForExpectations(timeout: .short)
		guard let failure = mockFailure else {
			XCTFail("MockFailure shall not be nil.")
			return
		}
		XCTAssertEqual(expectedFailure, failure)
	}
	
	func testGIVEN_RegistrationToken_WHEN_Failure_THEN_defaultServerErrorIsReturned() {
		// GIVEN
		let registrationToken = "someToken"
		
		let stack = MockNetworkStack(
			httpStatus: 999,
			responseData: nil
		)
		let expectedFailure = DGCError.DigitalCovid19CertificateError.defaultServerError(URLSession.Response.Failure.noResponse)
		let expectation = self.expectation(description: "test should succeed with DCCResponse")
		var mockFailure: DGCError.DigitalCovid19CertificateError?
		
		// WHEN
		HTTPClient.makeWith(mock: stack).getDigitalCovid19Certificate(
			registrationToken: registrationToken,
			isFake: false,
			completion: { result in
					switch result {
					case .success:
						XCTFail("Test should not succeed.")
					case let .failure(error):
						mockFailure = error
					}
					expectation.fulfill()
			})
		
		// THEN
		waitForExpectations(timeout: .short)
		guard let failure = mockFailure else {
			XCTFail("MockFailure shall not be nil.")
			return
		}
		XCTAssertEqual(expectedFailure, failure)
	}
}
