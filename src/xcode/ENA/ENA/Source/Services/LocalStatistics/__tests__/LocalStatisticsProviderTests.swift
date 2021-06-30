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
		client.fetchLocalStatistics(federalStateID: "1", eTag: "fake") { result in
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
		provider.latestLocalStatistics(federalStateID: "1", eTag: "fake")
			.sink(receiveCompletion: { result in
				switch result {
				case .finished:
					break
				case .failure(let error):
					XCTFail(error.localizedDescription)
				}
			}, receiveValue: { localStatistics in
				XCTAssertNotNil(localStatistics)
				valueReceived.fulfill()
			})
			.store(in: &subscriptions)
		
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
		provider.latestLocalStatistics(federalStateID: "1", eTag: "fake")
			.sink(receiveCompletion: { result in
				switch result {
				case .finished:
					break
				case .failure(let error):
					XCTAssertEqual(error.localizedDescription, expectedError.errorDescription)
				}
			}, receiveValue: { _ in
				XCTFail("Did not expect a value")
			})
			.store(in: &subscriptions)
	}
	
	func testLocalStatisticsProvidingHTTP304() throws {
		let valueNotChangedExpectation = expectation(description: "Value not changed")
		valueNotChangedExpectation.expectedFulfillmentCount = 2
		
		let store = MockTestStore()
		store.localStatistics.append(LocalStatisticsMetadata(
			federalStateID: "1",
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
		provider.latestLocalStatistics(federalStateID: "1", eTag: "fake")
			.sink(receiveCompletion: { result in
				switch result {
				case .finished:
					break
				case .failure(let error):
					XCTFail("Did not expect an error, got: \(error)")
				}
			}, receiveValue: { value in
				XCTAssertNotNil(value)
				valueNotChangedExpectation.fulfill()
			})
			.store(in: &subscriptions)
		
		waitForExpectations(timeout: .medium)
	}
}
