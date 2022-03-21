//
// 🦠 Corona-Warn-App
//

protocol RecycleBinIdentifiable {
	var recycleBinIdentifier: String { get }
}

enum RecycledItem: Hashable, Equatable, Codable {
	case certificate(HealthCertificate)
	case userCoronaTest(UserCoronaTest)

	var recycleBinIdentifier: String {
		switch self {
		case .certificate(let certificate):
			return certificate.recycleBinIdentifier
		case .userCoronaTest(let test):
			return test.recycleBinIdentifier
		}
	}

	// MARK: Equatable

	static func == (lhs: RecycledItem, rhs: RecycledItem) -> Bool {
		switch (lhs, rhs) {
		case let (.certificate(lhsCert), .certificate(rhsCert)):
			return lhsCert.recycleBinIdentifier == rhsCert.recycleBinIdentifier
		case let (.userCoronaTest(lhsTest), .userCoronaTest(rhsTest)):
			return lhsTest.recycleBinIdentifier == rhsTest.recycleBinIdentifier
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
	let recycledAt: Date
	let item: RecycledItem

	// MARK: Equatable

	// We take only the item into account because we don't want to equate against recycledAt.
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
