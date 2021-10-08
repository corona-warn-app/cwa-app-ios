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

	// MARK: Hashable

	func hash(into hasher: inout Hasher) {
		switch self {
		case .certificate:
			hasher.combine(0)
		case .coronaTest:
			hasher.combine(1)
		}
	}

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
}

struct RecycleBinItem: Equatable, Hashable, Codable {
	let deletionDate: Date
	let item: RecycledItem

	// MARK: Equatable

	static func == (lhs: RecycleBinItem, rhs: RecycleBinItem) -> Bool {
		return lhs.item == rhs.item
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
	var canRestore: ((HealthCertificate) -> Result<Void, TestRestorationError>) { get set }
	var restore: ((HealthCertificate) -> Void) { get set }
}

class RecycleBin {

	// MARK: - Init

	init(
		testRestorationHandler: TestRestorationHandling,
		certificateRestorationHandler: CertificateRestorationHandling
	) {
		self.testRestorationHandler = testRestorationHandler
		self.certificateRestorationHandler = certificateRestorationHandler
	}

	// MARK: - Internal

	@DidSetPublished private(set) var items = Set<RecycleBinItem>()

	func recycle(_ item: RecycledItem) {
		let binItem = RecycleBinItem(
			deletionDate: Date(),
			item: item
		)
		items.insert(binItem)
	}

	func canRestore(_ item: RecycleBinItem) -> Result<Void, RestorationError> {
		switch item.item {
		case .certificate:
			return .success(())
		case .coronaTest(let coronaTest):
			let canRestoreResult = testRestorationHandler.canRestore(coronaTest)
			return canRestoreResult.mapError { RestorationError.testError($0) }
		}
	}

	func restore(_ item: RecycleBinItem) {
		switch item.item {
		case .certificate(let certificate):
			certificateRestorationHandler.restore(certificate)
		case .coronaTest(let coronaTest):
			testRestorationHandler.restore(coronaTest)
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
		items.first { $0.item.recycleBinIdentifier == identifier }?.item
	}

	func cleanup() {
		let cleanedSubsequence = items.drop { item in
			guard let treshholdDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) else {
				fatalError("Could not create date.")
			}
			return item.deletionDate < treshholdDate
		}
		items = Set(cleanedSubsequence)
	}

	// MARK: - Private

	private let testRestorationHandler: TestRestorationHandling
	private let certificateRestorationHandler: CertificateRestorationHandling
}
