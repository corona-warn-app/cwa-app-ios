////
// 🦠 Corona-Warn-App
//

import FMDB
import Combine

class ContactDiaryStoreV1: DiaryStoring {

	var diaryDaysPublisher: Published<[DiaryDay]>.Publisher { $diaryDays }

	@Published private var diaryDays: [DiaryDay] = []

	private let database: FMDatabase
	private let queue: DispatchQueue

	init(
		database: FMDatabase,
		queue: DispatchQueue,
		schema: ContactDiaryStoreSchemaV1
	) {
		self.database = database
		self.queue = queue

		createSchemaIdNeeded(schema: schema)
		updateDiaryDays()
	}

	func createSchemaIdNeeded(schema: ContactDiaryStoreSchemaV1) {
		schema.create()
	}

	private func updateDiaryDays() {

	}

	func addContactPerson(name: String) -> Int {
		queue.sync {
			let sql = """
				INSERT INTO ContactPerson (
					name
				VALUES (
					:name
				);
			"""
			let parameters: [String: Any] = [
				"name": name
			]
			guard self.database.executeUpdate(sql, withParameterDictionary: parameters) else {
				Log.error("[SQLite] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return -1
			}
			return -1
		}
	}

	func addLocation(name: String) -> Int {
		return 0
	}

	func addContactPersonEncounter(contactPersonId: Int, date: String) -> Int {
		return 0
	}

	func addLocationVisit(locationId: Int, date: String) -> Int {
		return 0
	}

	func updateContactPerson(id: Int, name: String) {

	}

	func updateLocation(id: Int, name: String) {

	}

	func removeContactPerson(id: Int) {

	}

	func removeLocation(id: Int) {

	}

	func removeContactPersonEncounter(id: Int) {

	}

	func removeLocationVisit(id: Int) {

	}

	func removeAllLocations() {

	}

	func removeAllContactPersons() {
		
	}
}
