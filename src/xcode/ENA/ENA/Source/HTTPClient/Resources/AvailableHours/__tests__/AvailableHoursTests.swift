//
// 🦠 Corona-Warn-App
//

import XCTest

@testable import ENA

class AvailableHoursTests: CWATestCase {

	// MARK: Locator tests

	func testGIVEN_Locator_WHEN_getPath_THEN_isCorrect() {
		// GIVEN
		let locator = Locator.availableHours(day: "2020-04-20", country: "IT")

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
				"hour"
			], paths)

	}

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnownidentifier() {
		// GIVEN
		let knownUniqueIdentifier = "0c9bac572c347e9b4fa6f1b5c74caac1ec25558d3130e347ff4b5a0d8dae8904"
		let locator = Locator.availableHours(day: "2020-04-20", country: "IT")

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

	// MARK: - RestService tests

	func testGIVEN_AvailableHoursRequest_WHEN_404_THEN_ResultIsEmptyArray() {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 404,
			responseData: Data("".utf8)
		)
		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = AvailableHoursResource(day: "2020-05-12", country: "IT")
		let expectation = self.expectation(
			description: "did finish loading"
		)

		// WHEN
		var receivedModel: [Int]?
		restServiceProvider.load(resource) { result in
			switch result {
			case let .success(model):
				receivedModel = model
				expectation.fulfill()

			case .failure:
				XCTFail("Model did not succeed for 404 it should")
			}
		}

		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(receivedModel, [])
	}

	func testGIVEN_AvailableHoursRequest_WHEN_200_THEN_ResultIsParsed() {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 200,
			responseData: Data("[1, 2, 3, 4, 5]".utf8)
		)
		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = AvailableHoursResource(day: "2020-05-12", country: "IT")
		let expectation = self.expectation(
			description: "did finish loading"
		)

		// WHEN
		var receivedModel: [Int]?
		restServiceProvider.load(resource) { result in
			switch result {
			case let .success(model):
				receivedModel = model
				expectation.fulfill()

			case .failure:
				XCTFail("Model did not succeed for 404 it should")
			}
		}

		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(receivedModel, [1, 2, 3, 4, 5])
	}

	func testGIVEN_AvailableHoursRequest_WHEN_400_THEN_ResultIsAnError() {
		// GIVEN
		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: Data("".utf8)
		)
		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())
		let resource = AvailableHoursResource(day: "2020-05-12", country: "IT")
		let expectation = self.expectation(
			description: "did finish loading"
		)

		// WHEN
		var receivedModel: [Int]?
		restServiceProvider.load(resource) { result in
			switch result {
			case let .success(model):
				receivedModel = model
				XCTFail("Model did succeed but shouldn't")

			case .failure:
				expectation.fulfill()
			}
		}

		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertNil(receivedModel)
	}

}
