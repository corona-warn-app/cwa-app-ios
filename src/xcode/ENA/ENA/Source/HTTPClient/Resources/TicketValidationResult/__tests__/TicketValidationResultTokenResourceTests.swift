//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class TicketValidationResultTokenResourceTests: CWATestCase {

	func testSuccess() throws {
		let expectation = expectation(description: "Expect that we got a completion")

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: "resultJWT".data(using: .utf8)
		)

		let serviceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let ticketValidationResultTokenResource = TicketValidationResultTokenResource(
			resultTokenServiceURL: URL(staticString: "http://www.coronawarn.app"),
			jwt: "headerJWT",
			sendModel: TicketValidationResultTokenSendModel(kid: "", dcc: "", sig: "", encKey: "", encScheme: "", sigAlg: "")
		)

		serviceProvider.load(ticketValidationResultTokenResource) { result in
			switch result {
			case .success(let result):
				XCTAssertEqual(result.token, "resultJWT")
			case .failure(let error):
				XCTFail("Encountered Error when receiving result token! \(error)")
			}
			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testParseError() throws {
		let expectation = expectation(description: "Expect that we got a completion")

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: "🦠".data(using: .ascii)
		)

		let serviceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let ticketValidationResultTokenResource = TicketValidationResultTokenResource(
			resultTokenServiceURL: URL(staticString: "http://www.coronawarn.app"),
			jwt: "headerJWT",
			sendModel: TicketValidationResultTokenSendModel(kid: "", dcc: "", sig: "", encKey: "", encScheme: "", sigAlg: "")
		)

		serviceProvider.load(ticketValidationResultTokenResource) { result in
			switch result {
			case .success:
				XCTFail("Expected Error when receiving result token!")
			case .failure(let error):
				guard case let .receivedResourceError(customError) = error,
					  .RTR_PARSE_ERR == customError else {
						  XCTFail("unexpected error case")
					return
				}
			}

			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testCustomError400() throws {
		let ticketValidationResultTokenResource = TicketValidationResultTokenResource(
			resultTokenServiceURL: URL(staticString: "http://www.coronawarn.app"),
			jwt: "headerJWT",
			sendModel: TicketValidationResultTokenSendModel(kid: "", dcc: "", sig: "", encKey: "", encScheme: "", sigAlg: "")
		)

		let customError = try XCTUnwrap(
			ticketValidationResultTokenResource.customError(for: .unexpectedServerError(400))
		)

		XCTAssertEqual(customError, .RTR_CLIENT_ERR)
	}

	func testCustomError500() throws {
		let ticketValidationResultTokenResource = TicketValidationResultTokenResource(
			resultTokenServiceURL: URL(staticString: "http://www.coronawarn.app"),
			jwt: "headerJWT",
			sendModel: TicketValidationResultTokenSendModel(kid: "", dcc: "", sig: "", encKey: "", encScheme: "", sigAlg: "")
		)

		let customError = try XCTUnwrap(
			ticketValidationResultTokenResource.customError(for: .unexpectedServerError(500))
		)

		XCTAssertEqual(customError, .RTR_SERVER_ERR)
	}

	func testCustomTransportationError() throws {
		let ticketValidationResultTokenResource = TicketValidationResultTokenResource(
			resultTokenServiceURL: URL(staticString: "http://www.coronawarn.app"),
			jwt: "headerJWT",
			sendModel: TicketValidationResultTokenSendModel(kid: "", dcc: "", sig: "", encKey: "", encScheme: "", sigAlg: "")
		)

		let customError = try XCTUnwrap(
			ticketValidationResultTokenResource.customError(
				for: .transportationError(
					NSError(
						domain: NSURLErrorDomain,
						code: NSURLErrorNotConnectedToInternet,
						userInfo: nil
					)
				)
			)
		)

		XCTAssertEqual(customError, .RTR_NO_NETWORK)
	}

	func testCustomCertificatePinningMismatchError() throws {
		let ticketValidationResultTokenResource = TicketValidationResultTokenResource(
			resultTokenServiceURL: URL(staticString: "http://www.coronawarn.app"),
			jwt: "headerJWT",
			sendModel: TicketValidationResultTokenSendModel(kid: "", dcc: "", sig: "", encKey: "", encScheme: "", sigAlg: "")
		)

		let customError = try XCTUnwrap(
			ticketValidationResultTokenResource.customError(for: .trustEvaluationError(.CERT_PIN_MISMATCH))
		)

		XCTAssertEqual(customError, .RTR_CERT_PIN_MISMATCH)
	}
	
	func testCustomCertificatePinningHostMismatchError() throws {
		let ticketValidationResultTokenResource = TicketValidationResultTokenResource(
			resultTokenServiceURL: URL(staticString: "http://www.coronawarn.app"),
			jwt: "headerJWT",
			sendModel: TicketValidationResultTokenSendModel(kid: "", dcc: "", sig: "", encKey: "", encScheme: "", sigAlg: "")
		)

		let customError = try XCTUnwrap(
			ticketValidationResultTokenResource.customError(for: .trustEvaluationError(.CERT_PIN_HOST_MISMATCH))
		)

		XCTAssertEqual(customError, .RTR_CERT_PIN_HOST_MISMATCH)
	}

}
