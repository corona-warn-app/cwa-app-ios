//
// 🦠 Corona-Warn-App
//

import XCTest

@testable import ENA

class FetchDayTests: CWATestCase {

	// MARK: Locator tests

	func testGIVEN_Locator_WHEN_getPath_THEN_isCorrect() {
		// GIVEN
		let locator = Locator.diagnosisKeys(day: "2020-04-20", country: "IT")

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
				"date",
				"2020-04-20"
			], paths)
	}

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnownidentifier() {
		// GIVEN
		let knownUniqueIdentifier = "ca88626aeba6b7be1fff6b501d78608e4734e1f9703a0de6311137e1c535db9d"
		let locator = Locator.diagnosisKeys(day: "2020-04-22", country: "IT")

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

	// MARK: - Logic
	
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
