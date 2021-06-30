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

	func latestLocalStatistics(groupID: String, eTag: String? = nil) -> AnyPublisher<SAP_Internal_Stats_LocalStatistics, Error> {
		let localStatistics = store.localStatistics.filter({
			$0.groupID == groupID
		}).compactMap { $0 }.first
		
		guard let cached = localStatistics, !shouldFetch(store: store, groupID: groupID) else {
			let etag = localStatistics?.lastLocalStatisticsETag
			return fetchLocalStatistics(groupID: groupID, eTag: etag).eraseToAnyPublisher()
		}
		// return cached data; no error
		return Just(cached.localStatistics)
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}

	// MARK: - Private

	private let client: LocalStatisticsFetching
	private let store: LocalStatisticsCaching

	private func fetchLocalStatistics(groupID: String, eTag: String? = nil) -> Future<SAP_Internal_Stats_LocalStatistics, Error> {
		return Future { promise in
			self.client.fetchLocalStatistics(groupID: groupID, eTag: eTag) { result in
				switch result {
				case .success(let response):
					// cache
					self.store.localStatistics.append(LocalStatisticsMetadata(with: response))
					promise(.success(response.localStatistics))
				case .failure(let error):
					Log.error(error.localizedDescription, log: .vaccination)
					switch error {
					case URLSessionError.notModified:
						var localStatistics = self.store.localStatistics.filter({
							$0.groupID == groupID
						}).compactMap { $0 }.first
						localStatistics?.refreshLastLocalStatisticsFetchDate()
					default:
						break
					}
					// return cached if it exists
					if let cachedLocalStatistics = self.store.localStatistics.filter({
						$0.groupID == groupID
					}).compactMap({ $0 }).first {
						promise(.success(cachedLocalStatistics.localStatistics))
					} else {
						promise(.failure(error))
					}
				}
			}
		}
	}

	private func shouldFetch(store: LocalStatisticsCaching, groupID: String) -> Bool {
		let localStatistics = store.localStatistics.filter({
			$0.groupID == groupID
		}).compactMap { $0 }.first
		if localStatistics == nil { return true }

		// naive cache control
		guard let lastFetch = localStatistics?.lastLocalStatisticsFetchDate else {
			return true
		}
		Log.debug("timestamp >= 300s? \(abs(Date().timeIntervalSince(lastFetch))) >= 300)", log: .localStatistics)
		return abs(Date().timeIntervalSince(lastFetch)) >= 300
	}
}
