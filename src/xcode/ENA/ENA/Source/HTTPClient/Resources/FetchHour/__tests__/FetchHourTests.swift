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
				XCTFail("request succeeded expected")
			case let .failure(error):
				guard error == .invalidResponse else {
					XCTFail("wrong error given, invalidResponse expected")
					return
				}
			}
		}
		waitForExpectations(timeout: .medium)
	}

	// MARK: - Logic Tests

	func testFetchHour_InvalidPayload() throws {
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data("hello world".utf8)
		)

		let expectation = expectation(description: "expect error result")

		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = FetchHourResource(day: "2020-05-01", country: "IT", hour: 1)
		restService.load(resource) { result in
			defer {
				expectation.fulfill()
			}
			switch result {
			case .success:
				XCTFail("an invalid response should never cause success")
			case let .failure(error):
				if case let .resourceError(detailError) = error,
				   case .packageCreation = detailError {
				} else {
					XCTFail("wrong error given, packageCreation expected")
				}
			}
		}
		waitForExpectations(timeout: .medium)
	}

	func testFetchHour_Success() throws {
		let url = try XCTUnwrap(Bundle(for: type(of: self)).url(forResource: "api-response-day-2020-05-16", withExtension: nil))
		let stack = MockNetworkStack(
			httpStatus: 200,
			headerFields: ["etAg": "\"SomeEtag\""],
			responseData: try Data(contentsOf: url)
		)

		let expectation = expectation(description: "expect error result")
		let restService = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = FetchHourResource(day: "2020-05-01", country: "IT", hour: 1, signatureVerifier: MockVerifier())
		restService.load(resource) { result in
			defer {
				expectation.fulfill()
			}
			switch result {
			case let .success(sapPackage):
				self.assertPackageFormat(for: sapPackage)

			case let .failure(error):
				XCTFail("a valid response should never yield and error like: \(error)")
			}
		}
		waitForExpectations(timeout: .medium)
	}


}
