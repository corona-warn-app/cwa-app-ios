////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import FMDB
import Combine

// swiftlint:disable:next type_body_length
class ContactDiaryStoreV1: DiaryStoring, DiaryProviding {
	static let encriptionKeyKey = "ContactDiaryStoreEncryptionKey"

	// MARK: - Init

	init(
		databaseQueue: FMDatabaseQueue,
		schema: ContactDiaryStoreSchemaV1,
		key: String
	) {
		self.databaseQueue = databaseQueue
		self.key = key

		openAndSetup()

		createSchemaIfNeeded(schema: schema)
		_ = cleanup()

		databaseQueue.inDatabase { database in
			_ = updateDiaryDays(with: database)
		}

		registerToDidFinishLaunchingNotification()
	}

	// MARK: - Protocol DiaryProviding

	var diaryDaysPublisher = CurrentValueSubject<[DiaryDay], Never>([])

	// MARK: - Protocol DiaryStoring

	func cleanup() -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult = .success(())

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Cleanup old entries.", log: .localData)

			guard database.beginExclusiveTransaction() else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			let sqlContactPersonEncounter = """
				DELETE FROM ContactPersonEncounter
				WHERE date < date('now','-\(dataRetentionPeriodInDays) days')
			"""

			let sqlLocationVisit = """
				DELETE FROM LocationVisit
				WHERE date < date('now','-\(dataRetentionPeriodInDays) days')
			"""

			do {
				try database.executeUpdate(sqlContactPersonEncounter, values: nil)
				try database.executeUpdate(sqlLocationVisit, values: nil)
			} catch {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			guard database.commit() else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}
		}

		return result
	}

	func addContactPerson(name: String) -> DiaryStoringResult {
		var result: DiaryStoringResult = .success(0)

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
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			result = .success(database.lastInsertRowId)
		}

		return result
	}

	func addLocation(name: String) -> DiaryStoringResult {
		var result: DiaryStoringResult = .success(0)

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
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			result = .success(database.lastInsertRowId)
		}

		return result
	}

	func addContactPersonEncounter(contactPersonId: Int64, date: String) -> DiaryStoringResult {
		var result: DiaryStoringResult = .success(0)

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
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			result = .success(database.lastInsertRowId)
		}

		return result
	}

	func addLocationVisit(locationId: Int64, date: String) -> DiaryStoringResult {
		var result: DiaryStoringResult = .success(0)

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
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			result = .success(database.lastInsertRowId)
		}

		return result
	}

	func updateContactPerson(id: Int64, name: String) -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult = .success(())

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
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			result = .success(())
		}

		return result
	}

	func updateLocation(id: Int64, name: String) -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult = .success(())

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
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			result = .success(())
		}

		return result
	}

	func removeContactPerson(id: Int64) -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult = .success(())

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Remove ContactPerson with id: \(id).", log: .localData)

			let sql = """
				DELETE FROM ContactPerson
				WHERE id = ?;
			"""

			do {
				try database.executeUpdate(sql, values: [id])
			} catch {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			result = .success(())
		}

		return result
	}

	func removeLocation(id: Int64) -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult = .success(())

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Remove Location with id: \(id).", log: .localData)

			let sql = """
				DELETE FROM Location
				WHERE id = ?;
			"""

			do {
				try database.executeUpdate(sql, values: [id])
			} catch {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			result = .success(())
		}

		return result
	}

	func removeContactPersonEncounter(id: Int64) -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult = .success(())

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Remove ContactPersonEncounter with id: \(id).", log: .localData)

			let sql = """
					DELETE FROM ContactPersonEncounter
					WHERE id = ?;
				"""

			do {
				try database.executeUpdate(sql, values: [id])
			} catch {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			result = .success(())
		}

		return result
	}

	func removeLocationVisit(id: Int64) -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult = .success(())

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Remove LocationVisit with id: \(id).", log: .localData)

			let sql = """
					DELETE FROM LocationVisit
					WHERE id = ?;
				"""

			do {
				try database.executeUpdate(sql, values: [id])
			} catch {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			result = .success(())
		}

		return result
	}

	func removeAllLocations() -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult = .success(())

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Remove all Locations", log: .localData)

			let sql = """
				DELETE FROM Location
			"""

			guard database.executeStatements(sql) else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			result = .success(())
		}

		return result
	}

	func removeAllContactPersons() -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult = .success(())

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Remove all ContactPersons", log: .localData)

			let sql = """
				DELETE FROM ContactPerson
			"""

			guard database.executeStatements(sql) else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			let updateDiaryDaysResult = updateDiaryDays(with: database)
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			result = .success(())
		}

		return result
	}
	
	// MARK: - Private

	private let dataRetentionPeriodInDays = 16
	private let key: String

	private var dateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]
		return dateFormatter
	}()


	private let databaseQueue: FMDatabaseQueue

	private func createSchemaIfNeeded(schema: ContactDiaryStoreSchemaV1) {
		_ = schema.create()
	}

	private func openAndSetup() {
		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Open and setup database.", log: .localData)

			let dbhandle = OpaquePointer(database.sqliteHandle)
			guard CWASQLite.sqlite3_key(dbhandle, key, Int32(key.count)) == SQLITE_OK else {
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
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return
			}
		}
	}

	private func registerToDidFinishLaunchingNotification() {
		NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	@objc
	private func didBecomeActiveNotification(_ notification: Notification) {
		_ = cleanup()
	}

	private func fetchContactPersons(for date: String, in database: FMDatabase) -> Result<[DiaryContactPerson], SQLiteErrorCode> {
		var contactPersons = [DiaryContactPerson]()

		let sql = """
				SELECT ContactPerson.id AS contactPersonId, ContactPerson.name, ContactPersonEncounter.id AS contactPersonEncounterId
				FROM ContactPerson
				LEFT JOIN ContactPersonEncounter
				ON ContactPersonEncounter.contactPersonId = ContactPerson.id
				AND ContactPersonEncounter.date = ?
				ORDER BY ContactPerson.name ASC, contactPersonId ASC
			"""

		do {
			let result = try database.executeQuery(sql, values: [date])

			while result.next() {
				let encounterId = result.longLongInt(forColumn: "contactPersonEncounterId")
				let contactPerson = DiaryContactPerson(
					id: result.longLongInt(forColumn: "contactPersonId"),
					name: result.string(forColumn: "name") ?? "",
					encounterId: encounterId == 0 ? nil : encounterId
				)
				contactPersons.append(contactPerson)
			}
		} catch {
			Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
			return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
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
				ORDER BY Location.name ASC, locationId ASC
			"""

		do {
			let result = try database.executeQuery(sql, values: [date])

			while result.next() {
				let visitId = result.longLongInt(forColumn: "locationVisitId")
				let contactPerson = DiaryLocation(
					id: result.longLongInt(forColumn: "locationId"),
					name: result.string(forColumn: "name") ?? "",
					visitId: visitId == 0 ? nil : visitId
				)
				locations.append(contactPerson)
			}
		} catch {
			Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
			return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
		}

		return .success(locations)
	}

	private func updateDiaryDays(with database: FMDatabase) -> DiaryStoringVoidResult {
		var diaryDays = [DiaryDay]()

		for index in 0...dataRetentionPeriodInDays {
			guard let date = Calendar.current.date(byAdding: .day, value: -index, to: Date()) else {
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
