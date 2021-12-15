//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import HealthCertificateToolkit

final class DSCListProvider: DSCListProviding {

	// MARK: - Init

	init(
		client: DSCListFetching,
		store: DSCListCaching,
		interval: TimeInterval = updateInterval
	) {
		self.client = client
		self.store = store
		self.interval = interval
		// load last knows | default DSCList data
		self.metaData = Self.loadDSCListMetaDataIfAvailable(store: store, interval: interval)
		self.signingCertificates = CurrentValueSubject<[DCCSigningCertificate], Never>(metaData.signingCertificate)

		// trigger an update immediately
		NotificationCenter.default.addObserver(self, selector: #selector(updateListIfNeeded), name: UIApplication.willEnterForegroundNotification, object: nil)
		updateListIfNeeded()
	}

	// MARK: - Protocol DSCListProviding

	private(set) var signingCertificates: CurrentValueSubject<[DCCSigningCertificate], Never>

	// MARK: - Internal

	static let updateInterval: Double = 12 * 60 * 60  // 12 hours

	private(set) var metaData: DSCListMetaData {
		// on change write to the store and update publisher
		didSet {
			store.dscList = metaData
			signingCertificates.value = metaData.signingCertificate
		}
	}

	// MARK: - Private

	private let client: DSCListFetching
	private let store: DSCListCaching
	private let interval: TimeInterval

	private static func loadDSCListMetaDataIfAvailable(store: DSCListCaching, interval: TimeInterval) -> DSCListMetaData {
		Log.info("Load DSCList.")

		guard let metaDataDSCList = store.dscList else {
			// store is empty -> store default and return it
			guard
				let url = Bundle.main.url(forResource: "default_dsc_list", withExtension: "bin"),
				let data = try? Data(contentsOf: url),
				let dscList = try? SAP_Internal_Dgc_DscList(serializedData: data)
			else {
				fatalError("Failed to read default DSCList bin file - set empty fallback")
			}
			Log.info("Fallback default DSCList got loaded", log: .api)
			return DSCListMetaData(eTag: nil, timestamp: Date(timeIntervalSinceNow: -interval), dscList: dscList)
		}
		
		Log.info("DSCList loaded from store.")
		return metaDataDSCList
	}

	@objc
	private func updateListIfNeeded() {
		Log.info("Update DSCList if needed.")
		Log.debug("timeinterval since last check: \(metaData.timestamp.timeIntervalSinceNow)")
		
		guard metaData.timestamp.timeIntervalSinceNow < -interval else {
			Log.debug("DSCList update interval not reached - stop")
			return
		}
		client.fetchDSCList(etag: metaData.eTag) { [weak self] result in
			switch result {
			case .success(let response):
				Log.info("Fetched DSCList from server", log: .api)
				self?.metaData = DSCListMetaData(eTag: response.eTag, timestamp: Date(), dscList: response.dscList)

			case .failure(let error):
				Log.error("Failed to updated DSCList \(error)")
			}
		}
	}

}
