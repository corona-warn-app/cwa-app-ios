////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import OpenCombineFoundation
import OpenCombineDispatch

class StatisticsProvider: StatisticsProviding {
	/// Most likely a HTTP client
	private let client: StatisticsFetching

	/// The place where the app config and last etag is stored
	private let store: StatisticsCaching

	private var subscriptions = [AnyCancellable]()

	/// Default initializer
	/// - Parameters:
	///   - client: The client to fetch the stats
	///   - store: Used for caching
	init(client: StatisticsFetching, store: Store) {
		self.client = client
		self.store = store
	}

	func statistics() -> AnyPublisher<SAP_Internal_Stats_Statistics, Error> {
		guard let cached = store.statistics, !shouldFetch() else {
			return fetchStatistics()
				.debounce(for: .milliseconds(1000), scheduler: DispatchQueue.OCombine(.main))
				.eraseToAnyPublisher()
		}
		// return cached data; no error
		return Just(cached.statistics)
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}

	private func fetchStatistics(with etag: String? = nil) -> Future<SAP_Internal_Stats_Statistics, Error> {
		return Future { promise in
			self.client.fetchStatistics(etag: etag) { result in
				switch result {
				case .success(let response):
					// cache
					self.store.statistics = StatisticsMetadata(with: response)
					promise(.success(response.stats))
				case .failure(let error):
					switch error {
					case URLSessionError.notModified:
						if let stats = self.store.statistics {
							// like app config, we update `lastStatisticsFetch`
							self.store.statistics?.refeshLastFetchDate()
							// return cached stats
							promise(.success(stats.statistics))
						} else {
							// in the unlikely case that we dont have any stats but an ETag, we don't retry and simply return the error
							promise(.failure(error))
						}
					default: // pass all other errors
						promise(.failure(error))
					}
				}
			}
		}
	}

	/// Simple helper to simulate Cache-Control
	/// - Note: This 300 second value is because of current handicaps with the HTTPClient architecture
	///   which does not easily return response headers. This requires further refactoring of `URLSession+Convenience.swift`.
	/// - Returns: `true` is a network call should be done; `false` if cache should be used
	private func shouldFetch() -> Bool {
		if store.statistics == nil { return true }

		// naïve cache control
		guard let lastFetch = store.statistics?.lastStatisticsFetch else {
			return true
		}
		Log.debug("timestamp >= 300s? \(abs(Date().timeIntervalSince(lastFetch))) >= 300)", log: .appConfig)
		return abs(Date().timeIntervalSince(lastFetch)) >= 300
	}
}
