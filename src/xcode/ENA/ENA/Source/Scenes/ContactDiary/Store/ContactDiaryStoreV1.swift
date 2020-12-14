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

	private let dataRetentionPeriodInDays = 16

	private var dateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]
		return dateFormatter
	}()

	var diaryDaysPublisher = CurrentValueSubject<[DiaryDay], Never>([])

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
		_ = cleanup()
		_ = updateDiaryDays()

		registerToDidFinishLaunchingNotification()
	}

	private func createSchemaIfNeeded(schema: ContactDiaryStoreSchemaV1) {
		_ = schema.create()
	}

	private func openAndSetup() {
		queue.sync {
			Log.info("[ContactDiaryStore] Open and setup database.", log: .localData)

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
			guard self.database.executeStatements(sql) else {
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

	private func fetchContactPersons(for date: String) -> Result<[DiaryContactPerson], SQLiteErrorCode> {
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
			let result = try self.database.executeQuery(sql, values: [date])

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

	private func fetchLocations(for date: String) -> Result<[DiaryLocation], SQLiteErrorCode> {
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
			let result = try self.database.executeQuery(sql, values: [date])

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

	private func updateDiaryDays() -> DiaryStoringVoidResult {
		var diaryDays = [DiaryDay]()

		for index in 0...dataRetentionPeriodInDays {
			guard let date = Calendar.utcCalendar.date(byAdding: .day, value: -index, to: Date()) else {
				continue
			}
			let dateString = dateFormatter.string(from: date)

			let contactPersonsResult = fetchContactPersons(for: dateString)

			var personDiaryEntries: [DiaryEntry]
			switch contactPersonsResult {
			case .success(let contactPersons):
				personDiaryEntries = contactPersons.map {
					return DiaryEntry.contactPerson($0)
				}
			case .failure(let error):
				return .failure(error)
			}

			let locationsResult = fetchLocations(for: dateString)

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

	func cleanup() -> DiaryStoringVoidResult {
		Log.info("[ContactDiaryStore] Cleanup old entries.", log: .localData)

		guard database.beginExclusiveTransaction() else {
			Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
			return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
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
			try self.database.executeUpdate(sqlContactPersonEncounter, values: nil)
			try self.database.executeUpdate(sqlLocationVisit, values: nil)
		} catch {
			Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
			return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
		}

		guard database.commit() else {
			Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
			return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
		}

		return .success(())
	}

	func addContactPerson(name: String) -> DiaryStoringResult {
		queue.sync {
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
			guard self.database.executeUpdate(sql, withParameterDictionary: parameters) else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			let updateDiaryDaysResult = updateDiaryDays()
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(database.lastInsertRowId)
		}
	}

	func addLocation(name: String) -> DiaryStoringResult {
		queue.sync {
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
			guard self.database.executeUpdate(sql, withParameterDictionary: parameters) else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			let updateDiaryDaysResult = updateDiaryDays()
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(database.lastInsertRowId)
		}
	}

	func addContactPersonEncounter(contactPersonId: Int64, date: String) -> DiaryStoringResult {
		queue.sync {
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
			guard self.database.executeUpdate(sql, withParameterDictionary: parameters) else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			let updateDiaryDaysResult = updateDiaryDays()
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(database.lastInsertRowId)
		}
	}

	func addLocationVisit(locationId: Int64, date: String) -> DiaryStoringResult {
		queue.sync {
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
			guard self.database.executeUpdate(sql, withParameterDictionary: parameters) else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			let updateDiaryDaysResult = updateDiaryDays()
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(database.lastInsertRowId)
		}
	}

	func updateContactPerson(id: Int64, name: String) -> DiaryStoringVoidResult {
		queue.sync {
			Log.info("[ContactDiaryStore] Update ContactPerson with id: \(id).", log: .localData)

			let sql = """
				UPDATE ContactPerson
				SET name = SUBSTR(?, 1, 250)
				WHERE id = ?
			"""

			do {
				try self.database.executeUpdate(sql, values: [name, id])
			} catch {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			let updateDiaryDaysResult = updateDiaryDays()
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(())
		}
	}

	func updateLocation(id: Int64, name: String) -> DiaryStoringVoidResult {
		queue.sync {
			Log.info("[ContactDiaryStore] Update Location with id: \(id).", log: .localData)

			let sql = """
				UPDATE Location
				SET name = SUBSTR(?, 1, 250)
				WHERE id = ?
			"""

			do {
				try self.database.executeUpdate(sql, values: [name, id])
			} catch {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			let updateDiaryDaysResult = updateDiaryDays()
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(())
		}
	}

	func removeContactPerson(id: Int64) -> DiaryStoringVoidResult {
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

			let updateDiaryDaysResult = updateDiaryDays()
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(())
		}
	}

	func removeLocation(id: Int64) -> DiaryStoringVoidResult {
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

			let updateDiaryDaysResult = updateDiaryDays()
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(())
		}
	}

	func removeContactPersonEncounter(id: Int64) -> DiaryStoringVoidResult {
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

			let updateDiaryDaysResult = updateDiaryDays()
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(())
		}
	}

	func removeLocationVisit(id: Int64) -> DiaryStoringVoidResult {
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

			let updateDiaryDaysResult = updateDiaryDays()
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}
			return .success(())
		}
	}

	func removeAllLocations() -> DiaryStoringVoidResult {
		queue.sync {
			Log.info("[ContactDiaryStore] Remove all Locations", log: .localData)

			let sql = """
				DELETE FROM Location
			"""

			guard self.database.executeStatements(sql) else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			let updateDiaryDaysResult = updateDiaryDays()
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(())
		}
	}

	func removeAllContactPersons() -> DiaryStoringVoidResult {
		queue.sync {
			Log.info("[ContactDiaryStore] Remove all ContactPersons", log: .localData)

			let sql = """
				DELETE FROM ContactPerson
			"""

			guard self.database.executeStatements(sql) else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			let updateDiaryDaysResult = updateDiaryDays()
			guard case .success = updateDiaryDaysResult else {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				return .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			return .success(())
		}
	}
}

extension ContactDiaryStoreV1 {
	convenience init(fileName: String) {
		let fileManager = FileManager()
		guard let documentDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
			fatalError("unable to determine document dir")
		}
		let storeURL = documentDir
				.appendingPathComponent(fileName)
				.appendingPathExtension("sqlite3")

		guard let keychain = try? KeychainHelper() else {
			fatalError("Failed to create KeychainHelper for contact diary store.")
		}

		let key: String
		if let keyData = keychain.loadFromKeychain(key: ContactDiaryStoreV1.encriptionKeyKey) {
			key = String(decoding: keyData, as: UTF8.self)
		} else {
			do {
				key = try keychain.generateDatabaseKey()
			} catch {
				fatalError("Failed to create key for contact diary store.")
			}
		}

		let db = FMDatabase(url: storeURL)
		let queue = DispatchQueue(label: "ContactDiaryStoreSchemaV1TestsQueue")

		let schema = ContactDiaryStoreSchemaV1(
			database: db,
			queue: queue,
			key: key
		)

		self.init(
			database: db,
			queue: queue,
			schema: schema
		)
	}
}
