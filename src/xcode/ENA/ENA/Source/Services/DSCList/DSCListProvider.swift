//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

final class DSCListProvider: DSCListProviding {

	// MARK: - Init

	init(
		client: DSCListFetching,
		store: Store,
		interval: TimeInterval = 12 * 60 * 60  // 12 hours
	) {
		self.client = client
		self.store = store
		self.interval = interval
		// load last knows | default DSCList data
		let metaData = Self.loadDSCListMetaDataIfAvailable(store: store, interval: interval)
		lastUpdate = CurrentValueSubject<DSCListMetaData, Never>(metaData)

		// trigger an update immediately
		fetchDSCList()
	}

	// MARK: - Overrides

	// MARK: - Protocol DSCListProviding

	private(set) var lastUpdate: CurrentValueSubject<DSCListMetaData, Never>

	/// return the recent DSCList
	var dscList: SAP_Internal_Dgc_DscList {
		return lastUpdate.value.dscList
	}

	// MARK: - Private
	
	private let client: DSCListFetching
	private let store: Store
	private let interval: TimeInterval

	private static func loadDSCListMetaDataIfAvailable(store: Store, interval: TimeInterval) -> DSCListMetaData {
		guard let metaDataDSCList = store.dscList else {
			// store is empty -> store default and return it
			guard
				let url = Bundle.main.url(forResource: "default_dsc_list", withExtension: "bin"),
				let data = try? Data(contentsOf: url),
				let dscList = try? SAP_Internal_Dgc_DscList(serializedData: data)
			else {
				fatalError("Failed to read default DSCList bin file - set empty fallback")
			}
			return DSCListMetaData(eTag: nil, timestamp: Date(timeIntervalSinceNow: -interval), dscList: dscList)
		}
		return metaDataDSCList
	}

	private func updateStore(eTag: String? = nil, timestamp: Date = Date(), dscList: SAP_Internal_Dgc_DscList) {
		let metaData = DSCListMetaData(eTag: eTag, timestamp: timestamp, dscList: dscList)
		store.dscList = metaData
		lastUpdate.value = metaData
	}

	private func fetchDSCList() {
		guard lastUpdate.value.timestamp.timeIntervalSinceNow > interval else {
			Log.debug("DSCList update interval not reached - stop")
			return
		}

		client.fetchDSCList(etag: lastUpdate.value.eTag) { [weak self] result in
			switch result {
			case .success(let response):
				self?.updateStore(eTag: response.eTag, dscList: response.dscList)

			case .failure(let error):
				Log.error("Failed to updated DSCList \(error)")
			}
		}
	}

}
