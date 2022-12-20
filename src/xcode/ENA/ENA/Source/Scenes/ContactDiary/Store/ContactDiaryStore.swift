////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import FMDB
import OpenCombine

enum ContactDiaryStoreError: LocalizedError {
	case sqliteError(SecureSQLStoreError)
	
	var errorDescription: String? {
		switch self {
		case .sqliteError(let error):
			return String(format: AppStrings.ContactDiary.Error.description, error.localizedDescription)
		}
	}
}

protocol DateProviding {
	var today: Date { get }
}

struct DateProvider: DateProviding {
	
	// MARK: - Init
	
	init(date: Date) {
		_date = date
	}
	
	init() { }
	
	// MARK: - Internal
	
	var today: Date {
		return _date ?? Date()
	}
	
	// MARK: - Private
	
	private var _date: Date?
}

private struct ExportEntry {
	let date: Date
	let description: String
}

// swiftlint:disable:next type_body_length
class ContactDiaryStore: DiaryStoring, DiaryProviding, SecureSQLStore {

	static let encryptionKeyKey = "ContactDiaryStoreEncryptionKey"

	// MARK: - Init

	init(
		databaseQueue: FMDatabaseQueue,
		schema: StoreSchemaProtocol,
		key: String,
		dateProvider: DateProviding = DateProvider(),
		migrator: SerialMigratorProtocol
		) {
		self.databaseQueue = databaseQueue
		self.key = key
		self.dateProvider = dateProvider
		self.schema = schema
		self.migrator = migrator

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
			
			let coronaTestsSQL = """
					SELECT CoronaTest.id AS entryID,
						CoronaTest.date AS date,
						CoronaTest.testType AS testType,
						CoronaTest.testResult AS testResult
					FROM CoronaTest
					WHERE CoronaTest.date > date('\(todayDateString)','-\(userVisiblePeriodInDays) days')
					ORDER BY date DESC, testType COLLATE NOCASE ASC, entryId ASC
				"""

			do {
				let personEncounterResult = try database.executeQuery(personEncounterSQL, values: [])
				let locationVisitResult = try database.executeQuery(locationVisitSQL, values: [])
				let coronaTestsResult = try database.executeQuery(coronaTestsSQL, values: [])

				defer {
					personEncounterResult.close()
					locationVisitResult.close()
					coronaTestsResult.close()
				}

				let personEncounterEntries = extractPersonEncounterEntries(from: personEncounterResult)
				exportEntries.append(contentsOf: personEncounterEntries)

				let locationVisitEntries = extractLocationVisitEntries(from: locationVisitResult)
				exportEntries.append(contentsOf: locationVisitEntries)
				
				let coronaTestEntries = extractCoronaTestEntries(from: coronaTestsResult)
				exportEntries.append(contentsOf: coronaTestEntries)
			} catch {
				Log.error("[ContactDiaryStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()))
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

	// MARK: - Protocol SecureSQLStore

	let databaseQueue: FMDatabaseQueue
	var key: String
	let schema: StoreSchemaProtocol
	let migrator: SerialMigratorProtocol
	let logIdentifier = "ContactDiaryStore"
	let sqlSettings = """
				PRAGMA locking_mode=EXCLUSIVE;
				PRAGMA auto_vacuum=2;
				PRAGMA journal_mode=WAL;
				PRAGMA foreign_keys=ON;
			"""

	// MARK: - Protocol DiaryStoring

	@discardableResult
	func cleanup() -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult = .success(())

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

			let sqlCoronaTests = """
				DELETE FROM CoronaTest
				WHERE date < date('\(todayDateString)','-\(dataRetentionPeriodInDays - 1) days')
			"""
			
			let sqlCoronaSubmissions = """
				DELETE FROM Submission
				WHERE date < date('\(todayDateString)','-\(dataRetentionPeriodInDays - 1) days')
			"""

			do {
				try database.executeUpdate(sqlContactPersonEncounter, values: nil)
				try database.executeUpdate(sqlLocationVisit, values: nil)
				if database.userVersion >= 5 {
					try database.executeUpdate(sqlCoronaTests, values: nil)
				}
				if database.userVersion >= 6 {
					try database.executeUpdate(sqlCoronaSubmissions, values: nil)
				}
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
	func cleanup(timeout: TimeInterval) -> SecureSQLStore.VoidResult {
		let group = DispatchGroup()
		var result: SecureSQLStore.VoidResult?

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
	) -> SecureSQLStore.IdResult {
		var result: SecureSQLStore.IdResult?

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
		emailAddress: String,
		traceLocationId: Data?
	) -> SecureSQLStore.IdResult {
		var result: SecureSQLStore.IdResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Add Location.", log: .localData)

			let sql = """
				INSERT INTO Location (
					name,
					phoneNumber,
					emailAddress,
					traceLocationId
				)
				VALUES (
					SUBSTR(:name, 1, \(maxTextLength)),
					SUBSTR(:phoneNumber, 1, \(maxTextLength)),
					SUBSTR(:emailAddress, 1, \(maxTextLength)),
					:traceLocationId
				);
			"""

			let parameters: [String: Any] = [
				"name": name,
				"phoneNumber": phoneNumber,
				"emailAddress": emailAddress,
				"traceLocationId": traceLocationId as Any
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
	) -> SecureSQLStore.IdResult {
		var result: SecureSQLStore.IdResult?

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
		circumstances: String,
		checkinId: Int?
	) -> SecureSQLStore.IdResult {
		var result: SecureSQLStore.IdResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Add LocationVisit.", log: .localData)

			let sql = """
				INSERT INTO LocationVisit (
					date,
					locationId,
					durationInMinutes,
					circumstances,
					checkinId
				)
				VALUES (
					date(:dateString),
					:locationId,
					:durationInMinutes,
					:circumstances,
					:checkinId
				);
			"""

			let parameters: [String: Any] = [
				"dateString": date,
				"locationId": locationId,
				"durationInMinutes": durationInMinutes,
				"circumstances": circumstances,
				"checkinId": checkinId as Any
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

	func addCoronaTest(
		testDate: String,
		testType: Int,
		testResult: Int
	) -> SecureSQLStore.IdResult {
		var result: SecureSQLStore.IdResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Add CoronaTest.", log: .localData)

			let sql = """
				INSERT INTO CoronaTest (
					date,
					testType,
					testResult
				)
				VALUES (
					:date,
					:testType,
					:testResult
				);
			"""
			let parameters: [String: Any] = [
				"date": testDate,
				"testType": testType,
				"testResult": testResult
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
	
	func addSubmission(date: String) -> SecureSQLStore.IdResult {
		var result: SecureSQLStore.IdResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Add Submission.", log: .localData)

			let sql = """
				INSERT INTO Submission (
					date
				)
				VALUES (
					:date
				);
			"""
			let parameters: [String: Any] = ["date": date]
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
	) -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

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
	) -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

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
	) -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

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
	) -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

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

	func removeContactPerson(id: Int) -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

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

	func removeLocation(id: Int) -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

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

	func removeContactPersonEncounter(id: Int) -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

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

	func removeLocationVisit(id: Int) -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

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

	func removeAllLocations() -> SecureSQLStore.VoidResult {
		return removeAllEntries(from: "Location")
	}

	func removeAllContactPersons() -> SecureSQLStore.VoidResult {
		return removeAllEntries(from: "ContactPerson")
	}

	func removeAllCoronaTests() -> Result<Void, SecureSQLStoreError> {
		return removeAllEntries(from: "CoronaTest")
	}
	
	func removeAllSubmissions() -> Result<Void, SecureSQLStoreError> {
		return removeAllEntries(from: "Submission")
	}

	@discardableResult
	func reset() -> SecureSQLStore.VoidResult {
		let dropTablesResult = dropTables()
		if case let .failure(error) = dropTablesResult {
			return .failure(error)
		}
		
		if let newKey = try? ContactDiaryStore.resetEncryptionKey() {
			key = newKey
		}

		let openAndSetupResult = openAndSetup()
		if case .failure = openAndSetupResult {
			return openAndSetupResult
		}

		var updateDiaryDaysResult: SecureSQLStore.VoidResult?
		databaseQueue.inDatabase { database in
			updateDiaryDaysResult = updateDiaryDays(with: database)
		}
		if case .failure(let error) = updateDiaryDaysResult {
			return .failure(error)
		}

		return .success(())
	}

	// MARK: - Private

	private let maxTextLength = 250
	private let dateProvider: DateProviding

	private var todayDateString: String {
		dateFormatter.string(from: dateProvider.today)
	}

	private var dateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter.justLocalDateFormatter
		return dateFormatter
	}()

	private lazy var germanDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none
		dateFormatter.locale = Locale(identifier: "de_DE")
		return dateFormatter
	}()

	func registerToDidBecomeActiveNotification() {
		NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	@objc
	private func didBecomeActiveNotification(_ notification: Notification) {
		cleanup()
	}

	private func fetchContactPersons(for date: String, in database: FMDatabase) -> Result<[DiaryContactPerson], SecureSQLStoreError> {
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

	private func fetchLocations(for date: String, in database: FMDatabase) -> Result<[DiaryLocation], SecureSQLStoreError> {
		var locations = [DiaryLocation]()

		let sql = """
				SELECT Location.id AS locationId,
						Location.name,
						Location.phoneNumber,
						Location.emailAddress,
						Location.traceLocationId,
						LocationVisit.id AS locationVisitId,
						LocationVisit.date as locationVisitDate,
						LocationVisit.durationInMinutes as locationVisitDuration,
						LocationVisit.circumstances as locationVisitCircumstances,
						LocationVisit.checkinId as checkinId
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

				var checkinId: Int?
				if let _checkinId = queryResult.object(forColumn: "checkinId") as? Int {
					checkinId = _checkinId
				}

				let locationVisit: LocationVisit? = locationVisitId == 0 ? nil : LocationVisit(
					id: locationVisitId,
					date: queryResult.string(forColumn: "locationVisitDate") ?? "",
					locationId: Int(queryResult.int(forColumn: "locationId")),
					durationInMinutes: Int(queryResult.int(forColumn: "locationVisitDuration")),
					circumstances: queryResult.string(forColumn: "locationVisitCircumstances") ?? "",
					checkinId: checkinId
				)

				let location = DiaryLocation(
					id: Int(queryResult.int(forColumn: "locationId")),
					name: queryResult.string(forColumn: "name") ?? "",
					phoneNumber: queryResult.string(forColumn: "phoneNumber") ?? "",
					emailAddress: queryResult.string(forColumn: "emailAddress") ?? "",
					traceLocationId: queryResult.data(forColumn: "traceLocationId"),
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

	private func fetchCoronaTests(for date: String, in database: FMDatabase) -> Result<[DiaryDayTest], SecureSQLStoreError> {
		// database schema v5 is required here, if not available return success with empty data
		guard database.userVersion >= 5 else {
			return .success([])
		}

		var diaryDayTests = [DiaryDayTest]()

		let sql = """
				SELECT id,
					date,
					testType,
					testResult
				FROM CoronaTest
				WHERE date = ?
				ORDER BY id ASC
			"""

		do {
			let queryResult = try database.executeQuery(sql, values: [date])
			defer {
				queryResult.close()
			}

			while queryResult.next() {
				let coronaTestID = Int(queryResult.int(forColumn: "id"))
				let testDate = queryResult.string(forColumn: "date") ?? ""
				let testType = Int(queryResult.int(forColumn: "testType"))
				let testResult = Int(queryResult.int(forColumn: "testResult"))
				if let diaryDayTest = DiaryDayTest(id: coronaTestID, date: testDate, type: testType, result: testResult) {
					diaryDayTests.append(diaryDayTest)
				} else {
					Log.error("Failed to create DiaryDayTest from database data")
				}
			}
		} catch {
			logLastErrorCode(from: database)
			return .failure(dbError(from: database))
		}

		return .success(diaryDayTests)
	}
	
	private func fetchSubmissions(for date: String, in database: FMDatabase) -> Result<[DiaryDaySubmission], SecureSQLStoreError> {
		// database schema v6 is required here, if not available return success with empty data
		guard database.userVersion >= 6 else {
			return .success([])
		}

		var diaryDaySubmissions = [DiaryDaySubmission]()

		let sql = """
				SELECT id,
					   date
				FROM Submission
				WHERE date = ?
				ORDER BY id ASC
			"""

		do {
			let queryResult = try database.executeQuery(sql, values: [date])
			defer {
				queryResult.close()
			}

			while queryResult.next() {
				let submissionID = Int(queryResult.int(forColumn: "id"))
				let submissionDate = queryResult.string(forColumn: "date") ?? ""
				
				let diaryDaySubmission = DiaryDaySubmission(id: submissionID, date: submissionDate)
				diaryDaySubmissions.append(diaryDaySubmission)
			}
		} catch {
			logLastErrorCode(from: database)
			return .failure(dbError(from: database))
		}

		return .success(diaryDaySubmissions)
	}
	// MARK: - update

	@discardableResult
	func updateDiaryDays(with database: FMDatabase) -> SecureSQLStore.VoidResult {
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
				let sortedContactPersons = contactPersons.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
				personDiaryEntries = sortedContactPersons.map {
					return DiaryEntry.contactPerson($0)
				}
			case .failure(let error):
				return .failure(error)
			}

			let locationsResult = fetchLocations(for: dateString, in: database)

			var locationDiaryEntries: [DiaryEntry]
			switch locationsResult {
			case .success(let locations):
				let arrangedLocations = locations.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
				locationDiaryEntries = arrangedLocations.map {
					return DiaryEntry.location($0)
				}
			case .failure(let error):
				return .failure(error)
			}

			let diaryCoronaTests = fetchCoronaTests(for: dateString, in: database)
			var diaryDayTests: [DiaryDayTest]
			switch diaryCoronaTests {
			case .success(let coronaTests):
				diaryDayTests = coronaTests
			case .failure(let error):
				return .failure(error)
			}
			
			let diaryExposureSubmissions = fetchSubmissions(for: dateString, in: database)
			var diaryDaySubmissions: [DiaryDaySubmission]
			switch diaryExposureSubmissions {
			case .success(let submissions):
				diaryDaySubmissions = submissions
			case .failure(let error):
				return .failure(error)
			}

			let diaryEntries = personDiaryEntries + locationDiaryEntries
			let diaryDay = DiaryDay(
				dateString: dateString,
				entries: diaryEntries,
				tests: diaryDayTests,
				submissions: diaryDaySubmissions
			)
			diaryDays.append(diaryDay)
		}

		diaryDaysPublisher.send(diaryDays)

		return .success(())
	}

	private func removeAllEntries(from tableName: String) -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[ContactDiaryStore] Remove all entries from \(tableName)", log: .localData)

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

	private func dropTables() -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

		databaseQueue.inDatabase { database in
			let sql = """
					PRAGMA journal_mode=OFF;
					DROP TABLE Location;
					DROP TABLE LocationVisit;
					DROP TABLE ContactPerson;
					DROP TABLE ContactPersonEncounter;
					DROP TABLE CoronaTest;
					DROP TABLE Submission;
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
	
	private func extractCoronaTestEntries(from coronaTestsResult: FMResultSet) -> [ExportEntry] {
		var exportEntries = [ExportEntry]()

		while coronaTestsResult.next() {
			let dateString = coronaTestsResult.string(forColumn: "date") ?? ""
			guard let date = dateFormatter.date(from: dateString) else {
				fatalError("Failed to read date from string.")
			}
			let germanDateString = germanDateFormatter.string(from: date)
			
			let testType = coronaTestsResult.string(forColumn: "testType") ?? ""
			let testResult = coronaTestsResult.string(forColumn: "testResult") ?? ""
			
			let testTypeName = testType == String(CoronaTestType.pcr.rawValue) ? AppStrings.ContactDiary.Overview.Tests.pcrRegistered : AppStrings.ContactDiary.Overview.Tests.antigenDone
			
			let testResultName = testResult == String(TestResult.negative.rawValue) ? AppStrings.ContactDiary.Overview.Tests.negativeResult : AppStrings.ContactDiary.Overview.Tests.positiveResult
			
			let testTypeDescription = testTypeName == "" ? "" : "\(testTypeName)"
			let testResultDescription = testResultName == "" ? "" : "\(testResultName)"

			var entryComponents = [
				"\(germanDateString) \(testTypeDescription)",
				testResultDescription
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
}

private extension ContactPersonEncounter.Duration {

	var germanDescription: String {
		   switch self {
		   case .none:
			   return ""
		   case .lessThan10Minutes:
			   return "unter 10 Minuten"
		   case .moreThan10Minutes:
			   return "über 10 Minuten"
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
