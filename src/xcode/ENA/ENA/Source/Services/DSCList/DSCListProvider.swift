//
// 🦠 Corona-Warn-App
//

import UIKit
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
		self.metaData = Self.loadDSCListMetaDataIfAvailable(store: store, interval: interval)
		self.dscList = CurrentValueSubject<SAP_Internal_Dgc_DscList, Never>(metaData.dscList)

		// trigger an update immediately
		NotificationCenter.default.addObserver(self, selector: #selector(updateListIfNeeded), name: UIApplication.willEnterForegroundNotification, object: nil)
		updateListIfNeeded()
	}

	deinit {
		NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
	}

	// MARK: - Protocol DSCListProviding

	private(set) var dscList: CurrentValueSubject<SAP_Internal_Dgc_DscList, Never>

	// MARK: - Internal

	private(set) var metaData: DSCListMetaData {
		// on change write to the store and update publisher
		didSet {
			store.dscList = metaData
			dscList.value = metaData.dscList
		}
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

	@objc
	private func updateListIfNeeded() {
		Log.debug("timeinterval since last check: \(metaData.timestamp.timeIntervalSinceNow)")
		guard metaData.timestamp.timeIntervalSinceNow < -interval else {
			Log.debug("DSCList update interval not reached - stop")
			return
		}
		client.fetchDSCList(etag: metaData.eTag) { [weak self] result in
			switch result {
			case .success(let response):
				self?.metaData = DSCListMetaData(eTag: response.eTag, timestamp: Date(), dscList: response.dscList)

			case .failure(let error):
				Log.error("Failed to updated DSCList \(error)")
			}
		}
	}

}
