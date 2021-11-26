//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
import SwiftJWT
@testable import ENA

final class TicketValidationAccessTokenProcessorTests: XCTestCase {

	func testSuccess() throws {
		let accessToken = try accessToken(aud: "aud", t: 1)
		let completionExpectation = expectation(description: "completion called")

		TicketValidationAccessTokenProcessor(
			jwtVerification: MockJWTVerification(result: .success(()))
		)
			.process(
				jwtWithHeadersModel: JWTWithHeadersModel(
					jwt: accessToken.string,
					headers: ["x-nonce": "Nonce"]
				),
				accessTokenSignJwkSet: [],
				completion: { result in
					switch result {
					case .success(let accessTokenResult):
						XCTAssertEqual(accessTokenResult.accessToken, accessToken.string)
						XCTAssertEqual(accessTokenResult.accessTokenPayload, accessToken.payload)
						XCTAssertEqual(accessTokenResult.nonceBase64, "Nonce")
					case .failure(let error):
						XCTFail("Expected success, got \(error)")
					}

					completionExpectation.fulfill()
				}
			)

		waitForExpectations(timeout: .short)
	}

	func testMissingNonceError() throws {
		let accessToken = try accessToken(aud: "aud", t: 1)
		let completionExpectation = expectation(description: "completion called")

		TicketValidationAccessTokenProcessor(
			jwtVerification: MockJWTVerification(result: .success(()))
		)
			.process(
				jwtWithHeadersModel: JWTWithHeadersModel(
					jwt: accessToken.string,
					headers: [:]
				),
				accessTokenSignJwkSet: [],
				completion: { result in
					switch result {
					case .success:
						XCTFail("Expected error")
					case .failure(let error):
						XCTAssertEqual(error, .UNKNOWN)
					}

					completionExpectation.fulfill()
				}
			)

		waitForExpectations(timeout: .short)
	}

	func testParseError() throws {
		let completionExpectation = expectation(description: "completion called")

		TicketValidationAccessTokenProcessor(
			jwtVerification: MockJWTVerification(result: .success(()))
		)
			.process(
				jwtWithHeadersModel: JWTWithHeadersModel(
					jwt: "notAJWT",
					headers: ["x-nonce": "Nonce"]
				),
				accessTokenSignJwkSet: [],
				completion: { result in
					switch result {
					case .success:
						XCTFail("Expected error")
					case .failure(let error):
						XCTAssertEqual(error, .ATR_PARSE_ERR)
					}

					completionExpectation.fulfill()
				}
			)

		waitForExpectations(timeout: .short)
	}

	func testInvalidTypeError() throws {
		let accessToken = try accessToken(aud: "aud", t: 0)
		let completionExpectation = expectation(description: "completion called")

		TicketValidationAccessTokenProcessor(
			jwtVerification: MockJWTVerification(result: .success(()))
		)
			.process(
				jwtWithHeadersModel: JWTWithHeadersModel(
					jwt: accessToken.string,
					headers: ["x-nonce": "Nonce"]
				),
				accessTokenSignJwkSet: [],
				completion: { result in
					switch result {
					case .success:
						XCTFail("Expected error")
					case .failure(let error):
						XCTAssertEqual(error, .ATR_TYPE_INVALID)
					}

					completionExpectation.fulfill()
				}
			)

		waitForExpectations(timeout: .short)
	}

	func testInvalidAUDError() throws {
		let accessToken = try accessToken(aud: "", t: 2)
		let completionExpectation = expectation(description: "completion called")

		TicketValidationAccessTokenProcessor(
			jwtVerification: MockJWTVerification(result: .success(()))
		)
			.process(
				jwtWithHeadersModel: JWTWithHeadersModel(
					jwt: accessToken.string,
					headers: ["x-nonce": "Nonce"]
				),
				accessTokenSignJwkSet: [],
				completion: { result in
					switch result {
					case .success:
						XCTFail("Expected error")
					case .failure(let error):
						XCTAssertEqual(error, .ATR_AUD_INVALID)
					}

					completionExpectation.fulfill()
				}
			)

		waitForExpectations(timeout: .short)
	}

	func testMappedJWT_VER_ALG_NOT_SUPPORTEDError() throws {
		let accessToken = try accessToken(aud: "", t: 0)
		let completionExpectation = expectation(description: "completion called")

		TicketValidationAccessTokenProcessor(
			jwtVerification: MockJWTVerification(result: .failure(.JWT_VER_ALG_NOT_SUPPORTED))
		)
			.process(
				jwtWithHeadersModel: JWTWithHeadersModel(
					jwt: accessToken.string,
					headers: ["x-nonce": "Nonce"]
				),
				accessTokenSignJwkSet: [],
				completion: { result in
					switch result {
					case .success:
						XCTFail("Expected error")
					case .failure(let error):
						XCTAssertEqual(error, .ATR_JWT_VER_ALG_NOT_SUPPORTED)
					}

					completionExpectation.fulfill()
				}
			)

		waitForExpectations(timeout: .short)
	}

	func testMappedJWT_VER_EMPTY_JWKSError() throws {
		let accessToken = try accessToken(aud: "", t: 0)
		let completionExpectation = expectation(description: "completion called")

		TicketValidationAccessTokenProcessor(
			jwtVerification: MockJWTVerification(result: .failure(.JWT_VER_EMPTY_JWKS))
		)
			.process(
				jwtWithHeadersModel: JWTWithHeadersModel(
					jwt: accessToken.string,
					headers: ["x-nonce": "Nonce"]
				),
				accessTokenSignJwkSet: [],
				completion: { result in
					switch result {
					case .success:
						XCTFail("Expected error")
					case .failure(let error):
						XCTAssertEqual(error, .ATR_JWT_VER_EMPTY_JWKS)
					}

					completionExpectation.fulfill()
				}
			)

		waitForExpectations(timeout: .short)
	}

	func testMappedJWT_VER_NO_JWK_FOR_KIDError() throws {
		let accessToken = try accessToken(aud: "", t: 0)
		let completionExpectation = expectation(description: "completion called")

		TicketValidationAccessTokenProcessor(
			jwtVerification: MockJWTVerification(result: .failure(.JWT_VER_NO_JWK_FOR_KID))
		)
			.process(
				jwtWithHeadersModel: JWTWithHeadersModel(
					jwt: accessToken.string,
					headers: ["x-nonce": "Nonce"]
				),
				accessTokenSignJwkSet: [],
				completion: { result in
					switch result {
					case .success:
						XCTFail("Expected error")
					case .failure(let error):
						XCTAssertEqual(error, .ATR_JWT_VER_NO_JWK_FOR_KID)
					}

					completionExpectation.fulfill()
				}
			)

		waitForExpectations(timeout: .short)
	}

	func testMappedJWT_VER_NO_KIDError() throws {
		let accessToken = try accessToken(aud: "", t: 0)
		let completionExpectation = expectation(description: "completion called")

		TicketValidationAccessTokenProcessor(
			jwtVerification: MockJWTVerification(result: .failure(.JWT_VER_NO_KID))
		)
			.process(
				jwtWithHeadersModel: JWTWithHeadersModel(
					jwt: accessToken.string,
					headers: ["x-nonce": "Nonce"]
				),
				accessTokenSignJwkSet: [],
				completion: { result in
					switch result {
					case .success:
						XCTFail("Expected error")
					case .failure(let error):
						XCTAssertEqual(error, .ATR_JWT_VER_NO_KID)
					}

					completionExpectation.fulfill()
				}
			)

		waitForExpectations(timeout: .short)
	}

	func testMappedJWT_VER_SIG_INVALIDError() throws {
		let accessToken = try accessToken(aud: "", t: 0)
		let completionExpectation = expectation(description: "completion called")

		TicketValidationAccessTokenProcessor(
			jwtVerification: MockJWTVerification(result: .failure(.JWT_VER_SIG_INVALID))
		)
			.process(
				jwtWithHeadersModel: JWTWithHeadersModel(
					jwt: accessToken.string,
					headers: ["x-nonce": "Nonce"]
				),
				accessTokenSignJwkSet: [],
				completion: { result in
					switch result {
					case .success:
						XCTFail("Expected error")
					case .failure(let error):
						XCTAssertEqual(error, .ATR_JWT_VER_SIG_INVALID)
					}

					completionExpectation.fulfill()
				}
			)

		waitForExpectations(timeout: .short)
	}

	// MARK: - Private

	private func accessToken(aud: String, t: Int) throws -> (string: String, payload: TicketValidationAccessToken) {
		let accessTokenHeader = Header()

		let accessTokenPayload = TicketValidationAccessToken(
			iss: "",
			iat: nil,
			exp: nil,
			sub: "",
			aud: aud,
			jti: "",
			v: "",
			t: t,
			vc: .fake()
		)
		let accessTokenPayloadString = try accessTokenPayload.encode()

		let jsonEncoder = JSONEncoder()
		jsonEncoder.dateEncodingStrategy = .secondsSince1970
		let data = try jsonEncoder.encode(accessTokenHeader)
		let accessTokenHeaderString = JWTEncoder.base64urlEncodedString(data: data)

		return (
			string: "\(accessTokenHeaderString).\(accessTokenPayloadString)",
			payload: accessTokenPayload
		)
	}

}
