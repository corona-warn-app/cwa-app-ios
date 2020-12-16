////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import FMDB
import OpenCombine

protocol DateProviding {
	var today: Date { get }
}

struct DateProvider: DateProviding {
	var today: Date {
		Date()
	}
}

// swiftlint:disable:next type_body_length
class ContactDiaryStoreV1: DiaryStoring, DiaryProviding {

	static let encriptionKeyKey = "ContactDiaryStoreEncryptionKey"

	// MARK: - Init

	init(
		databaseQueue: FMDatabaseQueue,
		schema: ContactDiaryStoreSchemaV1,
		key: String,
		dateProvider: DateProviding = DateProvider()
	) {
		self.databaseQueue = databaseQueue
		self.key = key
		self.dateProvider = dateProvider

		openAndSetup()

		createSchemaIfNeeded(schema: schema)
		cleanup()

		databaseQueue.inDatabase { database in
			_ = updateDiaryDays(with: database)
		}

		registerToDidBecomeActiveNotification()
	}

	// MARK: - Protocol DiaryProviding

	var diaryDaysPublisher = CurrentValueSubject<[DiaryDay], Never>([])

	func export() -> Result<String, SQLiteErrorCode> {
		var result: Result<String, SQLiteErrorCode>?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] export entries.", log: .localData)

			var contentHeader = "Kontakte der letzten 14 Tage (%@ - %@)\nDie nachfolgende Liste dient dem zuständigen Gesundheitsamt zur Kontaktnachverfolgung gem. § 25 IfSG."

			let endExportDate = dateProvider.today
			guard let startExportDate = Calendar.current.date(byAdding: .day, value: -(userVisiblePeriodInDays - 1), to: endExportDate) else {
				fatalError("Could not create test dates.")
			}

			let startDateString = germanDateFormatter.string(from: startExportDate)
			let endDateString = germanDateFormatter.string(from: endExportDate)
			contentHeader = String(format: contentHeader, startDateString, endDateString)
			contentHeader.append("\n\n")

			var exportString = contentHeader

			let personEncounterSQL = """
					SELECT 'A' AS sourtGroup, ContactPerson.id AS entryId, ContactPerson.name AS entryName, ContactPersonEncounter.id AS contactPersonEncounterId, ContactPersonEncounter.date
					FROM ContactPersonEncounter
					LEFT JOIN ContactPerson
					ON ContactPersonEncounter.contactPersonId = ContactPerson.id
					WHERE ContactPersonEncounter.date > date('\(todayDateString)','-\(userVisiblePeriodInDays) days')
					UNION
					SELECT 'B' AS sourtGroup, Location.id AS entryId, Location.name AS entryName, LocationVisit.id AS locationVisitId, LocationVisit.date
					FROM LocationVisit
					LEFT JOIN Location
					ON LocationVisit.locationId = Location.id
					WHERE LocationVisit.date > date('\(todayDateString)','-\(userVisiblePeriodInDays) days')
					ORDER BY date DESC, sourtGroup ASC, entryName COLLATE NOCASE ASC, entryId ASC
				"""

			do {
				let queryResult = try database.executeQuery(personEncounterSQL, values: [])

				while queryResult.next() {
					let name = queryResult.string(forColumn: "entryName") ?? ""
					let dateString = queryResult.string(forColumn: "date") ?? ""

					guard let date = dateFormatter.date(from: dateString) else {
						fatalError("Failed to read date from string.")
					}

					let germanDateString = germanDateFormatter.string(from: date)
					exportString.append("\(germanDateString) \(name)\n")
				}
			} catch {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			result = .success(exportString)
		}

		guard let _result = result else {
			fatalError("Result should not be nil.")
		}

		return _result
	}

	// MARK: - Protocol DiaryStoring

	@discardableResult
	func cleanup() -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult = .success(())

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Cleanup old entries.", log: .localData)

			guard database.beginExclusiveTransaction() else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let sqlContactPersonEncounter = """
				DELETE FROM ContactPersonEncounter
				WHERE date < date('\(todayDateString)','-\(dataRetentionPeriodInDays - 1) days')
			"""

			let sqlLocationVisit = """
				DELETE FROM LocationVisit
				WHERE date < date('\(todayDateString)','-\(dataRetentionPeriodInDays - 1) days')
			"""

			do {
				try database.executeUpdate(sqlContactPersonEncounter, values: nil)
				try database.executeUpdate(sqlLocationVisit, values: nil)
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			guard database.commit() else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}
		}

		return result
	}

	func addContactPerson(name: String) -> DiaryStoringResult {
		var result: DiaryStoringResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Add ContactPerson.", log: .localData)

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
			guard database.executeUpdate(sql, withParameterDictionary: parameters) else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(Int(database.lastInsertRowId))
		}

		guard let _result = result else {
			fatalError("Result should not be nil.")
		}

		return _result
	}

	func addLocation(name: String) -> DiaryStoringResult {
		var result: DiaryStoringResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Add Location.", log: .localData)

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
			guard database.executeUpdate(sql, withParameterDictionary: parameters) else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(Int(database.lastInsertRowId))
		}

		guard let _result = result else {
			fatalError("Result should not be nil.")
		}

		return _result
	}

	func addContactPersonEncounter(contactPersonId: Int, date: String) -> DiaryStoringResult {
		var result: DiaryStoringResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Add ContactPersonEncounter.", log: .localData)

			let sql = """
				INSERT INTO ContactPersonEncounter (
					date,
					contactPersonId
				)
				VALUES (
					date(:dateString),
					:contactPersonId
				);
			"""

			let parameters: [String: Any] = [
				"dateString": date,
				"contactPersonId": contactPersonId
			]
			guard database.executeUpdate(sql, withParameterDictionary: parameters) else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(Int(database.lastInsertRowId))
		}

		guard let _result = result else {
			fatalError("Result should not be nil.")
		}

		return _result
	}

	func addLocationVisit(locationId: Int, date: String) -> DiaryStoringResult {
		var result: DiaryStoringResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Add LocationVisit.", log: .localData)

			let sql = """
				INSERT INTO LocationVisit (
					date,
					locationId
				)
				VALUES (
					date(:dateString),
					:locationId
				);
			"""

			let parameters: [String: Any] = [
				"dateString": date,
				"locationId": locationId
			]
			guard database.executeUpdate(sql, withParameterDictionary: parameters) else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(Int(database.lastInsertRowId))
		}

		guard let _result = result else {
			fatalError("Result should not be nil.")
		}

		return _result
	}

	func updateContactPerson(id: Int, name: String) -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Update ContactPerson with id: \(id).", log: .localData)

			let sql = """
				UPDATE ContactPerson
				SET name = SUBSTR(?, 1, 250)
				WHERE id = ?
			"""

			do {
				try database.executeUpdate(sql, values: [name, id])
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("Result should not be nil.")
		}

		return _result
	}

	func updateLocation(id: Int, name: String) -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Update Location with id: \(id).", log: .localData)

			let sql = """
				UPDATE Location
				SET name = SUBSTR(?, 1, 250)
				WHERE id = ?
			"""

			do {
				try database.executeUpdate(sql, values: [name, id])
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("Result should not be nil.")
		}

		return _result
	}

	func removeContactPerson(id: Int) -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Remove ContactPerson with id: \(id).", log: .localData)

			let sql = """
				DELETE FROM ContactPerson
				WHERE id = ?;
			"""

			do {
				try database.executeUpdate(sql, values: [id])
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("Result should not be nil.")
		}

		return _result
	}

	func removeLocation(id: Int) -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Remove Location with id: \(id).", log: .localData)

			let sql = """
				DELETE FROM Location
				WHERE id = ?;
			"""

			do {
				try database.executeUpdate(sql, values: [id])
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("Result should not be nil.")
		}

		return _result
	}

	func removeContactPersonEncounter(id: Int) -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Remove ContactPersonEncounter with id: \(id).", log: .localData)

			let sql = """
					DELETE FROM ContactPersonEncounter
					WHERE id = ?;
				"""

			do {
				try database.executeUpdate(sql, values: [id])
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("Result should not be nil.")
		}

		return _result
	}

	func removeLocationVisit(id: Int) -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Remove LocationVisit with id: \(id).", log: .localData)

			let sql = """
					DELETE FROM LocationVisit
					WHERE id = ?;
				"""

			do {
				try database.executeUpdate(sql, values: [id])
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("Result should not be nil.")
		}

		return _result
	}

	func removeAllLocations() -> DiaryStoringVoidResult {
		return removeAllEntries(from: "Location")
	}

	func removeAllContactPersons() -> DiaryStoringVoidResult {
		return removeAllEntries(from: "ContactPerson")
	}
	
	// MARK: - Private

	private let dataRetentionPeriodInDays = 16 // Including today.
	private let userVisiblePeriodInDays = 14 // Including today.
	private let key: String
	private let dateProvider: DateProviding
	
	private var todayDateString: String {
		dateFormatter.string(from: dateProvider.today)
	}

	private var dateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]
		return dateFormatter
	}()

	private var germanDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .none
		dateFormatter.locale = Locale(identifier: "de_DE")
		return dateFormatter
	}()

	private let databaseQueue: FMDatabaseQueue

	private func createSchemaIfNeeded(schema: ContactDiaryStoreSchemaV1) {
		_ = schema.create()
	}

	private func openAndSetup() {
		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Open and setup database.", log: .localData)

			let dbHandle = OpaquePointer(database.sqliteHandle)
			guard CWASQLite.sqlite3_key(dbHandle, key, Int32(key.count)) == SQLITE_OK else {
				Log.error("[ContactDiaryStore] Unable to set Key for encryption.", log: .localData)
				return
			}

			guard database.open() else {
				Log.error("[ContactDiaryStore] Database could not be opened", log: .localData)
				return
			}

			let sql = """
				PRAGMA locking_mode=EXCLUSIVE;
				PRAGMA auto_vacuum=2;
				PRAGMA journal_mode=WAL;
				PRAGMA foreign_keys=ON;
			"""
			guard database.executeStatements(sql) else {
				logLastErrorCode(from: database)
				return
			}
		}
	}

	private func registerToDidBecomeActiveNotification() {
		NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	@objc
	private func didBecomeActiveNotification(_ notification: Notification) {
		cleanup()
	}

	private func fetchContactPersons(for date: String, in database: FMDatabase) -> Result<[DiaryContactPerson], SQLiteErrorCode> {
		var contactPersons = [DiaryContactPerson]()

		let sql = """
				SELECT ContactPerson.id AS contactPersonId, ContactPerson.name, ContactPersonEncounter.id AS contactPersonEncounterId
				FROM ContactPerson
				LEFT JOIN ContactPersonEncounter
				ON ContactPersonEncounter.contactPersonId = ContactPerson.id
				AND ContactPersonEncounter.date = ?
				ORDER BY ContactPerson.name COLLATE NOCASE ASC, contactPersonId ASC
			"""

		do {
			let result = try database.executeQuery(sql, values: [date])

			while result.next() {
				let encounterId = result.longLongInt(forColumn: "contactPersonEncounterId")
				let contactPerson = DiaryContactPerson(
					id: Int(result.int(forColumn: "contactPersonId")),
					name: result.string(forColumn: "name") ?? "",
					encounterId: encounterId == 0 ? nil : Int(encounterId)
				)
				contactPersons.append(contactPerson)
			}
		} catch {
			logLastErrorCode(from: database)
			return .failure(dbError(from: database))
		}

		return .success(contactPersons)
	}

	private func fetchLocations(for date: String, in database: FMDatabase) -> Result<[DiaryLocation], SQLiteErrorCode> {
		var locations = [DiaryLocation]()

		let sql = """
				SELECT Location.id AS locationId, Location.name, LocationVisit.id AS locationVisitId
				FROM Location
				LEFT JOIN LocationVisit
				ON Location.id = LocationVisit.locationId
				AND LocationVisit.date = ?
				ORDER BY Location.name COLLATE NOCASE ASC, locationId ASC
			"""

		do {
			let result = try database.executeQuery(sql, values: [date])

			while result.next() {
				let visitId = result.longLongInt(forColumn: "locationVisitId")
				let contactPerson = DiaryLocation(
					id: Int(result.int(forColumn: "locationId")),
					name: result.string(forColumn: "name") ?? "",
					visitId: visitId == 0 ? nil : Int(visitId)
				)
				locations.append(contactPerson)
			}
		} catch {
			logLastErrorCode(from: database)
			return .failure(dbError(from: database))
		}

		return .success(locations)
	}

	private func updateDiaryDays(with database: FMDatabase) -> DiaryStoringVoidResult {
		var diaryDays = [DiaryDay]()

		for index in 0..<userVisiblePeriodInDays {
			guard let date = Calendar.current.date(byAdding: .day, value: -index, to: dateProvider.today) else {
				continue
			}
			let dateString = dateFormatter.string(from: date)

			let contactPersonsResult = fetchContactPersons(for: dateString, in: database)

			var personDiaryEntries: [DiaryEntry]
			switch contactPersonsResult {
			case .success(let contactPersons):
				personDiaryEntries = contactPersons.map {
					return DiaryEntry.contactPerson($0)
				}
			case .failure(let error):
				return .failure(error)
			}

			let locationsResult = fetchLocations(for: dateString, in: database)

			var locationDiaryEntries: [DiaryEntry]
			switch locationsResult {
			case .success(let locations):
				locationDiaryEntries = locations.map {
					return DiaryEntry.location($0)
				}
			case .failure(let error):
				return .failure(error)
			}

			let diaryEntries = personDiaryEntries + locationDiaryEntries
			let diaryDay = DiaryDay(dateString: dateString, entries: diaryEntries)
			diaryDays.append(diaryDay)
		}

		diaryDaysPublisher.send(diaryDays)

		return .success(())
	}

	private func removeAllEntries(from tableName: String) -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Remove all entires from \(tableName)", log: .localData)

			let sql = """
				DELETE FROM \(tableName)
			"""

			guard database.executeStatements(sql) else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("Result should not be nil.")
		}

		return _result
	}

	private func logLastErrorCode(from database: FMDatabase) {
		Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
	}

	private func dbError(from database: FMDatabase) -> SQLiteErrorCode {
		return SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown
	}
}

extension ContactDiaryStoreV1 {
	convenience init(fileName: String) {
		let fileManager = FileManager.default

		guard let storeDirectoryURL = try? fileManager
			.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
				.appendingPathComponent("ContactDiary") else {
			fatalError("Could not create folder.")
		}

		if !fileManager.fileExists(atPath: storeDirectoryURL.path) {
			try? fileManager.createDirectory(atPath: storeDirectoryURL.path, withIntermediateDirectories: true, attributes: nil)
		}

		let storeURL = storeDirectoryURL
			.appendingPathComponent(fileName)
			.appendingPathExtension("sqlite")

		guard let keychain = try? KeychainHelper() else {
			fatalError("Failed to create KeychainHelper for contact diary store.")
		}

		let key: String
		if let keyData = keychain.loadFromKeychain(key: ContactDiaryStoreV1.encriptionKeyKey) {
			key = String(decoding: keyData, as: UTF8.self)
		} else {
			do {
				key = try keychain.generateContactDiaryDatabaseKey()
			} catch {
				fatalError("Failed to create key for contact diary store.")
			}
		}

		guard let databaseQueue = FMDatabaseQueue(path: storeURL.path) else {
			fatalError("Failed to create FMDatabaseQueue.")
		}

		let schema = ContactDiaryStoreSchemaV1(
			databaseQueue: databaseQueue
		)

		self.init(
			databaseQueue: databaseQueue,
			schema: schema,
			key: key
		)
	}

	// swiftlint:disable:next file_length
}
