//
// 🦠 Corona-Warn-App
//

import XCTest

@testable import ENA

class FetchHourTests: CWATestCase {

	// MARK: Locator tests

	func testGIVEN_Locator_WHEN_getPath_THEN_isCorrect() {
		// GIVEN
		let locator = Locator.diagnosisKeysHour(day: "2020-04-20", country: "IT", hour: 14)

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
				"2020-04-20",
				"hour",
				"14"
			], paths)
	}

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnownidentifier() {
		// GIVEN
		let knownUniqueIdentifier = "1caf294d94275f9237d6b7993799983cc3fd18a0b289ded632a50136a4334a70"
		let locator = Locator.diagnosisKeysHour(day: "2020-04-22", country: "IT", hour: 14)

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

	func testGIVEN_Resource_WHEN_DisableHourlyDownloadIsTrue_THEN_NoRequestIsSent() throws {
		let stack = MockNetworkStack( httpStatus: 200, responseData: nil)
		let expectation = expectation(description: "ignore request")

		// WHEN
		let resource = FetchHourResource(day: "2020-05-01", country: "IT", hour: 1, signatureVerifier: MockVerifier())
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		restService.disable(FetchHourResource.identifier)

		// THEN
		restService.load(resource) { result in
			defer { expectation.fulfill() }
			switch result {
			case .success:
				XCTFail("request succeeded unexpected")
			case let .failure(error):
				guard error == .invalidResponse else {
					XCTFail("wrong error given, invalidResponse expected")
					return
				}
			}
		}
		waitForExpectations(timeout: .medium)
	}

}
