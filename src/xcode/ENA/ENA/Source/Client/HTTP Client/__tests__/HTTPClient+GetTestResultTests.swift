//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientTestResultTests: XCTestCase {
	private let expectationsTimeout: TimeInterval = 2

	func testGetTestResult_Success() throws {
		let testResult = 1234
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try JSONEncoder().encode(GetTestResultResponse(testResult: testResult))
		)

		let successExpectation = expectation(
			description: "Expect that we got a completion"
		)

		HTTPClient.makeWith(mock: stack).getTestResult(forDevice: "1234567890") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success(let responseCode):
				XCTAssertEqual(testResult, responseCode)
			case .failure:
				XCTFail("Encountered Error when receiving test result!")
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetTestResult_ServerError() throws {
		let testResult = 1234
		let stack = MockNetworkStack(
			httpStatus: 302,
			responseData: try JSONEncoder().encode(GetTestResultResponse(testResult: testResult))
		)

		let successExpectation = expectation(
			description: "Expect that we got a completion"
		)

		HTTPClient.makeWith(mock: stack).getTestResult(forDevice: "1234567890") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("The request should not have succeeded!")
			case .failure(let error):
				switch error {
				case .serverError:
					break
				default:
					XCTFail("The received error was not .serverError!")
				}
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetTestResult_MalformedResponse() throws {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data(bytes: [0xA, 0xB] as [UInt8], count: 2)
		)

		let successExpectation = expectation(
			description: "Expect that we got a completion"
		)

		HTTPClient.makeWith(mock: stack).getTestResult(forDevice: "1234567890") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("The request should not have succeeded!")
			case .failure(let error):
				switch error {
				case .invalidResponse:
					break
				default:
					XCTFail("The received error was not .invalidResponse!")
				}
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetTestResult_MalformedJSONResponse() throws {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: """
			{ "notAValidKey":"1234" }
			""".data(using: .utf8)
		)

		let successExpectation = expectation(
			description: "Expect that we got a completion"
		)

		HTTPClient.makeWith(mock: stack).getTestResult(forDevice: "1234567890") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("The request should not have succeeded!")
			case .failure(let error):
				switch error {
				case .invalidResponse:
					break
				default:
					XCTFail("The received error was not .invalidResponse!")
				}
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}
}
