//
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
//

@testable import ENA
import Foundation
import XCTest

final class HTTPClientAppConfigTests: XCTestCase {
	private let expectationsTimeout: TimeInterval = 2

	// MARK: - Signature Verification Tests

	func testGetAppConfiguration_SignatureVerificationSuccess() throws {
		// swiftlint:disable:next force_unwrapping
		let url = Bundle(for: type(of: self)).url(forResource: "de-config", withExtension: nil)!
		let packageSignatureExpectation = expectation(
			description: "Expect that the verifier is called!"
		)
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try Data(contentsOf: url),
			packageVerifier: { _ in
				packageSignatureExpectation.fulfill()
				return true
			}
		)
		let successExpectation = expectation(
			description: "Package signature validation passed!"
		)

		HTTPClient.makeWith(mock: stack).appConfiguration { result in
			defer { successExpectation.fulfill() }
			if result == nil {
				XCTFail("Signature validation should have passed!")
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetAppConfiguration_SignatureVerificationFail() throws {
		// swiftlint:disable:next force_unwrapping
		let url = Bundle(for: type(of: self)).url(forResource: "de-config", withExtension: nil)!
		let packageSignatureExpectation = expectation(
			description: "Expect that the verifier is called!"
		)
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try Data(contentsOf: url),
			packageVerifier: { _ in
				packageSignatureExpectation.fulfill()
				return false
			}
		)

		let successExpectation = expectation(
			description: "Expect that package signature validation fails"
		)

		HTTPClient.makeWith(mock: stack).appConfiguration { result in
			defer { successExpectation.fulfill() }
			if result != nil {
				XCTFail("Expected signature validation to fail!")
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetAppConfiguration_SupportedCountries() throws {
		// swiftlint:disable:next force_unwrapping
		let url = Bundle(for: type(of: self)).url(forResource: "de-config", withExtension: nil)!

		let fetchCountriesExpectation = expectation(description: "Fetch country list")

		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: try Data(contentsOf: url)
		)

		HTTPClient.makeWith(mock: stack).supportedCountries { result in
			switch result {
			case .failure(let error):
				XCTFail("Country fetch error: \(error as NSError)")
			case .success(let list):
				#if INTEROP
				// As of 2020-09-16 the latest backend deployment returns zero (0) countries.
				// Due to the current changes in INTEROP we should check this by end of Sept 2020!
				XCTAssertGreaterThanOrEqual(list.count, 0)
				#else
				XCTAssertEqual(list.count, 0)
				#endif
			}
			fetchCountriesExpectation.fulfill()
		}

		waitForExpectations(timeout: expectationsTimeout)
	}

	// MARK: - Invalid Response Tests

	func testGetAppConfiguration_ServerSentInvalidData() {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data(bytes: [0xA, 0xB], count: 2)
		)

		let successExpectation = expectation(
			description: "Expect that Data cannot be deserialized into SAP_ApplicationConfiguration!"
		)

		HTTPClient.makeWith(mock: stack).appConfiguration { result in
			defer { successExpectation.fulfill() }
			if result != nil {
				XCTFail("Request succeeded although data returned by server was invalid?!")
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetAppConfiguration_BadStatus() {
		let stack = MockNetworkStack(
			httpStatus: 500,
			responseData: Data()
		)

		let successExpectation = expectation(
			description: "Expect that request fails"
		)

		HTTPClient.makeWith(mock: stack).appConfiguration { result in
			defer { successExpectation.fulfill() }
			if result != nil {
				XCTFail("Server sent bad response code, but request succeeded?!")
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}

	func testGetAppConfiguration_NoData() {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: nil
		)

		let successExpectation = expectation(
			description: "Expect that request fails"
		)

		HTTPClient.makeWith(mock: stack).appConfiguration { result in
			defer { successExpectation.fulfill() }
			if result != nil {
				XCTFail("Server sent bad response code, but request succeeded?!")
			}
		}
		waitForExpectations(timeout: expectationsTimeout)
	}
}
