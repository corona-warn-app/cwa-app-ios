//
// 🦠 Corona-Warn-App
//

import Foundation

class LocalStatisticsProvider: LocalStatisticsProviding {

	// MARK: - Init

	init(client: LocalStatisticsFetching, store: Store) {
		self.client = client
		self.store = store
		
		self.selectedLocalStatisticsTuples = []
	}

	// MARK: - Internal

	var cachedSelectedLocalStatisticsTuples: [SelectedLocalStatisticsTuple] {
		var selectedLocalStatisticsTuples: [SelectedLocalStatisticsTuple] = []

		for localStatisticsRegion in store.selectedLocalStatisticsRegions {
			guard let localStatistics = store.localStatistics.first(where: {
				$0.groupID == String(localStatisticsRegion.federalState.groupID)
			})?.localStatistics else {
				continue
			}

			selectedLocalStatisticsTuples.append(
				SelectedLocalStatisticsTuple(
					federalStateAndDistrictsData: localStatistics,
					localStatisticsRegion: localStatisticsRegion
				)
			)
		}

		return selectedLocalStatisticsTuples
	}

	// function to get local statistics for a particular group
	func latestLocalStatistics(groupID: StatisticsGroupIdentifier, eTag: String? = nil, completion: @escaping (Result<SAP_Internal_Stats_LocalStatistics, Error>) -> Void) {
		let localStatistics = store.localStatistics.filter({
			$0.groupID == groupID
		}).compactMap { $0 }.first
		
		guard let cached = localStatistics, !shouldFetch(store: store, groupID: groupID) else {
			let etag = localStatistics?.lastLocalStatisticsETag
			fetchLocalStatistics(groupID: groupID, eTag: etag, completion: { result in
				completion(result)
			})
			return
		}

		// return cached data; no error
		return completion(.success(cached.localStatistics))
	}
	
	// function to get local statistics for N saved districts which are passed as an array
	// returns an array of type SelectedLocalStatisticsTuple which contains the data for a particular group
	// and the district information which will be then used for filtering.
	func latestSelectedLocalStatistics(selectedLocalStatisticsRegions: [LocalStatisticsRegion], completion: @escaping ([SelectedLocalStatisticsTuple]) -> Void) {
		self.selectedLocalStatisticsTuples = []

		// We need to fetch local statistics for N saved districts, so we use dispatch group
		// to make sure we get the data for N saved districts
		let localStatisticsGroup = DispatchGroup()

		for localStatisticsRegion in selectedLocalStatisticsRegions {
			localStatisticsGroup.enter()
			DispatchQueue.global().async { [weak self] in
				let localStatistics = self?.store.localStatistics.first(where: {
					$0.groupID == String(localStatisticsRegion.federalState.groupID)
				})

				self?.latestLocalStatistics(groupID: String(localStatisticsRegion.federalState.groupID), eTag: localStatistics?.lastLocalStatisticsETag, completion: { result in
					switch result {
					case .success(let localStatistics):
						self?.selectedLocalStatisticsTuples.append(SelectedLocalStatisticsTuple(federalStateAndDistrictsData: localStatistics, localStatisticsRegion: localStatisticsRegion))
						localStatisticsGroup.leave()
					case .failure(let error):
						Log.error("[LocalStatisticsProvider] Could not fetch saved local statistics for district: \(localStatisticsRegion.name): \(error)", log: .api)
					}
				})
			}
		}

		localStatisticsGroup.notify(queue: .main) { [weak self] in
			var arrangedSelectedLocalStatisticsTuples: [SelectedLocalStatisticsTuple] = []
			for localStatisticsRegion in selectedLocalStatisticsRegions {
				guard let localStatisticsTuple = self?.selectedLocalStatisticsTuples.first(where: {
					$0.localStatisticsRegion.id == localStatisticsRegion.id
				}) else {
					continue
				}

				arrangedSelectedLocalStatisticsTuples.append(localStatisticsTuple)
			}
			completion(arrangedSelectedLocalStatisticsTuples)
		}
	}

	// MARK: - Private

	private let client: LocalStatisticsFetching
	private let store: LocalStatisticsCaching
	private var selectedLocalStatisticsTuples: [SelectedLocalStatisticsTuple]

	private func fetchLocalStatistics(groupID: StatisticsGroupIdentifier, eTag: String? = nil, completion: @escaping
		(Result<SAP_Internal_Stats_LocalStatistics, Error>) -> Void) {
			self.client.fetchLocalStatistics(groupID: groupID, eTag: eTag) { result in
				switch result {
				case .success(let response):
					// removing previous data from the store
					self.store.localStatistics.removeAll(where: { $0.groupID == groupID })
					// cache
					self.store.localStatistics.append(LocalStatisticsMetadata(with: response))
					completion(.success(response.localStatistics))
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
					if let cachedLocalStatistics = self.store.localStatistics.first(where: {
						$0.groupID == groupID
					}) {
						completion(.success(cachedLocalStatistics.localStatistics))
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
}
