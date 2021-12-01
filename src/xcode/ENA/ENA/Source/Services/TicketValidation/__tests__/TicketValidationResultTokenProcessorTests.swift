//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
import SwiftJWT
@testable import ENA

final class TicketValidationResultTokenProcessorTests: XCTestCase {

	func testSuccess() throws {
		let resultToken = try resultToken()
		let completionExpectation = expectation(description: "completion called")

		TicketValidationResultTokenProcessor(
			jwtVerification: MockJWTVerification(result: .success(()))
		)
			.process(
				resultToken: resultToken.string,
				validationServiceSignJwkSet: [],
				completion: { result in
					switch result {
					case .success(let resultTokenResult):
						XCTAssertEqual(resultTokenResult.resultToken, resultToken.string)
						XCTAssertEqual(resultTokenResult.resultTokenPayload, resultToken.payload)
					case .failure(let error):
						XCTFail("Expected success, got \(error)")
					}

					completionExpectation.fulfill()
				}
			)

		waitForExpectations(timeout: .short)
	}

	func testParseError() throws {
		let completionExpectation = expectation(description: "completion called")

		TicketValidationResultTokenProcessor(
			jwtVerification: MockJWTVerification(result: .success(()))
		)
			.process(
				resultToken: "notAJWT",
				validationServiceSignJwkSet: [],
				completion: { result in
					switch result {
					case .success:
						XCTFail("Expected error")
					case .failure(let error):
						XCTAssertEqual(error, .RTR_PARSE_ERR)
					}

					completionExpectation.fulfill()
				}
			)

		waitForExpectations(timeout: .short)
	}

	func testMappedJWT_VER_ALG_NOT_SUPPORTEDError() throws {
		let resultToken = try resultToken()
		let completionExpectation = expectation(description: "completion called")

		TicketValidationResultTokenProcessor(
			jwtVerification: MockJWTVerification(result: .failure(.JWT_VER_ALG_NOT_SUPPORTED))
		)
			.process(
				resultToken: resultToken.string,
				validationServiceSignJwkSet: [],
				completion: { result in
					switch result {
					case .success:
						XCTFail("Expected error")
					case .failure(let error):
						XCTAssertEqual(error, .RTR_JWT_VER_ALG_NOT_SUPPORTED)
					}

					completionExpectation.fulfill()
				}
			)

		waitForExpectations(timeout: .short)
	}

	func testMappedJWT_VER_EMPTY_JWKSError() throws {
		let resultToken = try resultToken()
		let completionExpectation = expectation(description: "completion called")

		TicketValidationResultTokenProcessor(
			jwtVerification: MockJWTVerification(result: .failure(.JWT_VER_EMPTY_JWKS))
		)
			.process(
				resultToken: resultToken.string,
				validationServiceSignJwkSet: [],
				completion: { result in
					switch result {
					case .success:
						XCTFail("Expected error")
					case .failure(let error):
						XCTAssertEqual(error, .RTR_JWT_VER_EMPTY_JWKS)
					}

					completionExpectation.fulfill()
				}
			)

		waitForExpectations(timeout: .short)
	}

	func testMappedJWT_VER_NO_JWK_FOR_KIDError() throws {
		let resultToken = try resultToken()
		let completionExpectation = expectation(description: "completion called")

		TicketValidationResultTokenProcessor(
			jwtVerification: MockJWTVerification(result: .failure(.JWT_VER_NO_JWK_FOR_KID))
		)
			.process(
				resultToken: resultToken.string,
				validationServiceSignJwkSet: [],
				completion: { result in
					switch result {
					case .success:
						XCTFail("Expected error")
					case .failure(let error):
						XCTAssertEqual(error, .RTR_JWT_VER_NO_JWK_FOR_KID)
					}

					completionExpectation.fulfill()
				}
			)

		waitForExpectations(timeout: .short)
	}

	func testMappedJWT_VER_NO_KIDError() throws {
		let resultToken = try resultToken()
		let completionExpectation = expectation(description: "completion called")

		TicketValidationResultTokenProcessor(
			jwtVerification: MockJWTVerification(result: .failure(.JWT_VER_NO_KID))
		)
			.process(
				resultToken: resultToken.string,
				validationServiceSignJwkSet: [],
				completion: { result in
					switch result {
					case .success:
						XCTFail("Expected error")
					case .failure(let error):
						XCTAssertEqual(error, .RTR_JWT_VER_NO_KID)
					}

					completionExpectation.fulfill()
				}
			)

		waitForExpectations(timeout: .short)
	}

	func testMappedJWT_VER_SIG_INVALIDError() throws {
		let resultToken = try resultToken()
		let completionExpectation = expectation(description: "completion called")

		TicketValidationResultTokenProcessor(
			jwtVerification: MockJWTVerification(result: .failure(.JWT_VER_SIG_INVALID))
		)
			.process(
				resultToken: resultToken.string,
				validationServiceSignJwkSet: [],
				completion: { result in
					switch result {
					case .success:
						XCTFail("Expected error")
					case .failure(let error):
						XCTAssertEqual(error, .RTR_JWT_VER_SIG_INVALID)
					}

					completionExpectation.fulfill()
				}
			)

		waitForExpectations(timeout: .short)
	}

	// MARK: - Private

	private func resultToken() throws -> (string: String, payload: TicketValidationResultToken) {
		let resultTokenHeader = Header()

		let resultTokenPayload = TicketValidationResultToken.fake()
		let resultTokenPayloadString = try resultTokenPayload.encode()

		let jsonEncoder = JSONEncoder()
		jsonEncoder.dateEncodingStrategy = .secondsSince1970
		let data = try jsonEncoder.encode(resultTokenHeader)
		let resultTokenHeaderString = JWTEncoder.base64urlEncodedString(data: data)

		return (
			string: "\(resultTokenHeaderString).\(resultTokenPayloadString)",
			payload: resultTokenPayload
		)
	}

}
