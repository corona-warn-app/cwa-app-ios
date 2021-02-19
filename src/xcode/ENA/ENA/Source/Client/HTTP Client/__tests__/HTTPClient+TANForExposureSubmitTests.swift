//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientTANForExposureSubmitTests: XCTestCase {
	private let expectationsTimeout: TimeInterval = 2

	func testGetTANForExposureSubmit_Success() throws {
		let tan = "0987654321"
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(GetTANResponse(tan: tan))
		)

		let successExpectation = expectation(
			description: "Expect that we get a TAN"
		)

		HTTPClient.makeWith(mock: stack).getTANForExposureSubmit(forDevice: "1234567890") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success(let responseTAN):
				XCTAssertEqual(responseTAN, tan)
			case .failure:
				XCTFail("Encountered Error when receiving TAN")
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetTANForExposureSubmit_TokenDoesNotExist() throws {
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: Data()
		)

		let successExpectation = expectation(
			description: "Expect that we get a completion"
		)

		HTTPClient.makeWith(mock: stack).getTANForExposureSubmit(forDevice: "1234567890") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("Mock backend returned 400 - but we got a TAN instead?!")
			case .failure(let error):
				switch error {
				case .regTokenNotExist:
					break
				default:
					XCTFail("Received error was not .regTokenNotExist")
				}
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetTANForExposureSubmit_UnacceptableResponse() throws {
		let stack = MockNetworkStack(
			httpStatus: 302,
			responseData: Data()
		)

		let successExpectation = expectation(
			description: "Expect that we get a completion"
		)

		HTTPClient.makeWith(mock: stack).getTANForExposureSubmit(forDevice: "1234567890") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("Mock backend returned 302 - but we got a TAN instead?!")
			case .failure(let error):
				switch error {
				case .serverError:
					break
				default:
					XCTFail("Received error was not .serverError")
				}
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetTANForExposureSubmit_MalformedResponse() throws {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data(bytes: [0xA, 0xB] as [UInt8], count: 2)
		)

		let successExpectation = expectation(
			description: "Expect that we get a TAN"
		)

		HTTPClient.makeWith(mock: stack).getTANForExposureSubmit(forDevice: "1234567890") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("Mock backend returned random bytes - but we got a TAN instead?!")
			case .failure(let error):
				switch error {
				case .invalidResponse:
					break
				default:
					XCTFail("Received error was not .invalidResponse")
				}
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetTANForExposureSubmit_MalformedJSONResponse() throws {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: """
			{ "taaaaaaan":"Hello" }
			""".data(using: .utf8)
		)

		let successExpectation = expectation(
			description: "Expect that we get a TAN"
		)

		HTTPClient.makeWith(mock: stack).getTANForExposureSubmit(forDevice: "1234567890") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("Mock backend returned random bytes - but we got a TAN instead?!")
			case .failure(let error):
				switch error {
				case .invalidResponse:
					break
				default:
					XCTFail("Received error was not .invalidResponse")
				}
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetTANForExposureSubmit_VerifyPOSTBodyContent() throws {
		let expectedToken = "SomeToken"
		let sendPostExpectation = expectation(
			description: "Expect that the client sends a POST request"
		)
		let verifyPostBodyContent: MockUrlSession.URLRequestObserver = { request in
			defer { sendPostExpectation.fulfill() }

			guard let content = try? JSONDecoder().decode([String: String].self, from: request.httpBody ?? Data()) else {
				XCTFail("POST body was empty, expected registrationToken JSON!")
				return
			}

			guard content["registrationToken"] == expectedToken else {
				XCTFail("POST JSON body did not have registrationToken value, or it was incorrect!")
				return
			}
		}
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(GetRegistrationTokenResponse(registrationToken: expectedToken)),
			requestObserver: verifyPostBodyContent
		)

		HTTPClient.makeWith(mock: stack).getTANForExposureSubmit(forDevice: expectedToken) { _ in }
		waitForExpectations(timeout: expectationsTimeout)
	}
}
