////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import FMDB
import OpenCombine

// swiftlint:disable:next type_body_length
class ContactDiaryStoreV1: DiaryStoring, DiaryProviding {

	static let encriptionKeyKey = "ContactDiaryStoreEncryptionKey"

	// MARK: - Init

	init?(
		databaseQueue: FMDatabaseQueue,
		schema: ContactDiarySchemaProtocol,
		key: String,
		dateProvider: DateProviding = DateProvider(),
		migrator: SerialMigratorProtocol
		) {
		self.databaseQueue = databaseQueue
		self.key = key
		self.dateProvider = dateProvider
		self.schema = schema
		self.migrator = migrator
		
		guard case .success = openAndSetup() else {
			return nil
		}

		guard case .success = cleanup() else {
			return nil
		}

		var updateDiaryResult: DiaryStoringVoidResult?
		databaseQueue.inDatabase { database in
			updateDiaryResult = updateDiaryDays(with: database)
		}
		guard case .success = updateDiaryResult else {
			return nil
		}
		
		registerToDidBecomeActiveNotification()
	}

	convenience init?() {
		let latestDBVersion = 3
		guard let databaseQueue = FMDatabaseQueue(path: ContactDiaryStore.storeURL.path) else {
			Log.error("[ContactDiaryStore] Failed to create FMDatabaseQueue.", log: .localData)
			return nil
		}

		let schema = ContactDiaryStoreSchema(
			databaseQueue: databaseQueue
		)

		let migrations: [Migration] = [ContactDiaryMigration1To2(databaseQueue: databaseQueue), ContactDiaryMigration2To3(databaseQueue: databaseQueue)]
		let migrator = SerialDatabaseQueueMigrator(queue: databaseQueue, latestVersion: latestDBVersion, migrations: migrations)

		self.init(
			databaseQueue: databaseQueue,
			schema: schema,
			key: ContactDiaryStore.encryptionKey,
			migrator: migrator
		)
	}
	
	// MARK: - Protocol DiaryProviding

	var diaryDaysPublisher = CurrentValueSubject<[DiaryDay], Never>([])

	func export() -> Result<String, SQLiteErrorCode> {
		var result: Result<String, SQLiteErrorCode>?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] export entries.", log: .localData)
			var contentHeader = "Kontakte der letzten 15 Tage (%@ - %@)\nDie nachfolgende Liste dient dem zuständigen Gesundheitsamt zur Kontaktnachverfolgung gem. § 25 IfSG."

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
				defer {
					queryResult.close()
				}

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
			fatalError("[ContactDiaryStore] Result should not be nil.")
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

			let sqlRiskLevelPerDate = """
				DELETE FROM RiskLevelPerDate
				WHERE date < date('\(todayDateString)','-\(dataRetentionPeriodInDays - 1) days')
			"""

			do {
				try database.executeUpdate(sqlContactPersonEncounter, values: nil)
				try database.executeUpdate(sqlLocationVisit, values: nil)
				try database.executeUpdate(sqlRiskLevelPerDate, values: nil)

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

	@discardableResult
	func cleanup(timeout: TimeInterval) -> DiaryStoringVoidResult {
		let group = DispatchGroup()
		var result: DiaryStoringVoidResult?

		group.enter()
		DispatchQueue.global().async {
			result = self.cleanup()
			group.leave()
		}

		guard group.wait(timeout: DispatchTime.now() + timeout) == .success else {
			databaseQueue.interrupt()
			return .failure(.timeout)
		}

		guard let _result = result else {
			fatalError("Nil result from cleanup is not expected.")
		}
		return _result
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
			fatalError("[ContactDiaryStore] Result should not be nil.")
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
			fatalError("[ContactDiaryStore] Result should not be nil.")
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
			fatalError("[ContactDiaryStore] Result should not be nil.")
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
			fatalError("[ContactDiaryStore] Result should not be nil.")
		}

		return _result
	}

	func addRiskLevelPerDate(_ riskLevelsPerDate: [Date: RiskLevel]) -> DiaryStoringGroupResult {
		var result: DiaryStoringGroupResult?

		for (date, riskLevel) in riskLevelsPerDate {
			let dateString = dateFormatter.string(from: date)
			let riskLevelRawValue = riskLevel.rawValue
			databaseQueue.inDatabase { database in
				Log.info("[ContactDiaryStore] Add RiskLevelPerDate.", log: .localData)

				let sql = """
					INSERT INTO RiskLevelPerDate (
						date,
						riskLevel
					)
					VALUES (
						date(:dateString),
						:riskLevel
					);
				"""

				let parameters: [String: Any] = [
					"date": dateString,
					"riskLevel": riskLevelRawValue
				]
				guard database.executeUpdate(sql, withParameterDictionary: parameters) else {
					logLastErrorCode(from: database)
					result?.append(.failure(dbError(from: database)))
					return
				}

				let updateDiaryDaysResult = updateDiaryDays(with: database)
				guard case .success = updateDiaryDaysResult else {
					logLastErrorCode(from: database)
					result?.append(.failure(dbError(from: database)))
					return
				}

				result?.append(.success(Int(database.lastInsertRowId)))
			}
		}

		guard let _result = result else {
			fatalError("[ContactDiaryStore] Result should not be nil.")
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
			fatalError("[ContactDiaryStore] Result should not be nil.")
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
			fatalError("[ContactDiaryStore] Result should not be nil.")
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
			fatalError("[ContactDiaryStore] Result should not be nil.")
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
			fatalError("[ContactDiaryStore] Result should not be nil.")
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
			fatalError("[ContactDiaryStore] Result should not be nil.")
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
			fatalError("[ContactDiaryStore] Result should not be nil.")
		}

		return _result
	}

	func removeAllLocations() -> DiaryStoringVoidResult {
		return removeAllEntries(from: "Location")
	}

	func removeAllContactPersons() -> DiaryStoringVoidResult {
		return removeAllEntries(from: "ContactPerson")
	}

	@discardableResult
	func reset() -> DiaryStoringVoidResult {
		let dropTablesResult = dropTables()
		if case let .failure(error) = dropTablesResult {
			return .failure(error)
		}

		let openAndSetupResult = openAndSetup()
		if case .failure = openAndSetupResult {
			return openAndSetupResult
		}

		var updateDiaryDaysResult: DiaryStoringVoidResult?
		databaseQueue.inDatabase { database in
			updateDiaryDaysResult = updateDiaryDays(with: database)
		}
		if case .failure(let error) = updateDiaryDaysResult {
			return .failure(error)
		}

		return .success(())
	}

	func close() {
		databaseQueue.close()
	}

	// MARK: - Internal

	static var storeURL: URL {
		storeDirectoryURL
			.appendingPathComponent("ContactDiary")
			.appendingPathExtension("sqlite")
	}

	static var storeDirectoryURL: URL {
		let fileManager = FileManager.default

		guard let storeDirectoryURL = try? fileManager
			.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
				.appendingPathComponent("ContactDiary") else {
			fatalError("[ContactDiaryStore] Could not create folder.")
		}

		if !fileManager.fileExists(atPath: storeDirectoryURL.path) {
			try? fileManager.createDirectory(atPath: storeDirectoryURL.path, withIntermediateDirectories: true, attributes: nil)
		}
		return storeDirectoryURL
	}

	static func make() -> ContactDiaryStore {
		Log.info("[ContactDiaryStore] Trying to create contact diary store...", log: .localData)

		if let store = ContactDiaryStore() {
			Log.info("[ContactDiaryStore] Successfully created contact diary store", log: .localData)
			return store
		}

		Log.info("[ContactDiaryStore] Failed to create contact diary store. Try to rescue it...", log: .localData)

		// The database could not be created – To the rescue!
		// Remove the database file and try to init the store a second time.
		try? FileManager.default.removeItem(at: ContactDiaryStore.storeDirectoryURL)

		if let secondTryStore = ContactDiaryStore() {
			Log.info("[ContactDiaryStore] Successfully rescued contact diary store", log: .localData)
			return secondTryStore
		} else {
			Log.info("[ContactDiaryStore] Failed to rescue contact diary store.", log: .localData)
			fatalError("[ContactDiaryStore] Could not create contact diary store after second try.")
		}
	}

	static var encryptionKey: String {
		guard let keychain = try? KeychainHelper() else {
			fatalError("[ContactDiaryStore] Failed to create KeychainHelper for contact diary store.")
		}

		let key: String
		if let keyData = keychain.loadFromKeychain(key: ContactDiaryStore.encriptionKeyKey) {
			key = String(decoding: keyData, as: UTF8.self)
		} else {
			do {
				key = try keychain.generateContactDiaryDatabaseKey()
			} catch {
				fatalError("[ContactDiaryStore] Failed to create key for contact diary store.")
			}
		}

		return key
	}

	// MARK: - Private

	private let dataRetentionPeriodInDays = 17 // Including today.
	private let userVisiblePeriodInDays = 15 // Including today.
	private let key: String
	private let dateProvider: DateProviding
	private let schema: ContactDiarySchemaProtocol
	private let migrator: SerialMigratorProtocol
	private let databaseQueue: FMDatabaseQueue
	
	private var todayDateString: String {
		dateFormatter.string(from: dateProvider.today)
	}

	private var dateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter.contactDiaryFormatter
		return dateFormatter
	}()

	private lazy var germanDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none
		dateFormatter.locale = Locale(identifier: "de_DE")
		return dateFormatter
	}()

	private func openAndSetup() -> DiaryStoringVoidResult {
		var errorResult: DiaryStoringVoidResult?
		var userVersion: UInt32?
		
		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Open and setup database.", log: .localData)
			userVersion = database.userVersion
			let dbHandle = OpaquePointer(database.sqliteHandle)
			guard CWASQLite.sqlite3_key(dbHandle, key, Int32(key.count)) == SQLITE_OK else {
				Log.error("[ContactDiaryStore] Unable to set Key for encryption.", log: .localData)
				errorResult = .failure(dbError(from: database))
				return
			}
			
			guard database.open() else {
				Log.error("[ContactDiaryStore] Database could not be opened", log: .localData)
				errorResult = .failure(dbError(from: database))
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
				errorResult = .failure(dbError(from: database))
				return
			}
		}
		
		if let _errorResult = errorResult {
			return _errorResult
		}
		
		// if version is zero then this means this is a fresh database "i.e no previous app was installed"
		// then we create the latest scheme
		if let version = userVersion, version == 0 {
			let schemaCreateResult = schema.create()
			if case let .failure(error) = schemaCreateResult {
				return .failure(.database(error))
			}
		} else {
			migrate()
		}
		
		return .success(())
	}
	
	private func migrate() {
		do {
			try migrator.migrate()
		} catch {
			_ = MigrationError.general(description: error.localizedDescription)
		}
	}
	
	private func registerToDidBecomeActiveNotification() {
		NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	@objc
	private func didBecomeActiveNotification(_ notification: Notification) {
		cleanup()
	}

	private func fetchContactPersons(for date: String, in database: FMDatabase) -> Result<[DiaryContactPerson], DiaryStoringError> {
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
			let queryResult = try database.executeQuery(sql, values: [date])
			defer {
				queryResult.close()
			}

			while queryResult.next() {
				let encounterId = queryResult.longLongInt(forColumn: "contactPersonEncounterId")
				let contactPerson = DiaryContactPerson(
					id: Int(queryResult.int(forColumn: "contactPersonId")),
					name: queryResult.string(forColumn: "name") ?? "",
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

	private func fetchLocations(for date: String, in database: FMDatabase) -> Result<[DiaryLocation], DiaryStoringError> {
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
			let queryResult = try database.executeQuery(sql, values: [date])
			defer {
				queryResult.close()
			}

			while queryResult.next() {
				let visitId = queryResult.longLongInt(forColumn: "locationVisitId")
				let contactPerson = DiaryLocation(
					id: Int(queryResult.int(forColumn: "locationId")),
					name: queryResult.string(forColumn: "name") ?? "",
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

	private func fetchRiskLevelPerDate(for date: String, in database: FMDatabase) -> Result<RiskLevel?, DiaryStoringError> {
		var riskLevel: RiskLevel?

		let sql = """
				SELECT RiskLevelPerDate.date, MAX(RiskLevelPerDate.riskLevel) AS riskLevel
				FROM RiskLevelPerDate
				WHERE RiskLevelPerDate.date = ?
			"""

		do {
			let queryResult = try database.executeQuery(sql, values: [date])
			defer {
				queryResult.close()
			}

			while queryResult.next() {
				if let fetchedRiskLevel = RiskLevel(rawValue: queryResult.long(forColumn: "riskLevel")) {
					riskLevel = fetchedRiskLevel
				}
			}
		} catch {
			logLastErrorCode(from: database)
			return .failure(dbError(from: database))
		}

		return .success(riskLevel)
	}

	@discardableResult
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

			let riskLevelResult = fetchRiskLevelPerDate(for: dateString, in: database)

			var historyExposure: DiaryDay.HistoryExposure
			switch riskLevelResult {
			case .success(let riskLevel):
				historyExposure = getHistoryExposure(for: riskLevel)
			case .failure(let error):
				return .failure(error)
			}

			let diaryEntries = personDiaryEntries + locationDiaryEntries
			let diaryDay = DiaryDay(dateString: dateString, entries: diaryEntries, historyExposure: historyExposure)

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
			fatalError("[ContactDiaryStore] Result should not be nil.")
		}

		return _result
	}

	private func dropTables() -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult?

		databaseQueue.inDatabase { database in
			let sql = """
					PRAGMA journal_mode=OFF;
					DROP TABLE Location;
					DROP TABLE LocationVisit;
					DROP TABLE ContactPerson;
					DROP TABLE ContactPersonEncounter;
					DROP TABLE RiskLevelPerDate;
					VACUUM;
				"""

			guard database.executeStatements(sql) else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}
			database.userVersion = 0
			result = .success(())
		}

		guard let _result = result else {
			fatalError("[ContactDiaryStore] Result should not be nil.")
		}

		return _result
	}


	private func logLastErrorCode(from database: FMDatabase) {
		Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
	}

	private func dbError(from database: FMDatabase) -> DiaryStoringError {
		let dbError = SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown
		return .database(dbError)
	}

	private func getHistoryExposure(for riskLevel: RiskLevel?) -> DiaryDay.HistoryExposure {
		switch riskLevel {
		case .none:
			return .none
		case .some(let unwrappedRiskLevel):
			switch unwrappedRiskLevel {
			case .high:
				return .encounter(.high)
			case .low:
				return .encounter(.low)
			}
		}
	}
	// swiftlint:disable:next file_length
}
