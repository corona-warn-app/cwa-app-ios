//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

class RecycleBin {

	// MARK: - Init

	init(
		store: RecycleBinStoring
	) {
		self.store = store

		setupFromLaunchArguments()
	}

	// MARK: - Internal

	static let expirationDays = 30
	
	var userTestRestorationHandler: UserTestRestorationHandling!
	var certificateRestorationHandler: CertificateRestorationHandling!

	/// This function moves an item into the bin.
	///
	/// - Parameter item: The item which needs to be moved into the bin.
	/// - Parameter recycledAt: Date at which the item was moved into the bin. Default value: `Date()`
	/// - Returns: A `RecycleBinItem` which contains the item moved into the bin and metadata added from the bin (like `recycledAt`).
	@discardableResult
	func moveToBin(_ item: RecycledItem, recycledAt: Date = Date()) -> RecycleBinItem {
		Log.info("Recycle item.", log: .recycleBin)

		let binItem = RecycleBinItem(
			recycledAt: recycledAt,
			item: item
		)
		store.recycleBinItems.insert(binItem)
		return binItem
	}

	/// Asks if an item can be restored. This call is not restoring the item immediately.
	/// Instead its asking the restoration handler, if the item can be restored.
	///	In some cases the item cannot be restored immediately and needs some further processing or a user decision.
	///	Please see `restore(...)` for restoring the item immediately (Call it after further processing was done and the item can finally be restored).
	///
	/// - Parameter item: The item which needs to be restored.
	/// - Returns: `Result.Success`: The item can be restored. `Result.Failure`: Item cannot be restored and needs some further processing.
	func canRestore(_ item: RecycleBinItem) -> Result<Void, RestorationError> {
		Log.info("Ask for item restoration.", log: .recycleBin)

		switch item.item {
		case .certificate:
			Log.info("Ask for certificate item restoration.", log: .recycleBin)
			return .success(())
		case .userCoronaTest(let coronaTest):
			Log.info("Ask for test item restoration.", log: .recycleBin)
			let canRestoreResult = userTestRestorationHandler.canRestore(coronaTest)
			return canRestoreResult.mapError { RestorationError.testError($0) }
		}
	}

	/// Restores an item.
	/// Restoration handler is called to restore the item.
	/// The item is removed from the bin.
	///
	/// - Parameter item: The item which needs to be restored.
	func restore(_ item: RecycleBinItem) {
		Log.info("Restore item.", log: .recycleBin)

		switch item.item {
		case .certificate(let certificate):
			Log.info("Restore certificate item.", log: .recycleBin)
			certificateRestorationHandler.restore(certificate)
		case .userCoronaTest(let coronaTest):
			Log.info("Restore test item.", log: .recycleBin)
			userTestRestorationHandler.restore(coronaTest)
		}

		store.recycleBinItems.remove(item)
	}

	/// Removes the item from the bin.
	///
	/// - Parameter item: The item which needs to be removed.
	func remove(_ item: RecycleBinItem) {
		Log.info("Remove item.", log: .recycleBin)
		store.recycleBinItems.remove(item)
	}

	/// Removes all items from the bin.
	func removeAll() {
		Log.info("Remove all items.", log: .recycleBin)
		store.recycleBinItems.removeAll()
	}

	/// Returns item for a specific identifier.
	///
	/// - Parameter identifier: Identifier string for the item.
	/// - Returns: An item for the specified `identifier`. Or `nil` if the item does not exist.
	func item(for identifier: String) -> RecycleBinItem? {
		Log.info("Read item.", log: .recycleBin)
		return store.recycleBinItems.first { $0.item.recycleBinIdentifier == identifier }
	}

	/// Removes all items which where moved into the bin more then 30 days ago.
	///
	/// - Parameter now: Used for unit testing. The date against the filter is executed.
	func cleanup(_ now: Date = Date()) {
		Log.info("Cleanup items...", log: .recycleBin)
		Log.info("Number of items before cleanup: \(store.recycleBinItems.count)", log: .recycleBin)

		guard let thresholdDate = Calendar.current.date(byAdding: .day, value: -RecycleBin.expirationDays, to: now) else {
			fatalError("Could not create date.")
		}

		let cleanedSubsequence = store.recycleBinItems.filter {
			return $0.recycledAt >= thresholdDate
		}
		store.recycleBinItems = Set(cleanedSubsequence)

		Log.info("Number of items after cleanup: \(store.recycleBinItems.count)", log: .recycleBin)
		Log.info("Finished Cleanup.", log: .recycleBin)
	}

	// MARK: - Private

	private let store: RecycleBinStoring

	private func setupFromLaunchArguments() {
		#if DEBUG
		if isUITesting && LaunchArguments.recycleBin.pcrTest.boolValue {
			store.recycleBinItems.insert(
				RecycleBinItem(
					recycledAt: Date(),
					item: .userCoronaTest(.pcr(
						UserPCRTest(
							registrationDate: Date(),
							testResult: .pending,
							positiveTestResultWasShown: false,
							isSubmissionConsentGiven: false,
							keysSubmitted: false,
							journalEntryCreated: false,
							certificateSupportedByPointOfCare: false,
							certificateConsentGiven: false,
							certificateRequested: false
						)
					))
				)
			)
		}
		#endif
	}

}

#if !RELEASE

extension RecycleBin {
	static func fake(store: RecycleBinStoring = MockTestStore()) -> RecycleBin {
		let recycleBin = RecycleBin(store: store)
		recycleBin.userTestRestorationHandler = UserTestRestorationHandlerFake()
		recycleBin.certificateRestorationHandler = CertificateRestorationHandlerFake()
		return recycleBin
	}
}

#endif
