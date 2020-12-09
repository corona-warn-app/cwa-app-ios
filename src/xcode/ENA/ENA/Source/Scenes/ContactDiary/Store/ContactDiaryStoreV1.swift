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

		openAndSetup()

		createSchemaIfNeeded(schema: schema)
		updateDiaryDays()
	}

	func createSchemaIfNeeded(schema: ContactDiaryStoreSchemaV1) {
		_ = schema.create()
	}

	private func updateDiaryDays() {

	}

	private func openAndSetup() {
		Log.info("[ContactDiaryStore] Open and setup database.", log: .localData)

		guard database.open() else {
			Log.error("[ContactDiaryStore] Database could not be opened", log: .localData)
			return
		}

		queue.sync {
			let sql = """
				PRAGMA locking_mode=EXCLUSIVE;
				PRAGMA auto_vacuum=2;
				PRAGMA journal_mode=WAL;
				PRAGMA foreign_keys=ON;
			"""
			guard self.database.executeStatements(sql) else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return
			}
		}
	}

	func addContactPerson(name: String) -> Result<Int64, SQLiteErrorCode> {
		queue.sync {
			Log.info("[ContactDiaryStore] Add ContactPerson.", log: .localData)

			let sql = """
				INSERT INTO ContactPerson (
					name
				)
				VALUES (
					:name
				);
			"""
			let parameters: [String: Any] = [
				"name": name
			]
			guard self.database.executeUpdate(sql, withParameterDictionary: parameters) else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(database.lastInsertRowId)
		}
	}

	func addLocation(name: String) -> Result<Int64, SQLiteErrorCode> {
		queue.sync {
			Log.info("[ContactDiaryStore] Add Location.", log: .localData)

			let sql = """
				INSERT INTO Location (
					name
				)
				VALUES (
					:name
				);
			"""

			let parameters: [String: Any] = [
				"name": name
			]
			guard self.database.executeUpdate(sql, withParameterDictionary: parameters) else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(database.lastInsertRowId)
		}
	}

	func addContactPersonEncounter(contactPersonId: Int64, date: String) -> Result<Int64, SQLiteErrorCode> {
		queue.sync {
			Log.info("[ContactDiaryStore] Add ContactPersonEncounter.", log: .localData)

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
			guard self.database.executeUpdate(sql, withParameterDictionary: parameters) else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(database.lastInsertRowId)
		}
	}

	func addLocationVisit(locationId: Int64, date: String) -> Result<Int64, SQLiteErrorCode> {
		queue.sync {
			Log.info("[ContactDiaryStore] Add LocationVisit.", log: .localData)

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
			guard self.database.executeUpdate(sql, withParameterDictionary: parameters) else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(database.lastInsertRowId)
		}
	}

	func updateContactPerson(id: Int64, name: String) -> Result<Void, SQLiteErrorCode> {
		queue.sync {
			Log.info("[ContactDiaryStore] Update ContactPerson with id: \(id).", log: .localData)

			let sql = """
				UPDATE ContactPerson
				SET name = ?
				WHERE id = ?
			"""

			do {
				try self.database.executeUpdate(sql, values: [name, id])
			} catch {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(())
		}
	}

	func updateLocation(id: Int64, name: String) -> Result<Void, SQLiteErrorCode> {
		queue.sync {
			Log.info("[ContactDiaryStore] Update Location with id: \(id).", log: .localData)

			let sql = """
				UPDATE Location
				SET name = ?
				WHERE id = ?
			"""

			do {
				try self.database.executeUpdate(sql, values: [name, id])
			} catch {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(())
		}
	}

	func removeContactPerson(id: Int64) -> Result<Void, SQLiteErrorCode> {
		queue.sync {
			Log.info("[ContactDiaryStore] Remove ContactPerson with id: \(id).", log: .localData)

			let sql = """
				DELETE FROM ContactPerson
				WHERE id = ?;
			"""

			do {
				try self.database.executeUpdate(sql, values: [id])
			} catch {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(())
		}
	}

	func removeLocation(id: Int64) -> Result<Void, SQLiteErrorCode> {
		queue.sync {
			Log.info("[ContactDiaryStore] Remove Location with id: \(id).", log: .localData)

			let sql = """
				DELETE FROM Location
				WHERE id = ?;
			"""

			do {
				try self.database.executeUpdate(sql, values: [id])
			} catch {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(())
		}
	}

	func removeContactPersonEncounter(id: Int64) -> Result<Void, SQLiteErrorCode> {
		queue.sync {
			Log.info("[ContactDiaryStore] Remove ContactPersonEncounter with id: \(id).", log: .localData)

			let sql = """
					DELETE FROM ContactPersonEncounter
					WHERE id = ?;
				"""

			do {
				try self.database.executeUpdate(sql, values: [id])
			} catch {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(())
		}
	}

	func removeLocationVisit(id: Int64) -> Result<Void, SQLiteErrorCode> {
		queue.sync {
			Log.info("[ContactDiaryStore] Remove LocationVisit with id: \(id).", log: .localData)

			let sql = """
					DELETE FROM LocationVisit
					WHERE id = ?;
				"""

			do {
				try self.database.executeUpdate(sql, values: [id])
			} catch {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(())
		}
	}

	func removeAllLocations() -> Result<Void, SQLiteErrorCode> {
		queue.sync {
			Log.info("[ContactDiaryStore] Remove all Locations", log: .localData)

			let sql = """
				DELETE FROM Location
			"""

			guard self.database.executeStatements(sql) else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(())
		}
	}

	func removeAllContactPersons() -> Result<Void, SQLiteErrorCode> {
		queue.sync {
			Log.info("[ContactDiaryStore] Remove all ContactPersons", log: .localData)

			let sql = """
				DELETE FROM ContactPerson
			"""

			guard self.database.executeStatements(sql) else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(())
		}
	}
}
