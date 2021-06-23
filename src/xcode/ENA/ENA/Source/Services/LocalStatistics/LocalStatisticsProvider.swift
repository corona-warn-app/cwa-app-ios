//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

class LocalStatisticsProvider: LocalStatisticsProviding {

	// MARK: - Init

	init(client: LocalStatisticsFetching, store: Store) {
		self.client = client
		self.store = store
	}

	// MARK: - Internal

	func latestLocalStatistics(administrativeUnit: String, eTag: String? = nil) -> AnyPublisher<SAP_Internal_Stats_LocalStatistics, Error> {
		let etag = store.localStatistics?.lastLocalStatisticsETag

		guard let cached = store.localStatistics, !shouldFetch() else {
			return fetchLocalStatistics(administrativeUnit: administrativeUnit, eTag: etag).eraseToAnyPublisher()
		}
		// return cached data; no error
		return Just(cached.localStatistics)
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}

	// MARK: - Private

	private let client: LocalStatisticsFetching
	private let store: LocalStatisticsCaching

	private func fetchLocalStatistics(administrativeUnit: String, eTag: String? = nil) -> Future<SAP_Internal_Stats_LocalStatistics, Error> {
		return Future { promise in
			self.client.fetchLocalStatistics(administrativeUnit: administrativeUnit, eTag: eTag) { result in
				switch result {
				case .success(let response):
					// cache
					self.store.localStatistics = LocalStatisticsMetadata(with: response)
					promise(.success(response.localStatistics))
				case .failure(let error):
					Log.error(error.localizedDescription, log: .vaccination)
					switch error {
					case URLSessionError.notModified:
						self.store.localStatistics?.refreshLastLocalStatisticsFetchDate()
					default:
						break
					}
					// return cached if it exists
					if let cachedLocalStatistics = self.store.localStatistics {
						promise(.success(cachedLocalStatistics.localStatistics))
					} else {
						promise(.failure(error))
					}
				}
			}
		}
	}

	private func shouldFetch() -> Bool {
		if store.localStatistics == nil { return true }

		// naive cache control
		guard let lastFetch = store.localStatistics?.lastLocalStatisticsFetchDate else {
			return true
		}
		Log.debug("timestamp >= 300s? \(abs(Date().timeIntervalSince(lastFetch))) >= 300)", log: .vaccination)
		return abs(Date().timeIntervalSince(lastFetch)) >= 300
	}
}
