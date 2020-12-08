////
// 🦠 Corona-Warn-App
//

import XCTest
import FMDB
@testable import ENA

class ContactDiaryStoreV1Tests: XCTestCase {

	func test_When_addContactPerson_Then_ContactPersonIsPersisted() {
		let store = makeContactDiaryStore()

		store.addContactPerson(name: "Helge Schneider")
	}

	private func makeContactDiaryStore() -> ContactDiaryStoreV1 {
		let database = FMDatabase.inMemory()
		database.open()

		let queue = DispatchQueue(label: "ContactDiaryStoreSchemaV1TestsQueue")
		let schema = ContactDiaryStoreSchemaV1(database: database, queue: queue)

		return ContactDiaryStoreV1(
			database: database,
			queue: queue,
			schema: schema
		)
	}
}
