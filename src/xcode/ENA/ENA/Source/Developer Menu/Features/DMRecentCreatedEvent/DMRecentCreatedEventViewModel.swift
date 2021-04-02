////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation
import UIKit

final class DMRecentCreatedEventViewModel {

    // MARK: - Init

    init(
        store: Store,
        eventStore: EventStoringProviding
    ) {
        self.store = store
        self.eventStore = eventStore
		self.traceLocations = eventStore.traceLocationsPublisher.value
		
    }

    // MARK: - Internal
	
	let traceLocations: [TraceLocation]

    var refreshTableView: (IndexSet) -> Void = { _ in }
    var showAlert: ((UIAlertController) -> Void)?

    var numberOfSections: Int {
        return 1
    }

    func numberOfRows(in section: Int) -> Int {
		return traceLocations.count
    }
	
	func titleText(_ indexPath: IndexPath) -> String {
		return "Event \(indexPath.row): \(traceLocations[indexPath.row].description)"
	}
	
	func detailText(_ indexPath: IndexPath) -> String {
		let checkin = traceLocations[indexPath.row]

		let id = checkin.id.base64EncodedString()
		
		var optionalStartDate = "--"
		if let startDate = checkin.startDate {
			optionalStartDate = utcFormatter.string(from: startDate)
		}
		
		var optionalEndDate = "--"
		if let endDate = checkin.endDate {
			optionalEndDate = utcFormatter.string(from: endDate)
		}
		
		var optionalDefaultCheckInLengthInMinutes = "--"
		if let defaultCheckInLengthInMinutes = checkin.defaultCheckInLengthInMinutes {
			optionalDefaultCheckInLengthInMinutes = String(defaultCheckInLengthInMinutes)
		}

		let cryptographicSeed = checkin.cryptographicSeed.base64EncodedString()

		let cnPublicKey = checkin.cnPublicKey.base64EncodedString()
		
		var optionalidHash = "--"
		if let idHash = checkin.idHash {
			optionalidHash = String(describing: idHash)
		}
		
		let details = """
		id: \(id)
		version: \(checkin.version)
		type: \(checkin.type)
		description: \(checkin.description)
		address: \(checkin.address)
		startDate: \(optionalStartDate)
		endDate: \(optionalEndDate)
		defaultCheckInLengthInMinutes: \(optionalDefaultCheckInLengthInMinutes)
		cryptographicSeed: \(cryptographicSeed)
		cnPublicKey: \(cnPublicKey)
		idHash: \(optionalidHash)
		qrCodeURL: \(checkin.qrCodeURL ?? "--")
		suggestedCheckoutLength: \(checkin.suggestedCheckoutLength)
		"""
		return details
	}

    // MARK: - Private

    private let store: Store
    private let eventStore: EventStoringProviding
	
	private var utcFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		return dateFormatter
	}()
	
}
#endif
