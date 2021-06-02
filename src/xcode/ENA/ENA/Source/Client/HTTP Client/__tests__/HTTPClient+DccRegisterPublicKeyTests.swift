////
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientDccRegisterPublicKeyTests: CWATestCase {
	
	func testGIVEN_ErrorLog_WHEN_DCCRegisterPublicKey_THEN_HappyCase_VoidIsReturned() throws {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 201,
			responseData: Data()
		)

		let expectation = self.expectation(description: "completion handler is called without an error")

		// WHEN
		var resultSuccess: Bool = false
		HTTPClient.makeWith(mock: stack).dccRegisterPublicKey(token: "myToken", publicKey: Data()) { result in
			switch result {
			case .success():
				resultSuccess = true
			case let .failure(error):
				XCTFail("Test should not fail. Error: \(error.localizedDescription)")
			}
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertTrue(resultSuccess)
	}

	func testGIVEN_ErrorLog_WHEN_DCCRegisterPublicKey_THEN_badRequest_ErrorIsReturned() throws {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: Data()
		)

		let expectation = self.expectation(description: "completion handler is called without an error")

		// WHEN
		var resultError: DCCErrors.RegistrationError?
		HTTPClient.makeWith(mock: stack).dccRegisterPublicKey(token: "myToken", publicKey: Data()) { result in
			switch result {
			case .success():
				XCTFail("Test should not succeed")
			case let .failure(error):
				resultError = error
			}
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .short)
		let realError = try XCTUnwrap(resultError)
		XCTAssertEqual(realError, .badRequest)
	}

	func testGIVEN_ErrorLog_WHEN_DCCRegisterPublicKey_THEN_tokenNotAllowed_ErrorIsReturned() throws {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 403,
			responseData: Data()
		)

		let expectation = self.expectation(description: "completion handler is called without an error")

		// WHEN
		var resultError: DCCErrors.RegistrationError?
		HTTPClient.makeWith(mock: stack).dccRegisterPublicKey(token: "myToken", publicKey: Data()) { result in
			switch result {
			case .success():
				XCTFail("Test should not succeed")
			case let .failure(error):
				resultError = error
			}
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .short)
		let realError = try XCTUnwrap(resultError)
		XCTAssertEqual(realError, .tokenNotAllowed)
	}

	func testGIVEN_ErrorLog_WHEN_DCCRegisterPublicKey_THEN_tokenDoesNotExist_ErrorIsReturned() throws {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 404,
			responseData: Data()
		)

		let expectation = self.expectation(description: "completion handler is called without an error")

		// WHEN
		var resultError: DCCErrors.RegistrationError?
		HTTPClient.makeWith(mock: stack).dccRegisterPublicKey(token: "myToken", publicKey: Data()) { result in
			switch result {
			case .success():
				XCTFail("Test should not succeed")
			case let .failure(error):
				resultError = error
			}
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .short)
		let realError = try XCTUnwrap(resultError)
		XCTAssertEqual(realError, .tokenDoesNotExist)
	}

	func testGIVEN_ErrorLog_WHEN_DCCRegisterPublicKey_THEN_tokenAlreadyAssigned_ErrorIsReturned() throws {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 409,
			responseData: Data()
		)

		let expectation = self.expectation(description: "completion handler is called without an error")

		// WHEN
		var resultError: DCCErrors.RegistrationError?
		HTTPClient.makeWith(mock: stack).dccRegisterPublicKey(token: "myToken", publicKey: Data()) { result in
			switch result {
			case .success():
				XCTFail("Test should not succeed")
			case let .failure(error):
				resultError = error
			}
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .short)
		let realError = try XCTUnwrap(resultError)
		XCTAssertEqual(realError, .tokenAlreadyAssigned)
	}

	func testGIVEN_ErrorLog_WHEN_DCCRegisterPublicKey_THEN_internalServerError_IsReturned() throws {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 500,
			responseData: Data()
		)

		let expectation = self.expectation(description: "completion handler is called without an error")

		// WHEN
		var resultError: DCCErrors.RegistrationError?
		HTTPClient.makeWith(mock: stack).dccRegisterPublicKey(token: "myToken", publicKey: Data()) { result in
			switch result {
			case .success():
				XCTFail("Test should not succeed")
			case let .failure(error):
				resultError = error
			}
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .short)
		let realError = try XCTUnwrap(resultError)
		XCTAssertEqual(realError, .internalServerError)
	}

	func testGIVEN_ErrorLog_WHEN_DCCRegisterPublicKey_THEN_unhandledResponse_IsReturned() throws {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 502,
			responseData: Data()
		)

		let expectation = self.expectation(description: "completion handler is called without an error")

		// WHEN
		var resultError: DCCErrors.RegistrationError?
		HTTPClient.makeWith(mock: stack).dccRegisterPublicKey(token: "myToken", publicKey: Data()) { result in
			switch result {
			case .success():
				XCTFail("Test should not succeed")
			case let .failure(error):
				resultError = error
			}
			expectation.fulfill()
		}

		// THEN
		waitForExpectations(timeout: .short)
		var responseStatusCode: Int = 200
		let realError = try XCTUnwrap(resultError)
		switch realError {
		case let .unhandledResponse(statusCode):
			responseStatusCode = statusCode
		default:
			XCTFail("unexpected error")
		}

		XCTAssertEqual(responseStatusCode, 502)
	}

}
