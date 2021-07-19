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
		
		self.selectedLocalStatisticsTuples = []
	}

	// MARK: - Internal

	// function to get local statistics for a particular group
	func latestLocalStatistics(groupID: StatisticsGroupIdentifier, eTag: String? = nil) -> AnyPublisher<SAP_Internal_Stats_LocalStatistics, Error> {
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
	
	// function to get local statistics for N saved districts which are passed as an array
	// returns an array of type SelectedLocalStatisticsTuple which contains the data for a particular group
	// and the district information which will be then used for filtering.
	func latestSelectedLocalStatistics(selectedlocalStatisticsRegions: [LocalStatisticsRegion], completion: @escaping ([SelectedLocalStatisticsTuple]) -> Void) {
		return fetchSelectedLocalStatistics(selectedlocalStatisticsDistricts: selectedlocalStatisticsRegions, completion: completion)
	}

	// MARK: - Private

	private let client: LocalStatisticsFetching
	private let store: LocalStatisticsCaching
	private var selectedLocalStatisticsTuples: [SelectedLocalStatisticsTuple]
	private var subscriptions = Set<AnyCancellable>()

	private func fetchSelectedLocalStatistics(selectedlocalStatisticsDistricts: [LocalStatisticsRegion], completion: @escaping ([SelectedLocalStatisticsTuple]) -> Void) {
		
		self.selectedLocalStatisticsTuples = []

		// We need to fetch local statistics for N saved districts, so we use dispatch group
		// to make sure we get the data for N saved districts
		let localStatisticsGroup = DispatchGroup()
		
		for localStatisticsDistrict in selectedlocalStatisticsDistricts {
			localStatisticsGroup.enter()
			DispatchQueue.global().async {
				let localStatistics = self.store.localStatistics.filter({
					$0.groupID == String(localStatisticsDistrict.federalState.groupID)
				}).compactMap { $0 }.first
				
				self.fetchLocalStatistics(groupID: String(localStatisticsDistrict.federalState.groupID), eTag: localStatistics?.lastLocalStatisticsETag)
					.sink(
					receiveCompletion: { result in
						switch result {
						case .finished:
							break
						case .failure(let error):
							Log.error("[LocalStatisticsProvider] Could not fetch saved local statistics for district: \(localStatisticsDistrict.name): \(error)", log: .api)
						}
					}, receiveValue: { [weak self] in
						self?.selectedLocalStatisticsTuples.append(SelectedLocalStatisticsTuple(federalStateAndDistrictsData: $0, localStatisticsRegion: localStatisticsDistrict))
						localStatisticsGroup.leave()
					}
				)
				.store(in: &self.subscriptions)
			}
		}
		
		localStatisticsGroup.notify(queue: .main) {
			completion(self.selectedLocalStatisticsTuples)
		}
	}

	private func fetchLocalStatistics(groupID: StatisticsGroupIdentifier, eTag: String? = nil) -> Future<SAP_Internal_Stats_LocalStatistics, Error> {
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
