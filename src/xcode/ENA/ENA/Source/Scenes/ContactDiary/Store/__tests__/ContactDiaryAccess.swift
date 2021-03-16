////
// 🦠 Corona-Warn-App
//

import XCTest
import Foundation
import FMDB

final class ContactDiaryAccess {

	func addContactPerson(with name: String, to databaseQueue: FMDatabaseQueue) -> Int {
		var lastInsertedRow: Int = -1

		databaseQueue.inDatabase { database in
			let sql = """
				INSERT INTO ContactPerson (
					name
				)
				VALUES (
					SUBSTR(:name, 1, 250)
				);
			"""
			let parameters: [String: Any] = [
				"name": name
			]
			database.executeUpdate(sql, withParameterDictionary: parameters)
			lastInsertedRow = Int(database.lastInsertRowId)
		}
		return lastInsertedRow
	}

	func addLocation(with name: String, to databaseQueue: FMDatabaseQueue) -> Int {
		var lastInsertedRow: Int = -1

		databaseQueue.inDatabase { database in
			let sql = """
				INSERT INTO Location (
					name
				)
				VALUES (
					SUBSTR(:name, 1, 250)
				);
			"""
			let parameters: [String: Any] = [
				"name": name
			]
			database.executeUpdate(sql, withParameterDictionary: parameters)
			lastInsertedRow = Int(database.lastInsertRowId)
		}
		return lastInsertedRow
	}

	func addContactPersonEncounter(
		date: String,
		contactPersonId: Int,
		to databaseQueue: FMDatabaseQueue
	) {
		databaseQueue.inDatabase { database in
			let sql = """
				INSERT INTO ContactPersonEncounter (
					date,
					contactPersonId
				)
				VALUES (
					:date,
					:contactPersonId
				);
			"""
			let parameters: [String: Any] = [
				"date": date,
				"contactPersonId": contactPersonId
			]
			database.executeUpdate(sql, withParameterDictionary: parameters)
		}
	}

	func addLocationVisit(
		date: String,
		locationId: Int,
		to databaseQueue: FMDatabaseQueue
	) {
		databaseQueue.inDatabase { database in
			let sql = """
				INSERT INTO LocationVisit (
					date,
					locationId
				)
				VALUES (
					:date,
					:locationId
				);
			"""
			let parameters: [String: Any] = [
				"date": date,
				"locationId": locationId
			]
			database.executeUpdate(sql, withParameterDictionary: parameters)
		}
	}
}
