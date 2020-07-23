// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

@testable import ENA
import ExposureNotification
import XCTest
import CryptoKit

final class HTTPClientDaysAndHoursTests: XCTestCase {
	let binFileSize = 501
	let sigFileSize = 144
	let expectationsTimeout: TimeInterval = 2
	let mockUrl = URL(staticString: "http://example.com")
	let tan = "1234"

	private var keys: [ENTemporaryExposureKey] {
		let key = ENTemporaryExposureKey()
		key.keyData = Data(bytes: [1, 2, 3], count: 3)
		key.rollingPeriod = 1337
		key.rollingStartNumber = 42
		key.transmissionRiskLevel = 8

		return [key]
	}

	func testAvailableDays_Success() {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data("[\"2020-05-01\", \"2020-05-02\"]".utf8)
		)

		let expectation = self.expectation(
			description: "expect successful result"
		)

		HTTPClient.makeWith(mock: stack).availableDays { result in
			switch result {
			case let .success(days):
				XCTAssertEqual(
					days,
					["2020-05-01", "2020-05-02"]
				)
				expectation.fulfill()
			case let .failure(error):
				XCTFail("a valid response should never yiled an error like \(error)")
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testAvailableDays_StatusCodeNotAccepted() {
		let stack = MockNetworkStack(
			httpStatus: 500,
			responseData: Data(
				"""
				["2020-05-01", "2020-05-02"]
				""".utf8
			)
		)

		let expectation = self.expectation(
			description: "expect error result"
		)

		HTTPClient.makeWith(mock: stack).availableDays { result in
			switch result {
			case .success:
				XCTFail("an invalid response should never yield success")
			case .failure:
				expectation.fulfill()
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	// The hours of a given day can be missing
	func testAvailableHours_NotFound() {
		let stack = MockNetworkStack(
			httpStatus: 404,
			responseData: Data(
				"""
				[1,2,3,4,5]
				""".utf8
			)
		)

		let expectation = self.expectation(
			description: "expect successful result but empty"
		)
		HTTPClient.makeWith(mock: stack).availableHours(day: "2020-05-12") { result in
			switch result {
			case let .success(hours):
				XCTAssertEqual(
					hours,
					[]
				)
				expectation.fulfill()
			case let .failure(error):
				XCTFail("a valid response should never yiled an error like \(error)")
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testAvailableHours_Success() {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data(
				"""
				[1,2,3,4,5]
				""".utf8
			)
		)

		let expectation = self.expectation(
			description: "expect successful result"
		)

		HTTPClient.makeWith(mock: stack).availableHours(day: "2020-05-12") { result in
			switch result {
			case let .success(hours):
				XCTAssertEqual(
					hours,
					[1, 2, 3, 4, 5]
				)
				expectation.fulfill()
			case let .failure(error):
				XCTFail("a valid response should never yiled an error like \(error)")
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testFetchHour_InvalidPayload() throws {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data("hello world".utf8)
		)

		let failureExpectation = expectation(
			description: "expect error result"
		)

		HTTPClient.makeWith(mock: stack).fetchHour(1, day: "2020-05-01") { result in
			switch result {
			case .success:
				XCTFail("an invalid response should never cause success")
			case .failure:
				failureExpectation.fulfill()
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testFetchHour_Success() throws {
		// swiftlint:disable:next force_unwrapping
		let url = Bundle(for: type(of: self)).url(forResource: "api-response-day-2020-05-16", withExtension: nil)!
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try Data(contentsOf: url)
		)

		let successExpectation = expectation(
			description: "expect error result"
		)

		HTTPClient.makeWith(mock: stack).fetchHour(1, day: "2020-05-01") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case let .success(sapPackage):
				self.assertPackageFormat(for: sapPackage)
			case let .failure(error):
				XCTFail("a valid response should never yield and error like: \(error)")
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testFetchDay_Success() throws {
		// swiftlint:disable:next force_unwrapping
		let url = Bundle(for: type(of: self)).url(forResource: "api-response-day-2020-05-16", withExtension: nil)!
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try Data(contentsOf: url)
		)

		let successExpectation = expectation(
			description: "expect error result"
		)

		HTTPClient.makeWith(mock: stack).fetchDay("2020-05-01") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case let .success(sapPackage):
				self.assertPackageFormat(for: sapPackage)
			case let .failure(error):
				XCTFail("a valid response should never yield and error like: \(error)")
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testFetchDay_InvalidPackage() throws {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data(bytes: [0xA, 0xB], count: 2)
		)

		let successExpectation = expectation(
			description: "expect error result"
		)

		HTTPClient.makeWith(mock: stack).fetchDay("2020-05-01") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case .success:
				XCTFail("An invalid server response should not result in success!")
			case let .failure(error):
				switch error {
				case .invalidResponse:
					break
				default:
					XCTFail("Incorrect error type \(error) received, expected .invalidResponse")
				}
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	private func assertPackageFormat(for downloadedPackage: SAPDownloadedPackage) {
		XCTAssertEqual(downloadedPackage.bin.count, binFileSize)
		XCTAssertEqual(downloadedPackage.signature.count, sigFileSize)
	}
}
