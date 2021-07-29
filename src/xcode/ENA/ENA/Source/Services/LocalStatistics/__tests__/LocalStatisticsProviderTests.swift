//
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
@testable import ENA

class LocalStatisticsProviderTests: CWATestCase {

	private var subscriptions = [AnyCancellable]()
	
	func testFetchLocalStatitics() {
		let fetchedFromClientExpectation = expectation(description: "Local statistics fetched from client")
		fetchedFromClientExpectation.expectedFulfillmentCount = 1

		let store = MockTestStore()
		XCTAssertEqual(store.localStatistics, [])

		let client = CachingHTTPClientMock()
		client.fetchLocalStatistics(groupID: "1", eTag: "fake") { result in
			switch result {
			case .success(let response):
				XCTAssertNotNil(response.eTag)
				XCTAssertNotNil(response.timestamp)
				XCTAssertNotNil(response.localStatistics)
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
			fetchedFromClientExpectation.fulfill()
		}

		waitForExpectations(timeout: .medium)
	}
	
	func testLocalStatiticsProviding() throws {
		let valueReceived = expectation(description: "Local statistics received")
		valueReceived.expectedFulfillmentCount = 1
		
		let store = MockTestStore()
		let client = CachingHTTPClientMock()
		let provider = LocalStatisticsProvider(client: client, store: store)
		provider.latestLocalStatistics(groupID: "1", eTag: "fake", completion: { result in
			switch result {
			case .success(let localStatistics):
				XCTAssertNotNil(localStatistics)
				valueReceived.fulfill()
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
		})
		
		waitForExpectations(timeout: .short)
	}
	
	func testLocalStatisticsProvidingHTTPErrors() throws {
		let store = MockTestStore()
		let client = CachingHTTPClientMock()
		let expectedError = URLSessionError.serverError(503)
		client.onFetchLocalStatistics = { _, completeWith in
			// fake a broken backend
			completeWith(.failure(expectedError))
		}
		
		let provider = LocalStatisticsProvider(client: client, store: store)
		provider.latestLocalStatistics(groupID: "1", eTag: "fake", completion: { result in
			switch result {
			case .success:
				XCTFail("Did not expect a value")
			case .failure(let error):
				XCTAssertEqual(error.localizedDescription, expectedError.errorDescription)
			}
		})
	}
	
	func testLocalStatisticsProvidingHTTP304() throws {
		let valueNotChangedExpectation = expectation(description: "Value not changed")
		valueNotChangedExpectation.expectedFulfillmentCount = 2
		
		let store = MockTestStore()
		store.localStatistics.append(LocalStatisticsMetadata(
			groupID: "1",
			lastLocalStatisticsETag: "fake",
			lastLocalStatisticsFetchDate: try XCTUnwrap(301.secondsAgo),
			localStatistics: CachingHTTPClientMock.staticLocalStatistics
		))
		// Fake, backend returns HTTP 304
		let client = CachingHTTPClientMock()
		client.onFetchLocalStatistics = { _, completeWith in
			let error = URLSessionError.notModified
			completeWith(.failure(error))
			valueNotChangedExpectation.fulfill()
		}
		
		let provider = LocalStatisticsProvider(client: client, store: store)
		provider.latestLocalStatistics(groupID: "1", eTag: "fake", completion: { result in
			switch result {
			case .success(let value):
				XCTAssertNotNil(value)
				valueNotChangedExpectation.fulfill()
			case .failure(let error):
				XCTFail("Did not expect an error, got: \(error)")
			}
			
		})
		
		waitForExpectations(timeout: .medium)
	}
}
