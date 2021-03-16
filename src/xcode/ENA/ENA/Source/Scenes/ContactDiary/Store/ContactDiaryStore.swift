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

private struct ExportEntry {
	let date: Date
	let description: String
}

// swiftlint:disable:next type_body_length
class ContactDiaryStore: DiaryStoring, DiaryProviding {

	static let encryptionKeyKey = "ContactDiaryStoreEncryptionKey"

	// MARK: - Init

	init?(
		databaseQueue: FMDatabaseQueue,
		schema: ContactDiaryStoreSchemaProtocol,
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
	
	// MARK: - Protocol DiaryProviding

	var diaryDaysPublisher = CurrentValueSubject<[DiaryDay], Never>([])

	/** the export is not required to be localized at the moment - tests can check for specific locale text at the moment*/
	func export() -> Result<String, SQLiteErrorCode> {
		var result: Result<String, SQLiteErrorCode>?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] export entries.", log: .localData)
			var contentHeader = "Kontakte der letzten \(userVisiblePeriodInDays) Tage (%@ - %@)\nDie nachfolgende Liste dient dem zuständigen Gesundheitsamt zur Kontaktnachverfolgung gem. § 25 IfSG."

			let endExportDate = dateProvider.today
			guard let startExportDate = Calendar.current.date(byAdding: .day, value: -(userVisiblePeriodInDays - 1), to: endExportDate) else {
				fatalError("Could not create test dates.")
			}

			let startDateString = germanDateFormatter.string(from: startExportDate)
			let endDateString = germanDateFormatter.string(from: endExportDate)
			contentHeader = String(format: contentHeader, startDateString, endDateString)
			contentHeader.append("\n\n")

			var exportEntries = [ExportEntry]()

			let personEncounterSQL = """
					SELECT ContactPerson.id AS entryId,
						ContactPerson.name AS entryName,
						ContactPerson.phoneNumber AS phoneNumber,
						ContactPerson.emailAddress AS emailAddress,
						ContactPersonEncounter.id AS contactPersonEncounterId,
						ContactPersonEncounter.date AS date,
						ContactPersonEncounter.duration AS duration,
						ContactPersonEncounter.maskSituation AS maskSituation,
						ContactPersonEncounter.setting AS setting,
						ContactPersonEncounter.circumstances AS circumstances
					FROM ContactPersonEncounter
					LEFT JOIN ContactPerson
					ON ContactPersonEncounter.contactPersonId = ContactPerson.id
					WHERE ContactPersonEncounter.date > date('\(todayDateString)','-\(userVisiblePeriodInDays) days')
					ORDER BY date DESC, entryName COLLATE NOCASE ASC, entryId ASC
				"""

			let locationVisitSQL = """
					SELECT Location.id AS entryId,
						Location.name AS entryName,
						Location.phoneNumber AS phoneNumber,
						Location.emailAddress AS emailAddress,
						LocationVisit.id AS locationVisitId,
						LocationVisit.date AS date,
						LocationVisit.durationInMinutes AS durationInMinutes,
						LocationVisit.circumstances AS circumstances
					FROM LocationVisit
					LEFT JOIN Location
					ON LocationVisit.locationId = Location.id
					WHERE LocationVisit.date > date('\(todayDateString)','-\(userVisiblePeriodInDays) days')
					ORDER BY date DESC, entryName COLLATE NOCASE ASC, entryId ASC
				"""

			do {
				let personEncounterResult = try database.executeQuery(personEncounterSQL, values: [])
				let locationVisitResult = try database.executeQuery(locationVisitSQL, values: [])

				defer {
					personEncounterResult.close()
					locationVisitResult.close()
				}

				let personEncounterEntries = extractPersonEncounterEntries(from: personEncounterResult)
				exportEntries.append(contentsOf: personEncounterEntries)

				let locationVisitEntries = extractLocationVisitEntries(from: locationVisitResult)
				exportEntries.append(contentsOf: locationVisitEntries)
			} catch {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
			}

			let entriesString = exportEntries.sorted { lfs, rhs -> Bool in
				lfs.date.compare(rhs.date) == .orderedDescending
			}.map {
				$0.description
			}.joined(separator: "\n")

			result = .success(contentHeader + entriesString)
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

	func addContactPerson(
		name: String,
		phoneNumber: String,
		emailAddress: String
	) -> DiaryStoringResult {
		var result: DiaryStoringResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Add ContactPerson.", log: .localData)

			let sql = """
				INSERT INTO ContactPerson (
					name,
					phoneNumber,
					emailAddress
				)
				VALUES (
					SUBSTR(:name, 1, \(maxTextLength)),
					SUBSTR(:phoneNumber, 1, \(maxTextLength)),
					SUBSTR(:emailAddress, 1, \(maxTextLength))
				);
			"""
			let parameters: [String: Any] = [
				"name": name,
				"phoneNumber": phoneNumber,
				"emailAddress": emailAddress
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

	func addLocation(
		name: String,
		phoneNumber: String,
		emailAddress: String
	) -> DiaryStoringResult {
		var result: DiaryStoringResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Add Location.", log: .localData)

			let sql = """
				INSERT INTO Location (
					name,
					phoneNumber,
					emailAddress
				)
				VALUES (
					SUBSTR(:name, 1, \(maxTextLength)),
					SUBSTR(:phoneNumber, 1, \(maxTextLength)),
					SUBSTR(:emailAddress, 1, \(maxTextLength))
				);
			"""

			let parameters: [String: Any] = [
				"name": name,
				"phoneNumber": phoneNumber,
				"emailAddress": emailAddress
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

	func addContactPersonEncounter(
		contactPersonId: Int,
		date: String,
		duration: ContactPersonEncounter.Duration,
		maskSituation: ContactPersonEncounter.MaskSituation,
		setting: ContactPersonEncounter.Setting,
		circumstances: String
	) -> DiaryStoringResult {
		var result: DiaryStoringResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Add ContactPersonEncounter.", log: .localData)

			let sql = """
				INSERT INTO ContactPersonEncounter (
					date,
					contactPersonId,
					duration,
					maskSituation,
					setting,
					circumstances
				)
				VALUES (
					date(:dateString),
					:contactPersonId,
					:duration,
					:maskSituation,
					:setting,
					:circumstances
				);
			"""

			let parameters: [String: Any] = [
				"dateString": date,
				"contactPersonId": contactPersonId,
				"duration": duration.rawValue,
				"maskSituation": maskSituation.rawValue,
				"setting": setting.rawValue,
				"circumstances": circumstances
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

	func addLocationVisit(
		locationId: Int,
		date: String,
		durationInMinutes: Int,
		circumstances: String
	) -> DiaryStoringResult {
		var result: DiaryStoringResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Add LocationVisit.", log: .localData)

			let sql = """
				INSERT INTO LocationVisit (
					date,
					locationId,
					durationInMinutes,
					circumstances
				)
				VALUES (
					date(:dateString),
					:locationId,
					:durationInMinutes,
					:circumstances
				);
			"""

			let parameters: [String: Any] = [
				"dateString": date,
				"locationId": locationId,
				"durationInMinutes": durationInMinutes,
				"circumstances": circumstances
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

	func updateContactPerson(
		id: Int,
		name: String,
		phoneNumber: String,
		emailAddress: String
	) -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Update ContactPerson with id: \(id).", log: .localData)

			let sql = """
				UPDATE ContactPerson
				SET name = SUBSTR(?, 1, \(maxTextLength)), phoneNumber = SUBSTR(?, 1, \(maxTextLength)), emailAddress = SUBSTR(?, 1, \(maxTextLength))
				WHERE id = ?
			"""

			do {
				try database.executeUpdate(sql, values: [name, phoneNumber, emailAddress, id])
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

	func updateLocation(
		id: Int,
		name: String,
		phoneNumber: String,
		emailAddress: String
	) -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Update Location with id: \(id).", log: .localData)

			let sql = """
				UPDATE Location
				SET name = SUBSTR(?, 1, \(maxTextLength)), phoneNumber = SUBSTR(?, 1, \(maxTextLength)), emailAddress = SUBSTR(?, 1, \(maxTextLength))
				WHERE id = ?
			"""

			do {
				try database.executeUpdate(sql, values: [name, phoneNumber, emailAddress, id])
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

	@discardableResult
	func updateContactPersonEncounter(
		id: Int,
		date: String,
		duration: ContactPersonEncounter.Duration,
		maskSituation: ContactPersonEncounter.MaskSituation,
		setting: ContactPersonEncounter.Setting,
		circumstances: String
	) -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Update ContactPersonEncounter with id: \(id).", log: .localData)

			let sql = """
				UPDATE ContactPersonEncounter
				SET date = SUBSTR(?, 1, \(maxTextLength)), duration = ?, maskSituation = ?, setting = ?, circumstances = SUBSTR(?, 1, \(maxTextLength))
				WHERE id = ?
			"""

			do {
				try database.executeUpdate(
					sql,
					values: [
						date,
						duration.rawValue,
						maskSituation.rawValue,
						setting.rawValue,
						circumstances,
						id
					]
				)
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

	@discardableResult
	func updateLocationVisit(
		id: Int,
		date: String,
		durationInMinutes: Int,
		circumstances: String
	) -> DiaryStoringVoidResult {
		var result: DiaryStoringVoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Update LocationVisit with id: \(id).", log: .localData)

			let sql = """
				UPDATE LocationVisit
				SET date = SUBSTR(?, 1, \(maxTextLength)), durationInMinutes = ?, circumstances = SUBSTR(?, 1, \(maxTextLength))
				WHERE id = ?
			"""

			do {
				try database.executeUpdate(
					sql,
					values: [
						date,
						durationInMinutes,
						circumstances,
						id
					]
				)
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

	// MARK: - Private

	private let maxTextLength = 250
	private let key: String
	private let dateProvider: DateProviding
	private let schema: ContactDiaryStoreSchemaProtocol
	private let migrator: SerialMigratorProtocol
	
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

	private let databaseQueue: FMDatabaseQueue

	private func openAndSetup() -> DiaryStoringVoidResult {
		var errorResult: DiaryStoringVoidResult?
		var userVersion: UInt32 = 0
		
		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Open and setup database.", log: .localData)
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

			userVersion = database.userVersion

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
		// then we create the latest schema
		if userVersion == 0 {
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
				SELECT ContactPerson.id AS contactPersonId,
						ContactPerson.name,
						ContactPerson.phoneNumber,
						ContactPerson.emailAddress,
						ContactPersonEncounter.id AS encounterId,
						ContactPersonEncounter.date AS encounterDate,
						ContactPersonEncounter.duration AS encounterDuration,
						ContactPersonEncounter.maskSituation AS encounterMaskSituation,
						ContactPersonEncounter.setting AS encounterSetting,
						ContactPersonEncounter.circumstances AS encounterCircumstances
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
				let encounterId = Int(queryResult.int(forColumn: "encounterId"))
				let encounter: ContactPersonEncounter? = encounterId == 0 ? nil : ContactPersonEncounter(
					id: encounterId,
					date: queryResult.string(forColumn: "encounterDate") ?? "",
					contactPersonId: Int(queryResult.int(forColumn: "contactPersonId")),
					duration: ContactPersonEncounter.Duration(
						rawValue: Int(queryResult.int(forColumn: "encounterDuration"))
					) ?? .none,
					maskSituation: ContactPersonEncounter.MaskSituation(
						rawValue: Int(queryResult.int(forColumn: "encounterMaskSituation"))
					) ?? .none,
					setting: ContactPersonEncounter.Setting(
						rawValue: Int(queryResult.int(forColumn: "encounterSetting"))
					) ?? .none,
					circumstances: queryResult.string(forColumn: "encounterCircumstances") ?? ""
				)

				let contactPerson = DiaryContactPerson(
					id: Int(queryResult.int(forColumn: "contactPersonId")),
					name: queryResult.string(forColumn: "name") ?? "",
					phoneNumber: queryResult.string(forColumn: "phoneNumber") ?? "",
					emailAddress: queryResult.string(forColumn: "emailAddress") ?? "",
					encounter: encounter
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
				SELECT Location.id AS locationId,
						Location.name,
						Location.phoneNumber,
						Location.emailAddress,
						LocationVisit.id AS locationVisitId,
						LocationVisit.date as locationVisitDate,
						LocationVisit.durationInMinutes as locationVisitDuration,
						LocationVisit.circumstances as locationVisitCircumstances
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
				let locationVisitId = Int(queryResult.int(forColumn: "locationVisitId"))
				let locationVisit: LocationVisit? = locationVisitId == 0 ? nil : LocationVisit(
					id: locationVisitId,
					date: queryResult.string(forColumn: "locationVisitDate") ?? "",
					locationId: Int(queryResult.int(forColumn: "locationId")),
					durationInMinutes: Int(queryResult.int(forColumn: "locationVisitDuration")),
					circumstances: queryResult.string(forColumn: "locationVisitCircumstances") ?? ""
				)
				let location = DiaryLocation(
					id: Int(queryResult.int(forColumn: "locationId")),
					name: queryResult.string(forColumn: "name") ?? "",
					phoneNumber: queryResult.string(forColumn: "phoneNumber") ?? "",
					emailAddress: queryResult.string(forColumn: "emailAddress") ?? "",
					visit: locationVisit
				)
				locations.append(location)
			}
		} catch {
			logLastErrorCode(from: database)
			return .failure(dbError(from: database))
		}

		return .success(locations)
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

	private func extractPersonEncounterEntries(from personEncounterResult: FMResultSet) -> [ExportEntry] {
		var exportEntries = [ExportEntry]()

		while personEncounterResult.next() {
			let dateString = personEncounterResult.string(forColumn: "date") ?? ""
			guard let date = dateFormatter.date(from: dateString) else {
				fatalError("Failed to read date from string.")
			}
			let germanDateString = germanDateFormatter.string(from: date)

			let name = personEncounterResult.string(forColumn: "entryName") ?? ""
			let phoneNumber = personEncounterResult.string(forColumn: "phoneNumber") ?? ""
			let emailAddress = personEncounterResult.string(forColumn: "emailAddress") ?? ""
			let duration = ContactPersonEncounter.Duration(rawValue: Int(personEncounterResult.int(forColumn: "duration"))) ?? .none
			let maskSituation = ContactPersonEncounter.MaskSituation(rawValue: Int(personEncounterResult.int(forColumn: "maskSituation"))) ?? .none
			let setting = ContactPersonEncounter.Setting(rawValue: Int(personEncounterResult.int(forColumn: "setting"))) ?? .none
			let circumstances = personEncounterResult.string(forColumn: "circumstances") ?? ""

			let phoneNumberDescription = phoneNumber == "" ? "" : "Tel. \(phoneNumber)"
			let emailAddressDescription = emailAddress == "" ? "" : "eMail \(emailAddress)"
			let durationDescription = duration == .none ? "" : "Kontaktdauer \(duration.germanDescription)"

			var entryComponents = [
				"\(germanDateString) \(name)",
				phoneNumberDescription,
				emailAddressDescription,
				durationDescription,
				maskSituation.germanDescription,
				setting.germanDescription, circumstances
			]

			entryComponents = entryComponents.filter { $0 != "" }

			exportEntries.append(
				ExportEntry(
					date: date,
					description: entryComponents.joined(separator: "; ")
				)
			)
		}

		return exportEntries
	}

	private func extractLocationVisitEntries(from locationVisitResult: FMResultSet) -> [ExportEntry] {
		var exportEntries = [ExportEntry]()

		while locationVisitResult.next() {
			let dateString = locationVisitResult.string(forColumn: "date") ?? ""
			guard let date = dateFormatter.date(from: dateString) else {
				fatalError("Failed to read date from string.")
			}
			let germanDateString = germanDateFormatter.string(from: date)

			let name = locationVisitResult.string(forColumn: "entryName") ?? ""
			let phoneNumber = locationVisitResult.string(forColumn: "phoneNumber") ?? ""
			let emailAddress = locationVisitResult.string(forColumn: "emailAddress") ?? ""
			let circumstances = locationVisitResult.string(forColumn: "circumstances") ?? ""

			let durationInM = locationVisitResult.int(forColumn: "durationInMinutes")
			let dateComponents = DateComponents(minute: Int(durationInM))
			let formatter = DateComponentsFormatter()
			formatter.unitsStyle = .positional
			formatter.zeroFormattingBehavior = .pad
			formatter.allowedUnits = [.hour, .minute]

			let durationDescription = durationInM == 0 ? "" : "Dauer \(formatter.string(from: dateComponents) ?? "") h"
			let phoneNumberDescription = phoneNumber == "" ? "" : "Tel. \(phoneNumber)"
			let emailAddressDescription = emailAddress == "" ? "" : "eMail \(emailAddress)"

			var entryComponents = [
				"\(germanDateString) \(name)",
				phoneNumberDescription,
				emailAddressDescription,
				durationDescription,
				circumstances
			]

			entryComponents = entryComponents.filter { $0 != "" }

			exportEntries.append(
				ExportEntry(
					date: date,
					description: entryComponents.joined(separator: "; ")
				)
			)
		}

		return exportEntries
	}

	private func logLastErrorCode(from database: FMDatabase) {
		Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
	}

	private func dbError(from database: FMDatabase) -> DiaryStoringError {
		let dbError = SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown
		return .database(dbError)
	}
}

// MARK: Creation

extension ContactDiaryStore {

	static func make(url: URL? = nil) -> ContactDiaryStore {
		let storeURL: URL

		if let url = url {
			storeURL = url
		} else {
			storeURL = ContactDiaryStore.storeURL
		}

		Log.info("[ContactDiaryStore] Trying to create contact diary store...", log: .localData)

		if let store = ContactDiaryStore(url: storeURL) {
			Log.info("[ContactDiaryStore] Successfully created contact diary store", log: .localData)
			return store
		}

		Log.info("[ContactDiaryStore] Failed to create contact diary store. Try to rescue it...", log: .localData)

		// The database could not be created – To the rescue!
		// Remove the database file and try to init the store a second time.
		do {
			try FileManager.default.removeItem(at: storeURL)
		} catch {
			Log.error("Could not remove item at \(ContactDiaryStore.storeDirectoryURL)", log: .localData, error: error)
			assertionFailure()
		}

		if let secondTryStore = ContactDiaryStore(url: storeURL) {
			Log.info("[ContactDiaryStore] Successfully rescued contact diary store", log: .localData)
			return secondTryStore
		} else {
			Log.info("[ContactDiaryStore] Failed to rescue contact diary store.", log: .localData)
			fatalError("[ContactDiaryStore] Could not create contact diary store after second try.")
		}
	}

	private static var storeURL: URL {
		storeDirectoryURL
			.appendingPathComponent("ContactDiary")
			.appendingPathExtension("sqlite")
	}

	private static var storeDirectoryURL: URL {
		let fileManager = FileManager.default

		guard let storeDirectoryURL = try? fileManager
			.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
				.appendingPathComponent("ContactDiary") else {
			fatalError("[ContactDiaryStore] Could not create folder.")
		}

		if !fileManager.fileExists(atPath: storeDirectoryURL.path) {
			do {
				try fileManager.createDirectory(atPath: storeDirectoryURL.path, withIntermediateDirectories: true, attributes: nil)
			} catch {
				Log.error("Could not create directory at \(storeDirectoryURL)", log: .localData, error: error)
				assertionFailure()
			}
		}
		return storeDirectoryURL
	}

	private static var encryptionKey: String {
		guard let keychain = try? KeychainHelper() else {
			fatalError("[ContactDiaryStore] Failed to create KeychainHelper for contact diary store.")
		}

		let key: String
		if let keyData = keychain.loadFromKeychain(key: ContactDiaryStore.encryptionKeyKey) {
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
}

extension ContactDiaryStore {
	convenience init?(url: URL) {

		guard let databaseQueue = FMDatabaseQueue(path: url.path) else {
			Log.error("[ContactDiaryStore] Failed to create FMDatabaseQueue.", log: .localData)
			return nil
		}

		let latestDBVersion = 3
		let schema = ContactDiaryStoreSchemaV3(
			databaseQueue: databaseQueue
		)
		
		let migrations: [Migration] = [
			ContactDiaryMigration1To2(databaseQueue: databaseQueue),
			ContactDiaryMigration2To3(databaseQueue: databaseQueue)
		]
		let migrator = SerialDatabaseQueueMigrator(
			queue: databaseQueue,
			latestVersion: latestDBVersion,
			migrations: migrations
		)

		self.init(
			databaseQueue: databaseQueue,
			schema: schema,
			key: ContactDiaryStore.encryptionKey,
			migrator: migrator
		)
	}
}

private extension ContactPersonEncounter.Duration {

	var germanDescription: String {
		   switch self {
		   case .none:
			   return ""
		   case .lessThan15Minutes:
			   return "< 15 Minuten"
		   case .moreThan15Minutes:
			   return "> 15 Minuten"
		   }
	   }
}

private extension ContactPersonEncounter.MaskSituation {

	var germanDescription: String {
		   switch self {
		   case .none:
			   return ""
		   case .withMask:
			   return "mit Maske"
		   case .withoutMask:
			   return "ohne Maske"
		   }
	   }
}

private extension ContactPersonEncounter.Setting {

	var germanDescription: String {
		   switch self {
		   case .none:
			   return ""
		   case .outside:
			   return "im Freien"
		   case .inside:
			   return "im Gebäude"
		   }
	   }
	// swiftlint:disable:next file_length
}
