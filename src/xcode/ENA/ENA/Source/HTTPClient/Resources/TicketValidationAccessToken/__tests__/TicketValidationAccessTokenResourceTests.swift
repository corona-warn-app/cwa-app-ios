//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class TicketValidationAccessTokenResourceTests: CWATestCase {

	func testSuccess() throws {
		let expectation = expectation(description: "Expect that we got a completion")

		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["x-nonce": "Nonce"],
			responseData: "accessJWT".data(using: .utf8)
		)

		let serviceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let ticketValidationAccessTokenResource = TicketValidationAccessTokenResource(
			accessTokenServiceURL: URL(staticString: "http://www.coronawarn.app"),
			jwt: "headerJWT",
			sendModel: TicketValidationAccessTokenSendModel(service: "", pubKey: ""),
			trustEvaluation: .fake()
		)

		serviceProvider.load(ticketValidationAccessTokenResource) { result in
			switch result {
			case .success(let result):
				XCTAssertEqual(result.token, "accessJWT")
				XCTAssertEqual(result.metaData.headers["x-nonce"] as? String, "Nonce")
			case .failure(let error):
				XCTFail("Encountered Error when receiving access token! \(error)")
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
		let ticketValidationAccessTokenResource = TicketValidationAccessTokenResource(
			accessTokenServiceURL: URL(staticString: "http://www.coronawarn.app"),
			jwt: "headerJWT",
			sendModel: TicketValidationAccessTokenSendModel(service: "", pubKey: ""),
			trustEvaluation: .fake()
		)

		serviceProvider.load(ticketValidationAccessTokenResource) { result in
			switch result {
			case .success:
				XCTFail("Expected Error when receiving access token!")
			case .failure(let error):
				guard case let .receivedResourceError(customError) = error,
					  .ATR_PARSE_ERR == customError else {
						  XCTFail("unexpected error case")
					return
				}
			}

			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func testCustomError400() throws {
		let ticketValidationAccessTokenResource = TicketValidationAccessTokenResource(
			accessTokenServiceURL: URL(staticString: "http://www.coronawarn.app"),
			jwt: "headerJWT",
			sendModel: TicketValidationAccessTokenSendModel(service: "", pubKey: ""),
			trustEvaluation: .fake()
		)

		let customError = try XCTUnwrap(
			ticketValidationAccessTokenResource.customError(for: .unexpectedServerError(400))
		)

		XCTAssertEqual(customError, .ATR_CLIENT_ERR)
	}

	func testCustomError500() throws {
		let ticketValidationAccessTokenResource = TicketValidationAccessTokenResource(
			accessTokenServiceURL: URL(staticString: "http://www.coronawarn.app"),
			jwt: "headerJWT",
			sendModel: TicketValidationAccessTokenSendModel(service: "", pubKey: ""),
			trustEvaluation: .fake()
		)

		let customError = try XCTUnwrap(
			ticketValidationAccessTokenResource.customError(for: .unexpectedServerError(500))
		)

		XCTAssertEqual(customError, .ATR_SERVER_ERR)
	}

	func testCustomTransportationError() throws {
		let ticketValidationAccessTokenResource = TicketValidationAccessTokenResource(
			accessTokenServiceURL: URL(staticString: "http://www.coronawarn.app"),
			jwt: "headerJWT",
			sendModel: TicketValidationAccessTokenSendModel(service: "", pubKey: ""),
			trustEvaluation: .fake()
		)

		let customError = try XCTUnwrap(
			ticketValidationAccessTokenResource.customError(
				for: .transportationError(
					NSError(
						domain: NSURLErrorDomain,
						code: NSURLErrorNotConnectedToInternet,
						userInfo: nil
					)
				)
			)
		)

		XCTAssertEqual(customError, .ATR_NO_NETWORK)
	}

	func testCustomCertificatePinningMismatchError() throws {
		let ticketValidationAccessTokenResource = TicketValidationAccessTokenResource(
			accessTokenServiceURL: URL(staticString: "http://www.coronawarn.app"),
			jwt: "headerJWT",
			sendModel: TicketValidationAccessTokenSendModel(service: "", pubKey: ""),
			trustEvaluation: .fake()
		)

		let customError = try XCTUnwrap(
			ticketValidationAccessTokenResource.customError(for: .trustEvaluationError(.jsonWebKey(.CERT_PIN_MISMATCH)))
		)

		XCTAssertEqual(customError, .ATR_CERT_PIN_MISMATCH)
	}

	func testCustomCertificatePinningNoJWKForKIDError() throws {
		let ticketValidationAccessTokenResource = TicketValidationAccessTokenResource(
			accessTokenServiceURL: URL(staticString: "http://www.coronawarn.app"),
			jwt: "headerJWT",
			sendModel: TicketValidationAccessTokenSendModel(service: "", pubKey: ""),
			trustEvaluation: .fake()
		)

		let customError = try XCTUnwrap(
			ticketValidationAccessTokenResource.customError(for: .trustEvaluationError(.jsonWebKey(.CERT_PIN_NO_JWK_FOR_KID)))
		)

		XCTAssertEqual(customError, .ATR_CERT_PIN_NO_JWK_FOR_KID)
	}

}
