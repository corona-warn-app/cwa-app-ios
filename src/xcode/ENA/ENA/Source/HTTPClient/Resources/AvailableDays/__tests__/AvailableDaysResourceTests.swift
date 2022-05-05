//
// 🦠 Corona-Warn-App
//

import XCTest

@testable import ENA

class AvailableDaysResourceTests: CWATestCase {

	// MARK: - Locator

	func testGIVEN_Locator_WHEN_getPath_THEN_isCorrect() {
		// GIVEN
		let locator = Locator.availableDays(country: "IT")

		// WHEN
		let paths = locator.paths

		// THEN
		XCTAssertEqual(
			[
				"version",
				"v1",
				"diagnosis-keys",
				"country",
				"IT",
				"date"
			], paths)
	}

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnownidentifier() {
		// GIVEN
		let knownUniqueIdentifier = "ec4d142271653f1cae9bfa8012bc9b2ce1f5e4502ae3d266cdc58702909eb241"
		let locator = Locator.availableDays(country: "IT")

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

	// MARK: - Logic

	func testAvailableDays_Success() {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data("[\"2020-05-01\", \"2020-05-02\"]".utf8)
		)

		let expectation = self.expectation(
			description: "expect successful result"
		)

		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = AvailableDaysResource(country: "IT")

		restServiceProvider.load(resource) { result in
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
		waitForExpectations(timeout: .medium)
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
		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = AvailableDaysResource(country: "IT")

		restServiceProvider.load(resource) { result in
			switch result {
			case .success:
				XCTFail("an invalid response should never yield success")
			case .failure:
				expectation.fulfill()
			}
		}
		waitForExpectations(timeout: .medium)
	}
	
	func testFetchDay_Success() throws {
		let url = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "api-response-day-2020-05-16", withExtension: nil))
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\""],
			responseData: try Data(contentsOf: url)
		)

		let successExpectation = expectation(
			description: "expect error result"
		)

		let httpClient = HTTPClient.makeWith(mock: stack)
		httpClient.fetchDay("2020-05-01", forCountry: "IT") { result in
			defer { successExpectation.fulfill() }
			switch result {
			case let .success(sapPackage):
				self.assertPackageFormat(for: sapPackage)
			case let .failure(error):
				XCTFail("a valid response should never yield and error like: \(error)")
			}
		}
		waitForExpectations(timeout: .medium)
	}

	func testFetchDay_InvalidPackage() throws {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data(bytes: [0xA, 0xB] as [UInt8], count: 2)
		)

		let successExpectation = expectation(
			description: "expect error result"
		)

		let httpClient = HTTPClient.makeWith(mock: stack)
		httpClient.fetchDay("2020-05-01", forCountry: "IT") { result in
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
		waitForExpectations(timeout: .medium)
	}


}
