////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import FMDB

// swiftlint:disable:next type_body_length
class EventStore: EventStoringProviding {

	static let dataRetentionPeriodInDays = 15
	static let encryptionKeyKey = "EventStoreEncryptionKey"

	// MARK: - Init

	init?(
		databaseQueue: FMDatabaseQueue,
		schema: StoreSchemaProtocol,
		key: String,
		migrator: SerialMigratorProtocol
		) {
		self.databaseQueue = databaseQueue
		self.key = key
		self.schema = schema
		self.migrator = migrator

		guard case .success = openAndSetup() else {
			return nil
		}

		guard case .success = cleanup() else {
			return nil
		}

		guard case .success = updatePublishers() else {
			return nil
		}

		registerToDidBecomeActiveNotification()
	}

	// MARK: - Protocol EventStoring

	@discardableResult
	func createTraceLocation(_ traceLocation: TraceLocation) -> EventStoring.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Add TraceLocation.", log: .localData)

			let sql = """
				INSERT INTO TraceLocation (
					guid,
					version,
					type,
					description,
					address,
					startDate,
					endDate,
					defaultCheckInLengthInMinutes,
					signature
				)
				VALUES (
					:guid,
					:version,
					:type,
					SUBSTR(:description, 1, \(maxTextLength)),
					SUBSTR(:address, 1, \(maxTextLength)),
					:startDate,
					:endDate,
					:defaultCheckInLengthInMinutes,
					:signature
				);
			"""

			var startDateInterval: Int?
			if let startDate = traceLocation.startDate {
				startDateInterval = Int(startDate.timeIntervalSince1970)
			}

			var endDateInterval: Int?
			if let endDate = traceLocation.endDate {
				endDateInterval = Int(endDate.timeIntervalSince1970)
			}

			let parameters: [String: Any] = [
				"guid": traceLocation.guid,
				"version": traceLocation.version,
				"type": traceLocation.type.rawValue,
				"description": traceLocation.description,
				"address": traceLocation.address,
				"startDate": startDateInterval as Any,
				"endDate": endDateInterval as Any,
				"defaultCheckInLengthInMinutes": traceLocation.defaultCheckInLengthInMinutes as Any,
				"signature": traceLocation.signature
			]
			guard database.executeUpdate(sql, withParameterDictionary: parameters) else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateTraceLocationsResult = updateTraceLocations(with: database)
			guard case .success = updateTraceLocationsResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func deleteTraceLocation(guid: String) -> EventStoring.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Remove TraceLocation with id: \(guid).", log: .localData)

			let sql = """
				DELETE FROM TraceLocation
				WHERE guid = ?;
			"""

			do {
				try database.executeUpdate(sql, values: [guid])
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateTraceLocationsResult = updateTraceLocations(with: database)
			guard case .success = updateTraceLocationsResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func deleteAllTraceLocations() -> EventStoring.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Remove all TraceLocations.", log: .localData)

			let sql = """
				DELETE FROM TraceLocation;
			"""

			do {
				try database.executeUpdate(sql, values: [])
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateTraceLocationsResult = updateTraceLocations(with: database)
			guard case .success = updateTraceLocationsResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func createCheckin(_ checkin: Checkin) -> EventStoring.IdResult {
		var result: EventStoring.IdResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Add Checkin.", log: .localData)

			let sql = """
				INSERT INTO Checkin (
					traceLocationGUID,
					traceLocationVersion,
					traceLocationType,
					traceLocationDescription,
					traceLocationAddress,
					traceLocationStartDate,
					traceLocationEndDate,
					traceLocationDefaultCheckInLengthInMinutes,
					traceLocationSignature,
					checkinStartDate,
					targetCheckinEndDate,
					checkinEndDate,
					createJournalEntry
				)
				VALUES (
					:traceLocationGUID,
					:traceLocationVersion,
					:traceLocationType,
					SUBSTR(:traceLocationDescription, 1, \(maxTextLength)),
					SUBSTR(:traceLocationAddress, 1, \(maxTextLength)),
					:traceLocationStartDate,
					:traceLocationEndDate,
					:traceLocationDefaultCheckInLengthInMinutes,
					:traceLocationSignature,
					:checkinStartDate,
					:targetCheckinEndDate,
					:checkinEndDate,
					:createJournalEntry
				);
			"""

			var traceLocationStartDateInterval: Int?
			if let traceLocationStart = checkin.traceLocationStart {
				traceLocationStartDateInterval = Int(traceLocationStart.timeIntervalSince1970)
			}

			var traceLocationEndDateInterval: Int?
			if let traceLocationEnd = checkin.traceLocationEnd {
				traceLocationEndDateInterval = Int(traceLocationEnd.timeIntervalSince1970)
			}

			var checkinEndDateInterval: Int?
			if let checkinEndDate = checkin.checkinEndDate {
				checkinEndDateInterval = Int(checkinEndDate.timeIntervalSince1970)
			}

			var targetCheckinEndDateInterval: Int?
			if let targetCheckinEndDate = checkin.targetCheckinEndDate {
				targetCheckinEndDateInterval = Int(targetCheckinEndDate.timeIntervalSince1970)
			}

			let parameters: [String: Any] = [
				"traceLocationGUID": checkin.traceLocationGUID,
				"traceLocationVersion": checkin.traceLocationVersion,
				"traceLocationType": checkin.traceLocationType.rawValue,
				"traceLocationDescription": checkin.traceLocationDescription,
				"traceLocationAddress": checkin.traceLocationAddress,
				"traceLocationStartDate": traceLocationStartDateInterval as Any,
				"traceLocationEndDate": traceLocationEndDateInterval as Any,
				"traceLocationDefaultCheckInLengthInMinutes": checkin.traceLocationDefaultCheckInLengthInMinutes as Any,
				"traceLocationSignature": checkin.traceLocationSignature,
				"checkinStartDate": Int(checkin.checkinStartDate.timeIntervalSince1970),
				"targetCheckinEndDate": targetCheckinEndDateInterval as Any,
				"checkinEndDate": checkinEndDateInterval as Any,
				"createJournalEntry": checkin.createJournalEntry
			]
			guard database.executeUpdate(sql, withParameterDictionary: parameters) else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateCheckinsResult = updateCheckins(with: database)
			guard case .success = updateCheckinsResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(Int(database.lastInsertRowId))
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func deleteCheckin(id: Int) -> EventStoring.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Remove Checkin with id: \(id).", log: .localData)

			let sql = """
				DELETE FROM Checkin
				WHERE id = ?;
			"""

			do {
				try database.executeUpdate(sql, values: [id])
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateCheckinsResult = updateCheckins(with: database)
			guard case .success = updateCheckinsResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func deleteAllCheckins() -> EventStoring.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Remove all Checkins.", log: .localData)

			let sql = """
				DELETE FROM Checkin;
			"""

			do {
				try database.executeUpdate(sql, values: [])
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateCheckinsResult = updateCheckins(with: database)
			guard case .success = updateCheckinsResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func updateCheckin(id: Int, endDate: Date) -> EventStoring.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Update checkinEndDate to \(endDate) for Checkin with id: \(id).", log: .localData)

			let sql = """
				UPDATE Checkin
				SET checkinEndDate = ?
				WHERE id = ?
			"""

			do {
				try database.executeUpdate(
					sql,
					values: [
						Int(endDate.timeIntervalSince1970),
						id
					]
				)
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateCheckinsResult = updateCheckins(with: database)
			guard case .success = updateCheckinsResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func createTraceTimeIntervalMatch(_ match: TraceTimeIntervalMatch) -> EventStoring.IdResult {
		var result: EventStoring.IdResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Add TraceTimeIntervalMatch.", log: .localData)

			let sql = """
				INSERT INTO TraceTimeIntervalMatch (
					id,
					checkinId,
					traceWarningPackageId,
					traceLocationGUID,
					transmissionRiskLevel,
					startIntervalNumber,
					endIntervalNumber
				)
				VALUES (
					:id,
					:checkinId,
					:traceWarningPackageId,
					:traceLocationGUID,
					:transmissionRiskLevel,
					:startIntervalNumber,
					:endIntervalNumber
				);
			"""
			let parameters: [String: Any] = [
				"id": match.id,
				"checkinId": match.checkinId,
				"traceWarningPackageId": match.traceWarningPackageId,
				"traceLocationGUID": match.traceLocationGUID,
				"transmissionRiskLevel": match.transmissionRiskLevel,
				"startIntervalNumber": match.startIntervalNumber,
				"endIntervalNumber": match.endIntervalNumber
			]
			guard database.executeUpdate(sql, withParameterDictionary: parameters) else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateTraceTimeIntervalMatchesResult = updateTraceTimeIntervalMatches(with: database)
			guard case .success = updateTraceTimeIntervalMatchesResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(Int(database.lastInsertRowId))
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func deleteTraceTimeIntervalMatch(id: Int) -> EventStoring.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Remove all TraceTimeIntervalMatches.", log: .localData)

			let sql = """
				DELETE FROM TraceTimeIntervalMatch;
			"""

			do {
				try database.executeUpdate(sql, values: [])
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateTraceTimeIntervalMatchesResult = updateTraceTimeIntervalMatches(with: database)
			guard case .success = updateTraceTimeIntervalMatchesResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func createTraceWarningPackageMetadata(_ match: TraceWarningPackageMetadata) -> EventStoring.IdResult {
		var result: EventStoring.IdResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Add TraceWarningPackageMetadata.", log: .localData)

			let sql = """
				INSERT INTO TraceWarningPackageMetadata (
					id,
					region,
					eTag
				)
				VALUES (
					:id,
					:region,
					:eTag
				);
			"""
			let parameters: [String: Any] = [
				"id": match.id,
				"region": match.region,
				"eTag": match.eTag
			]
			guard database.executeUpdate(sql, withParameterDictionary: parameters) else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateTraceWarningPackageMetadatasResult = updateTraceWarningPackageMetadata(with: database)
			guard case .success = updateTraceWarningPackageMetadatasResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(Int(database.lastInsertRowId))
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func deleteTraceWarningPackageMetadata(id: Int) -> EventStoring.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Remove TraceWarningPackageMetadata with id: \(id).", log: .localData)

			let sql = """
				DELETE FROM TraceWarningPackageMetadata
				WHERE id = ?;
			"""

			do {
				try database.executeUpdate(sql, values: [id])
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateTraceWarningPackageMetadataResult = updateTraceWarningPackageMetadata(with: database)
			guard case .success = updateTraceWarningPackageMetadataResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	// MARK: - Protocol EventProviding

	var traceLocationsPublisher = CurrentValueSubject<[TraceLocation], Never>([])

	var checkinsPublisher = CurrentValueSubject<[Checkin], Never>([])

	var traceTimeIntervalMatchesPublisher = OpenCombine.CurrentValueSubject<[TraceTimeIntervalMatch], Never>([])

	var traceWarningPackageMetadatasPublisher = OpenCombine.CurrentValueSubject<[TraceWarningPackageMetadata], Never>([])

	// MARK: - Private

	private let databaseQueue: FMDatabaseQueue
	private let key: String
	private let schema: StoreSchemaProtocol
	private let migrator: SerialMigratorProtocol
	private let maxTextLength = 100

	private func openAndSetup() -> EventStoring.VoidResult {
		var errorResult: EventStoring.VoidResult?
		var userVersion: UInt32 = 0

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Open and setup database.", log: .localData)
			let dbHandle = OpaquePointer(database.sqliteHandle)
			guard CWASQLite.sqlite3_key(dbHandle, key, Int32(key.count)) == SQLITE_OK else {
				Log.error("[EventStore] Unable to set Key for encryption.", log: .localData)
				errorResult = .failure(dbError(from: database))
				return
			}

			guard database.open() else {
				Log.error("[EventStore] Database could not be opened", log: .localData)
				errorResult = .failure(dbError(from: database))
				return
			}

			userVersion = database.userVersion

			let sql = """
				PRAGMA locking_mode=EXCLUSIVE;
				PRAGMA auto_vacuum=2;
				PRAGMA journal_mode=WAL;
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

	private func updatePublishers() -> Result<Void, EventStoringError> {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
			let ckeckinsResult = updateCheckins(with: database)
			let traceLocationsResult = updateTraceLocations(with: database)
			let traceWarningPackageMetadata = updateTraceWarningPackageMetadata(with: database)
			let traceTimeIntervalMatchesResult = updateTraceTimeIntervalMatches(with: database)

			guard case .success = ckeckinsResult,
				  case .success = traceLocationsResult,
				  case .success = traceWarningPackageMetadata,
				  case .success = traceTimeIntervalMatchesResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}
		return _result
	}

	@discardableResult
	private func cleanup() -> EventStoring.VoidResult {
		var result: EventStoring.VoidResult = .success(())

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Cleanup old entries.", log: .localData)

			guard database.beginExclusiveTransaction() else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let retentionTimeInterval = Int(Date().timeIntervalSince1970) - EventStore.dataRetentionPeriodInDays * 86400

			let sqlCleanupCheckin = """
				DELETE FROM Checkin
				WHERE checkinEndDate < \(retentionTimeInterval)
				AND checkinEndDate IS NOT NULL;
			"""

			let sqlCleanupTraceLocation = """
				DELETE FROM TraceLocation
				WHERE endDate < \(retentionTimeInterval)
				AND endDate > 0;
			"""

			let sqlCleanupTraceTimeIntervalMatch = """
				DELETE FROM TraceTimeIntervalMatch
				WHERE endIntervalNumber < \(retentionTimeInterval);
			"""

			do {
				try database.executeUpdate(sqlCleanupCheckin, values: nil)
				try database.executeUpdate(sqlCleanupTraceLocation, values: nil)
				try database.executeUpdate(sqlCleanupTraceTimeIntervalMatch, values: nil)
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

			let updateCheckinsResult = updateCheckins(with: database)
			guard case .success = updateCheckinsResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}
		}

		return result
	}

	@discardableResult
	private func updateTraceLocations(with database: FMDatabase) -> EventStore.VoidResult {
		Log.info("[EventStore] Update TraceLocations publisher.", log: .localData)

		let sql = """
				SELECT * FROM TraceLocation;
			"""

		do {
			let queryResult = try database.executeQuery(sql, values: [])
			var events = [TraceLocation]()

			while queryResult.next() {
				guard let guid = queryResult.string(forColumn: "guid"),
					  let description = queryResult.string(forColumn: "description"),
					  let address = queryResult.string(forColumn: "address"),
					  let signature = queryResult.string(forColumn: "signature") else {
					fatalError("[EventStore] SQL column is NOT NULL. Nil was not expected.")
				}

				let version = Int(queryResult.int(forColumn: "version"))
				let type = TraceLocationType(rawValue: Int(queryResult.int(forColumn: "type"))) ?? .type1

				var startDate: Date?
				if let startDateInterval = queryResult.object(forColumn: "startDate") as? Int {
					startDate = Date(timeIntervalSince1970: Double(startDateInterval))
				}

				var endDate: Date?
				if let endDateInterval = queryResult.object(forColumn: "endDate") as? Int {
					endDate = Date(timeIntervalSince1970: Double(endDateInterval))
				}

				var defaultCheckInLengthInMinutes: Int?
				if let _defaultCheckInLengthInMinutes = queryResult.object(forColumn: "defaultCheckInLengthInMinutes") as? Int {
					defaultCheckInLengthInMinutes = _defaultCheckInLengthInMinutes
				}

				let event = TraceLocation(
					guid: guid,
					version: version,
					type: type,
					description: description,
					address: address,
					startDate: startDate,
					endDate: endDate,
					defaultCheckInLengthInMinutes: defaultCheckInLengthInMinutes,
					signature: signature
				)

				events.append(event)
			}

			traceLocationsPublisher.send(events)
		} catch {
			logLastErrorCode(from: database)
			return .failure(dbError(from: database))
		}

		return .success(())
	}

	@discardableResult
	private func updateCheckins(with database: FMDatabase) -> EventStore.VoidResult {
		Log.info("[EventStore] Update checkins publisher.", log: .localData)

		let sql = """
				SELECT * FROM Checkin;
			"""

		do {
			let queryResult = try database.executeQuery(sql, values: [])
			var checkins = [Checkin]()

			while queryResult.next() {
				guard let traceLocationGUID = queryResult.string(forColumn: "traceLocationGUID"),
					  let traceLocationDescription = queryResult.string(forColumn: "traceLocationDescription"),
					  let traceLocationAddress = queryResult.string(forColumn: "traceLocationAddress"),
					  let traceLocationSignature = queryResult.string(forColumn: "traceLocationSignature") else {
					fatalError("[EventStore] SQL column is NOT NULL. Nil was not expected.")
				}

				let id = Int(queryResult.int(forColumn: "id"))
				let traceLocationType = TraceLocationType(rawValue: Int(queryResult.int(forColumn: "traceLocationType"))) ?? .type1
				let traceLocationVersion = Int(queryResult.int(forColumn: "traceLocationVersion"))
				let checkinStartDate = Date(timeIntervalSince1970: Double(queryResult.int(forColumn: "checkinStartDate")))
				let createJournalEntry = queryResult.bool(forColumn: "createJournalEntry")

				var traceLocationStart: Date?
				if let traceLocationStartInterval = queryResult.object(forColumn: "traceLocationStartDate") as? Int {
					traceLocationStart = Date(timeIntervalSince1970: Double(traceLocationStartInterval))
				}

				var traceLocationEnd: Date?
				if let traceLocationEndInterval = queryResult.object(forColumn: "traceLocationEndDate") as? Int {
					traceLocationEnd = Date(timeIntervalSince1970: Double(traceLocationEndInterval))
				}

				var traceLocationDefaultCheckInLengthInMinutes: Int?
				if let _traceLocationDefaultCheckInLengthInMinutes = queryResult.object(forColumn: "traceLocationDefaultCheckInLengthInMinutes") as? Int {
					traceLocationDefaultCheckInLengthInMinutes = _traceLocationDefaultCheckInLengthInMinutes
				}

				var checkinEndDate: Date?
				if let checkinEndDateInterval = queryResult.object(forColumn: "checkinEndDate") as? Int {
					checkinEndDate = Date(timeIntervalSince1970: Double(checkinEndDateInterval))
				}

				var targetCheckinEndDate: Date?
				if let targetCheckinEndDateInterval = queryResult.object(forColumn: "targetCheckinEndDate") as? Int {
					targetCheckinEndDate = Date(timeIntervalSince1970: Double(targetCheckinEndDateInterval))
				}

				let checkin = Checkin(
					id: id,
					traceLocationGUID: traceLocationGUID,
					traceLocationVersion: traceLocationVersion,
					traceLocationType: traceLocationType,
					traceLocationDescription: traceLocationDescription,
					traceLocationAddress: traceLocationAddress,
					traceLocationStart: traceLocationStart,
					traceLocationEnd: traceLocationEnd,
					traceLocationDefaultCheckInLengthInMinutes: traceLocationDefaultCheckInLengthInMinutes,
					traceLocationSignature: traceLocationSignature,
					checkinStartDate: checkinStartDate,
					checkinEndDate: checkinEndDate,
					targetCheckinEndDate: targetCheckinEndDate,
					createJournalEntry: createJournalEntry
				)

				checkins.append(checkin)
			}

			checkinsPublisher.send(checkins)
		} catch {
			logLastErrorCode(from: database)
			return .failure(dbError(from: database))
		}

		return .success(())
	}

	@discardableResult
	private func updateTraceTimeIntervalMatches(with database: FMDatabase) -> EventStore.VoidResult {
		Log.info("[EventStore] Update TraceTimeIntervalMatches publisher.", log: .localData)

		let sql = """
				SELECT * FROM TraceTimeIntervalMatch;
			"""

		do {
			let queryResult = try database.executeQuery(sql, values: [])
			var traceTimeIntervalMatches = [TraceTimeIntervalMatch]()

			while queryResult.next() {
				guard let traceLocationGUID = queryResult.string(forColumn: "traceLocationGUID") else {
					fatalError("[EventStore] SQL column is NOT NULL. Nil was not expected.")
				}

				let id = Int(queryResult.int(forColumn: "id"))
				let checkinId = Int(queryResult.int(forColumn: "checkinId"))
				let traceWarningPackageId = Int(queryResult.int(forColumn: "traceWarningPackageId"))
				let transmissionRiskLevel = Int(queryResult.int(forColumn: "transmissionRiskLevel"))
				let startIntervalNumber = Int(queryResult.int(forColumn: "startIntervalNumber"))
				let endIntervalNumber = Int(queryResult.int(forColumn: "endIntervalNumber"))


				let traceTimeIntervalMatch = TraceTimeIntervalMatch(
					id: id,
					checkinId: checkinId,
					traceWarningPackageId: traceWarningPackageId,
					traceLocationGUID: traceLocationGUID,
					transmissionRiskLevel: transmissionRiskLevel,
					startIntervalNumber: startIntervalNumber,
					endIntervalNumber: endIntervalNumber
				)

				traceTimeIntervalMatches.append(traceTimeIntervalMatch)
			}

			traceTimeIntervalMatchesPublisher.send(traceTimeIntervalMatches)
		} catch {
			logLastErrorCode(from: database)
			return .failure(dbError(from: database))
		}

		return .success(())
	}

	@discardableResult
	private func updateTraceWarningPackageMetadata(with database: FMDatabase) -> EventStore.VoidResult {
		Log.info("[EventStore] Update TraceWarningPackageMetadata publisher.", log: .localData)

		let sql = """
				SELECT * FROM TraceWarningPackageMetadata;
			"""

		do {
			let queryResult = try database.executeQuery(sql, values: [])
			var traceWarningPackageMetadatas = [TraceWarningPackageMetadata]()

			while queryResult.next() {
				guard let region = queryResult.string(forColumn: "region"),
					  let eTag = queryResult.string(forColumn: "eTag") else {
					fatalError("[EventStore] SQL column is NOT NULL. Nil was not expected.")
				}

				let id = Int(queryResult.int(forColumn: "id"))


				let traceWarningPackageMetadata = TraceWarningPackageMetadata(
					id: id,
					region: region,
					eTag: eTag
				)

				traceWarningPackageMetadatas.append(traceWarningPackageMetadata)
			}

			traceWarningPackageMetadatasPublisher.send(traceWarningPackageMetadatas)
		} catch {
			logLastErrorCode(from: database)
			return .failure(dbError(from: database))
		}

		return .success(())
	}

	private func logLastErrorCode(from database: FMDatabase) {
		Log.error("[EventStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
	}

	private func dbError(from database: FMDatabase) -> EventStoringError {
		let dbError = SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown
		return .database(dbError)
	}
	// swiftlint:disable:next file_length
}
