//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

enum RecycledItem: Hashable, Equatable, Encodable {
	case certificate(HealthCertificate)
	case coronaTest(CoronaTest)

	// MARK: Hashable

	func hash(into hasher: inout Hasher) {
		switch self {
		case .certificate:
			hasher.combine(0)
		case .coronaTest:
			hasher.combine(1)
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
}

struct RecycleBinItem: Equatable, Hashable, Encodable {
	let deletionDate: Date
//	let restaurationHandler: RestaurationHandler
	let item: RecycledItem

	// MARK: Equatable

	static func == (lhs: RecycleBinItem, rhs: RecycleBinItem) -> Bool {
		return lhs.item == rhs.item
	}
}

//struct RestaurationHandler: Hashable, Equatable, Codable {
//	let id = UUID()
//	var canRestore: ((RecycledItem) -> Result<Void, RestaurationError>)?
//	var restore: ((RecycledItem) -> Void)?
//
//	// MARK: Hashable
//
//	func hash(into hasher: inout Hasher) {
//		hasher.combine(id)
//	}
//
//	// MARK: Equatable
//
//	static func == (lhs: RestaurationHandler, rhs: RestaurationHandler) -> Bool {
//		return lhs.id == rhs.id
//	}
//}

enum SomeError: Error {

}

class RecycleBin {

	@DidSetPublished private(set) var items = Set<RecycleBinItem>()

	var canRestoreTest: ((CoronaTest) -> Result<Void, SomeError>)?
	var restoreTest: ((CoronaTest) -> Void)?

	var restoreHealthCertificate: ((HealthCertificate) -> Void)?

	func recycle(_ item: RecycledItem) {
		let binItem = RecycleBinItem(
			deletionDate: Date(),
			item: item
		)
		items.insert(binItem)
	}

	func canRestore(_ item: RecycleBinItem) -> Result<Void, SomeError> {
		switch item.item {
		case .certificate:
			return .success(())
		case .coronaTest(let coronaTest):
			guard let canRestoreTest = canRestoreTest else {
				fatalError("ToDo")
			}
			return canRestoreTest(coronaTest)
		}
	}

	func restore(_ item: RecycleBinItem) {
		switch item.item {
		case .certificate(let certificate):
			restoreHealthCertificate?(certificate)
		case .coronaTest(let coronaTest):
			restoreTest?(coronaTest)
		}

		items.remove(item)
	}

	func remove(_ item: RecycleBinItem) {
		items.remove(item)
	}

	func removeAll() {
		items.removeAll()
	}

	func item(for identifier: String) -> RecycledItem? {

		return nil
	}

	func cleanup() {

	}
}
