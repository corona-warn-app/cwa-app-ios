//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

protocol RecycleBinIdentifiable {
	var recycleBinIdentifier: String { get }
}

enum RecycledItem: Hashable, Equatable, Codable {
	case certificate(HealthCertificate)
	case coronaTest(CoronaTest)

	var recycleBinIdentifier: String {
		switch self {
		case .certificate(let certificate):
			return certificate.recycleBinIdentifier
		case .coronaTest(let test):
			return test.recycleBinIdentifier
		}
	}

	// MARK: Equatable

	static func == (lhs: RecycledItem, rhs: RecycledItem) -> Bool {
		switch (lhs, rhs) {
		case let (.certificate(lhsCert), .certificate(rhsCert)):
			return lhsCert.recycleBinIdentifier == rhsCert.recycleBinIdentifier
		default:
			return false
		}
	}

	// MARK: Hashable

	func hash(into hasher: inout Hasher) {
		hasher.combine(recycleBinIdentifier)
	}
}

struct RecycleBinItem: Equatable, Hashable, Codable {
	let recycleDate: Date
	let item: RecycledItem

	// MARK: Equatable

	// We take only the item into account because we don't want to equate against the recycleDate.
	// It's not possible to have the same item with different recycleDates in the recycle-bin (see hashable and 'set' implementation in the recycle-bin. The hashing is only going against the item, not the date.
	static func == (lhs: RecycleBinItem, rhs: RecycleBinItem) -> Bool {
		return lhs.item == rhs.item
	}

	// MARK: Hashable

	// We take only the item into account because we don't want to have duplicate item entries (with different dates) in the set of recycle-bin items.
	func hash(into hasher: inout Hasher) {
		hasher.combine(item)
	}
}

enum RestorationError: Error {
	case testError(TestRestorationError)
	case certificateError(CertificateRestorationError)
}

enum TestRestorationError: Error {
	case some
}

protocol TestRestorationHandling {
	var canRestore: ((CoronaTest) -> Result<Void, TestRestorationError>) { get set }
	var restore: ((CoronaTest) -> Void) { get set }
}

enum CertificateRestorationError: Error {
	case some
}

protocol CertificateRestorationHandling {
	var canRestore: ((HealthCertificate) -> Result<Void, CertificateRestorationError>) { get set }
	var restore: ((HealthCertificate) -> Void) { get set }
}

class RecycleBin {

	// MARK: - Init

	init(
		store: RecycleBinStoring
	) {
		self.store = store
	}

	// MARK: - Internal

	var testRestorationHandler: TestRestorationHandling!
	var certificateRestorationHandler: CertificateRestorationHandling!

	@discardableResult
	func moveToBin(_ item: RecycledItem, recycleDate: Date = Date()) -> RecycleBinItem {
		Log.info("Recycle item.", log: .recycleBin)

		let binItem = RecycleBinItem(
			recycleDate: recycleDate,
			item: item
		)
		store.recycleBinItems.insert(binItem)
		return binItem
	}

	func canRestore(_ item: RecycleBinItem) -> Result<Void, RestorationError> {
		Log.info("Ask for item restoration.", log: .recycleBin)

		switch item.item {
		case .certificate(let certificate):
			Log.info("Ask for certificate item restoration.", log: .recycleBin)
			let canRestoreResult = certificateRestorationHandler.canRestore(certificate)
			return canRestoreResult.mapError { RestorationError.certificateError($0) }
		case .coronaTest(let coronaTest):
			Log.info("Ask for test item restoration.", log: .recycleBin)
			let canRestoreResult = testRestorationHandler.canRestore(coronaTest)
			return canRestoreResult.mapError { RestorationError.testError($0) }
		}
	}

	func restore(_ item: RecycleBinItem) {
		Log.info("Restore item.", log: .recycleBin)

		switch item.item {
		case .certificate(let certificate):
			Log.info("Restore certificate item.", log: .recycleBin)
			certificateRestorationHandler.restore(certificate)
		case .coronaTest(let coronaTest):
			Log.info("Restore test item.", log: .recycleBin)
			testRestorationHandler.restore(coronaTest)
		}

		store.recycleBinItems.remove(item)
	}

	func remove(_ item: RecycleBinItem) {
		Log.info("Remove item.", log: .recycleBin)
		store.recycleBinItems.remove(item)
	}

	func removeAll() {
		Log.info("Remove all items.", log: .recycleBin)
		store.recycleBinItems.removeAll()
	}

	func item(for identifier: String) -> RecycledItem? {
		Log.info("Read item.", log: .recycleBin)
		return store.recycleBinItems.first { $0.item.recycleBinIdentifier == identifier }?.item
	}

	func cleanup(_ now: Date = Date()) {
		Log.info("Cleanup items...", log: .recycleBin)
		Log.info("Number of items before cleanup: \(store.recycleBinItems.count)", log: .recycleBin)

		guard let treshholdDate = Calendar.current.date(byAdding: .day, value: -30, to: now) else {
			fatalError("Could not create date.")
		}

		let cleanedSubsequence = store.recycleBinItems.filter {
			return $0.recycleDate >= treshholdDate
		}
		store.recycleBinItems = Set(cleanedSubsequence)

		Log.info("Number of items after cleanup: \(store.recycleBinItems.count)", log: .recycleBin)
		Log.info("Finished Cleanup.", log: .recycleBin)
	}

	// MARK: - Private

	private let store: RecycleBinStoring
}
