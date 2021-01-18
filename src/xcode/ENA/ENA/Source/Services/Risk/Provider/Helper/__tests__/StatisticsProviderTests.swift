////
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
@testable import ENA

class StatisticsProviderTests: XCTestCase {

	private var subscriptions = [AnyCancellable]()

	/// Tests the static mock data and general fetching mechanism
	func testFetchStaticStats() {
		let fetchedFromClientExpectation = expectation(description: "stats fetched from client")
		fetchedFromClientExpectation.expectedFulfillmentCount = 1

		let store = MockTestStore()
		XCTAssertNil(store.appConfigMetadata)

		let client = CachingHTTPClientMock(store: store)
		client.fetchStatistics(etag: "foo") { result in
			switch result {
			case .success(let response): // StatisticsFetchingResponse
				XCTAssertEqual(response.stats.keyFigureCards.count, 4)
				XCTAssertEqual(response.stats.cardIDSequence.count, response.stats.keyFigureCards.count)
			case .failure(let error):
				XCTFail(error.localizedDescription)
			}
			fetchedFromClientExpectation.fulfill()
		}

		waitForExpectations(timeout: .medium)
	}

	func testStatisticsProviding() throws {
		let valueReceived = expectation(description: "Value received")
		valueReceived.expectedFulfillmentCount = 1

		let store = MockTestStore()
		let client = CachingHTTPClientMock(store: store)
		let provider = StatisticsProvider(client: client, store: store)
		provider.statistics()
			.sink(receiveCompletion: { result in
				switch result {
				case .finished:
					break
				case .failure(let error):
					XCTFail(error.localizedDescription)
				}
			}, receiveValue: { stats in
				XCTAssertEqual(stats.keyFigureCards.count, 4)
				XCTAssertEqual(stats.cardIDSequence.count, stats.keyFigureCards.count)
				valueReceived.fulfill()
			})
			.store(in: &subscriptions)

		waitForExpectations(timeout: .medium)
	}

	func testStatisticsProvidingHTTPErrors() throws {
		let responseReceived = expectation(description: "responseReceived")
		responseReceived.expectedFulfillmentCount = 1

		let store = MockTestStore()
		let client = CachingHTTPClientMock(store: store)
		client.onFetchStatistics = { _, completeWith in
			// fake a broken backend
			let error = URLSessionError.serverError(503)
			completeWith(.failure(error))
		}

		let provider = StatisticsProvider(client: client, store: store)
		provider.statistics()
			.sink(receiveCompletion: { result in
				switch result {
				case .finished:
					XCTFail("Did not expect a success")
				case .failure(let error):
					switch error {
					case URLSessionError.serverError(let code):
						XCTAssertEqual(code, 503)
						responseReceived.fulfill()
					default:
						XCTFail("Expected a different error")
					}
				}
			}, receiveValue: { _ in
				XCTFail("Did not expect a value")
			})
			.store(in: &subscriptions)

		waitForExpectations(timeout: .medium)
	}

	func testStatisticsProvidingHttp304() throws {
		let checkpoint = expectation(description: "Value received")
		checkpoint.expectedFulfillmentCount = 2

		// provide an already 'cached' data set
		let store = MockTestStore()
		store.statistics = StatisticsMetadata(
			stats: CachingHTTPClientMock.staticStatistics,
			eTag: "fake",
			timestamp: try XCTUnwrap(301.secondsAgo))

		// Fake, backend returns HTTP 304
		let client = CachingHTTPClientMock(store: store)
		client.onFetchStatistics = { _, completeWith in
			let error = URLSessionError.notModified
			completeWith(.failure(error))
			checkpoint.fulfill()
		}

		// Request statistics...
		let provider = StatisticsProvider(client: client, store: store)
		provider.statistics()
			.sink(receiveCompletion: { result in
				switch result {
				case .finished:
					break
				case .failure(let error):
					XCTFail("Expected a no error, got: \(error)")
				}
			}, receiveValue: { stats in
				XCTAssertEqual(stats.keyFigureCards.count, 4)
				XCTAssertEqual(stats.cardIDSequence.count, stats.keyFigureCards.count)
				checkpoint.fulfill()
			})
			.store(in: &subscriptions)

		waitForExpectations(timeout: .medium)
	}

	func testStatisticsProvidingCacheDecay() throws {
		let checkpoint = expectation(description: "Value received")
		checkpoint.expectedFulfillmentCount = 2

		// provide an already 'cached' data set that's older than the max cache time for stats (300s)
		let store = MockTestStore()
		store.statistics = StatisticsMetadata(
			stats: CachingHTTPClientMock.staticStatistics,
			eTag: "fake",
			timestamp: try XCTUnwrap(301.secondsAgo))

		// Fake, backend returns new data
		let client = CachingHTTPClientMock(store: store)
		client.onFetchStatistics = { _, completeWith in
			let response = StatisticsFetchingResponse(CachingHTTPClientMock.staticStatistics, "fake2")
			completeWith(.success(response))
			checkpoint.fulfill()
		}

		// Request statistics...
		let provider = StatisticsProvider(client: client, store: store)
		provider.statistics()
			.sink(receiveCompletion: { result in
				switch result {
				case .finished:
					break
				case .failure(let error):
					XCTFail("Expected a no error, got: \(error)")
				}
			}, receiveValue: { stats in
				XCTAssertEqual(stats.keyFigureCards.count, 4)
				XCTAssertEqual(stats.cardIDSequence.count, stats.keyFigureCards.count)
				XCTAssertEqual(store.statistics?.lastStatisticsETag, "fake2")
				checkpoint.fulfill()
			})
			.store(in: &subscriptions)

		waitForExpectations(timeout: .medium)
	}

	func testStatisticsProvidingInvalidCacheState() throws {
		let checkpoint = expectation(description: "Value received")
		checkpoint.expectedFulfillmentCount = 2

		// Empty store
		let store = MockTestStore()

		// Simulate response for given ETag
		let client = CachingHTTPClientMock(store: store)
		client.onFetchStatistics = { _, completeWith in
			let error = URLSessionError.notModified
			completeWith(.failure(error))
			checkpoint.fulfill()
		}

		// Request statistics...
		let provider = StatisticsProvider(client: client, store: store)
		provider.statistics()
			.sink(receiveCompletion: { result in
				switch result {
				case .finished:
					XCTFail("Expected an error!")
				case .failure(let error):
					switch error {
					case URLSessionError.notModified:
						checkpoint.fulfill()
					default:
						XCTFail("Expected a different error")
					}
				}
			}, receiveValue: { _ in
				XCTFail("not expected")
			})
			.store(in: &subscriptions)

		waitForExpectations(timeout: .medium)
	}
}
