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

		updatePublisherFromStore()
	}

	// MARK: - Internal

	var regionStatisticsData = OpenCombine.CurrentValueSubject<[RegionStatisticsData], Never>([])

	func add(_ region: LocalStatisticsRegion) {
		store.selectedLocalStatisticsRegions.append(region)
		updatePublisherFromStore()
		updateLocalStatistics()
	}

	func remove(_ region: LocalStatisticsRegion) {
		store.selectedLocalStatisticsRegions.removeAll {
			$0.id == region.id
		}

		updatePublisherFromStore()
	}

	func updateLocalStatistics(completion: ((Result<Void, Error>) -> Void)? = nil) {
		let fetchedLocalStatisticsQueue = DispatchQueue(label: "com.sap.LocalStatisticsProvider.fetchedLocalStatistics")

		var _fetchedLocalStatistics = [LocalStatisticsMetadata]()
		var fetchedLocalStatistics: [LocalStatisticsMetadata] {
			get { fetchedLocalStatisticsQueue.sync { _fetchedLocalStatistics } }
			set { fetchedLocalStatisticsQueue.sync { _fetchedLocalStatistics = newValue } }
		}

		// We need to fetch local statistics for N saved districts, so we use dispatch group
		// to make sure we get the data for N saved districts
		let localStatisticsGroup = DispatchGroup()

		for localStatisticsRegion in store.selectedLocalStatisticsRegions {
			localStatisticsGroup.enter()
			DispatchQueue.global().async { [weak self] in
				let localStatistics = self?.store.localStatistics.first {
					$0.groupID == String(localStatisticsRegion.federalState.groupID)
				}

				self?.latestLocalStatistics(
					groupID: String(localStatisticsRegion.federalState.groupID),
					eTag: localStatistics?.lastLocalStatisticsETag,
					completion: { result in
						switch result {
						case .success(let localStatistics):
							fetchedLocalStatistics = fetchedLocalStatistics.filter {
								$0.groupID != localStatistics.groupID
							}
							fetchedLocalStatistics.append(localStatistics)
						case .failure(let error):
							Log.error("[LocalStatisticsProvider] Could not fetch saved local statistics for district: \(localStatisticsRegion.name): \(error)", log: .api)
						}

						localStatisticsGroup.leave()
					}
				)
			}
		}

		localStatisticsGroup.notify(queue: .main) { [weak self] in
			guard let self = self else { return }

			self.regionStatisticsData.value = self.regionStatisticsData(
				for: self.store.selectedLocalStatisticsRegions,
				with: fetchedLocalStatistics
			)
		}
	}

	// MARK: - Private

	private let client: LocalStatisticsFetching
	private let store: LocalStatisticsCaching

	private func updatePublisherFromStore() {
		regionStatisticsData.value = regionStatisticsData(
			for: store.selectedLocalStatisticsRegions,
			with: store.localStatistics
		)
	}

	// function to get local statistics for a particular group
	private func latestLocalStatistics(groupID: StatisticsGroupIdentifier, eTag: String? = nil, completion: @escaping (Result<LocalStatisticsMetadata, Error>) -> Void) {
		let localStatistics = store.localStatistics.filter({
			$0.groupID == groupID
		}).compactMap { $0 }.first

		guard let cachedLocalStatistics = localStatistics, !shouldFetch(store: store, groupID: groupID) else {
			let etag = localStatistics?.lastLocalStatisticsETag
			fetchLocalStatistics(groupID: groupID, eTag: etag, completion: { result in
				completion(result)
			})
			return
		}

		// return cached data; no error
		return completion(.success(cachedLocalStatistics))
	}

	private func fetchLocalStatistics(groupID: StatisticsGroupIdentifier, eTag: String? = nil, completion: @escaping
										(Result<LocalStatisticsMetadata, Error>) -> Void) {
		self.client.fetchLocalStatistics(groupID: groupID, eTag: eTag) { result in
			switch result {
			case .success(let response):
				// removing previous data from the store
				self.store.localStatistics.removeAll(where: { $0.groupID == groupID })
				// cache
				self.store.localStatistics.append(LocalStatisticsMetadata(with: response))
				completion(.success(LocalStatisticsMetadata(with: response)))
			case .failure(let error):
				Log.error(error.localizedDescription, log: .vaccination)
				switch error {
				case URLSessionError.notModified:
					var localStatistics = self.store.localStatistics.filter({
						$0.groupID == groupID
					}).compactMap { $0 }.first
					// TODO: Check if this is actually set
					localStatistics?.refreshLastLocalStatisticsFetchDate()
				default:
					break
				}
				// return cached if it exists
				if let cachedLocalStatistics = self.store.localStatistics.first(where: {
					$0.groupID == groupID
				}) {
					completion(.success(cachedLocalStatistics))
				} else {
					completion(.failure(error))
				}
			}
		}
	}

	private func shouldFetch(store: LocalStatisticsCaching, groupID: StatisticsGroupIdentifier) -> Bool {
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

	private func regionStatisticsData(for regions: [LocalStatisticsRegion], with data: [LocalStatisticsMetadata]) -> [RegionStatisticsData] {
		regions.map {
			RegionStatisticsData(
				region: $0,
				localStatisticsData: data.compactMap { $0.localStatistics }
			)
		}
	}

}
