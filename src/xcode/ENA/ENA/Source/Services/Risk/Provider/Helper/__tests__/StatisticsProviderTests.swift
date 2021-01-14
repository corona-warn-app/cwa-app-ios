////
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
@testable import ENA

class StatisticsProviderTests: XCTestCase {

	private var subscriptions = [AnyCancellable]()

	func testFetchStaticStats() {

		let fetchedFromClientExpectation = expectation(description: "stats fetched from client")
		// we trigger a config fetch twice but expect only one http request (plus one cached result)
		fetchedFromClientExpectation.expectedFulfillmentCount = 1

		let store = MockTestStore()
		XCTAssertNil(store.appConfigMetadata)

		let client = CachingHTTPClientMock(store: store)
		client.fetchStatistics(etag: "foo") { result in
			switch result {
			case .success(let response): // StatisticsFetchingResponse
				break
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
			fetchedFromClientExpectation.fulfill()
		}

		waitForExpectations(timeout: .medium)
	}

	func testFetchStats() {

		let fetchedFromClientExpectation = expectation(description: "stats fetched from client")
		// we trigger a config fetch twice but expect only one http request (plus one cached result)
		fetchedFromClientExpectation.expectedFulfillmentCount = 1

		let store = MockTestStore()
		XCTAssertNil(store.appConfigMetadata)
		let client = CachingHTTPClient(clientConfiguration: HTTPClient.Configuration.makeDefaultConfiguration(store: store))
		client.fetchStatistics(etag: "foo") { result in
			switch result {
			case .success(let response):
				XCTAssertEqual(response.stats.keyFigureCards.count, 4)
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
			fetchedFromClientExpectation.fulfill()
		}

		waitForExpectations(timeout: .medium)
	}
}
