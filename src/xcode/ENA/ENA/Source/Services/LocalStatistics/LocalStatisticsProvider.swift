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
		guard !store.selectedLocalStatisticsRegions.contains(region) else {
			return
		}

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

		var _errors = [Error]()
		var errors: [Error] {
			get { fetchedLocalStatisticsQueue.sync { _errors } }
			set { fetchedLocalStatisticsQueue.sync { _errors = newValue } }
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
							errors.append(error)
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

			if let firstError = errors.first {
				/// Data verification errors are preferably passed on as they cause an error message for the user
				let firstDataVerificationError = errors.first {
					if case CachingHTTPClient.CacheError.dataVerificationError = $0 {
						return true
					} else {
						return false
					}
				}

				completion?(.failure(firstDataVerificationError ?? firstError))
			} else {
				completion?(.success(()))
			}
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

	private func latestLocalStatistics(
		groupID: StatisticsGroupIdentifier,
		eTag: String? = nil,
		completion: @escaping (Result<LocalStatisticsMetadata, Error>) -> Void
	) {
		let localStatistics = store.localStatistics.filter({
			$0.groupID == groupID
		}).compactMap { $0 }.first

		guard let cachedLocalStatistics = localStatistics, !shouldFetch(store: store, groupID: groupID) else {
			self.client.fetchLocalStatistics(
				groupID: groupID,
				eTag: localStatistics?.lastLocalStatisticsETag
			) { result in
				switch result {
				case .success(let response):
					// removing previous data from the store
					self.store.localStatistics.removeAll(where: { $0.groupID == groupID })
					// cache
					self.store.localStatistics.append(LocalStatisticsMetadata(with: response))
					completion(.success(LocalStatisticsMetadata(with: response)))
				case .failure(let error):
					Log.error(error.localizedDescription, log: .localStatistics)
					switch error {
					case URLSessionError.notModified:
						if let cachedIndex = self.store.localStatistics.firstIndex(where: { $0.groupID == groupID }) {
							var cachedLocalStatistics = self.store.localStatistics[cachedIndex]
							cachedLocalStatistics.refreshLastLocalStatisticsFetchDate()
							self.store.localStatistics.remove(at: cachedIndex)
							self.store.localStatistics.append(cachedLocalStatistics)
						}
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

			return
		}

		// return cached data; no error
		return completion(.success(cachedLocalStatistics))
	}

	private func shouldFetch(
		store: LocalStatisticsCaching,
		groupID: StatisticsGroupIdentifier
	) -> Bool {
		guard let localStatistics = self.store.localStatistics.first(where: { $0.groupID == groupID }) else {
			return true
		}

		// naive cache control
		let lastFetchDate = localStatistics.lastLocalStatisticsFetchDate
		Log.debug("timestamp >= 300s? \(abs(Date().timeIntervalSince(lastFetchDate))) >= 300)", log: .localStatistics)

		return abs(Date().timeIntervalSince(lastFetchDate)) >= 300
	}

	private func regionStatisticsData(
		for regions: [LocalStatisticsRegion],
		with data: [LocalStatisticsMetadata]
	) -> [RegionStatisticsData] {
		regions.map {
			RegionStatisticsData(
				region: $0,
				localStatisticsData: data.compactMap { $0.localStatistics }
			)
		}
	}

}
