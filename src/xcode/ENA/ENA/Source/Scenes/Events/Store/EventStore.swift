////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import FMDB

// swiftlint:disable:next type_body_length
class EventStore: EventStoring, EventProviding {

	static let encryptionKeyKey = "EventStoreEncryptionKey"

	// MARK: - Init

	init?(
		databaseQueue: FMDatabaseQueue,
		schema: SchemaProtocol,
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

		registerToDidBecomeActiveNotification()
	}

	// MARK: - Protocol EventStoring

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
			let parameters: [String: Any] = [
				"guid": traceLocation.guid,
				"version": traceLocation.version,
				"type": traceLocation.type,
				"description": traceLocation.description,
				"address": traceLocation.address,
				"startDate": Int(traceLocation.startDate.timeIntervalSince1970),
				"endDate": Int(traceLocation.endDate.timeIntervalSince1970),
				"defaultCheckInLengthInMinutes": traceLocation.defaultCheckInLengthInMinutes,
				"signature": traceLocation.signature
			]
			guard database.executeUpdate(sql, withParameterDictionary: parameters) else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateEventsResult = updateTraceLocations(with: database)
			guard case .success = updateEventsResult else {
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

	func deleteTraceLocation(id: String) -> EventStoring.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Remove TraceLocation with id: \(id).", log: .localData)

			let sql = """
				DELETE FROM TraceLocation
				WHERE id = ?;
			"""

			do {
				try database.executeUpdate(sql, values: [id])
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateEventsResult = updateTraceLocations(with: database)
			guard case .success = updateEventsResult else {
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

	func deleteAllTraceLocations() -> EventStoring.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Remove all TraceLocations.", log: .localData)

			let sql = """
				DELETE * FROM TraceLocation;
			"""

			do {
				try database.executeUpdate(sql, values: [])
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateEventsResult = updateTraceLocations(with: database)
			guard case .success = updateEventsResult else {
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
					SUBSTR(:traceLocationDescription, 1, \(maxTextLength))
					SUBSTR(:traceLocationAddress, 1, \(maxTextLength)),
					:traceLocationStart,
					:traceLocationEnd,
					:traceLocationDefaultCheckInLengthInMinutes,
					:traceLocationSignature,
					:checkinStartDate,
					:targetCheckinEndDate,
					:checkinEndDate,
					:createJournalEntry
				);
			"""
			let parameters: [String: Any] = [
				"traceLocationGUID": checkin.traceLocationGUID,
				"traceLocationVersion": checkin.traceLocationVersion,
				"traceLocationType": checkin.traceLocationType,
				"traceLocationDescription": checkin.traceLocationDescription,
				"traceLocationAddress": checkin.traceLocationAddress,
				"traceLocationStart": Int(checkin.traceLocationStart.timeIntervalSince1970),
				"traceLocationEnd": Int(checkin.traceLocationEnd.timeIntervalSince1970),
				"traceLocationDefaultCheckInLengthInMinutes": checkin.traceLocationDefaultCheckInLengthInMinutes,
				"traceLocationSignature": checkin.traceLocationSignature,
				"checkinStartDate": Int(checkin.checkinStartDate.timeIntervalSince1970),
				"targetCheckinEndDate": Int(checkin.targetCheckinEndDate.timeIntervalSince1970),
				"checkinEndDate": Int(checkin.checkinEndDate.timeIntervalSince1970),
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

	func deleteAllCheckins() -> EventStoring.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Remove all Checkins.", log: .localData)

			let sql = """
				DELETE * FROM Checkin;
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

	func updateCheckin(id: Int, endDate: Date) -> EventStoring.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Update Checkin with id: \(id).", log: .localData)

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
					transmissionRiskLevel
					startIntervalNumber,
					endIntervalNumber
				)
				VALUES (
					:checkinId,
					:traceWarningPackageId,
					:traceLocationGUID,
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

	func deleteTraceTimeIntervalMatch(id: Int) -> EventStoring.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Remove all TraceTimeIntervalMatches.", log: .localData)

			let sql = """
				DELETE * FROM TraceTimeIntervalMatch;
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
	private let schema: SchemaProtocol
	private let migrator: SerialMigratorProtocol
	private let maxTextLength = 150

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

	@discardableResult
	private func cleanup() -> EventStoring.VoidResult {
		var result: EventStoring.VoidResult = .success(())

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Cleanup old entries.", log: .localData)

			// TODO: AFS

//			guard database.beginExclusiveTransaction() else {
//				logLastErrorCode(from: database)
//				result = .failure(dbError(from: database))
//				return
//			}
//
//			let sqlContactPersonEncounter = """
//				DELETE FROM ContactPersonEncounter
//				WHERE date < date('\(todayDateString)','-\(dataRetentionPeriodInDays - 1) days')
//			"""
//
//			let sqlLocationVisit = """
//				DELETE FROM LocationVisit
//				WHERE date < date('\(todayDateString)','-\(dataRetentionPeriodInDays - 1) days')
//			"""
//
//			do {
//				try database.executeUpdate(sqlContactPersonEncounter, values: nil)
//				try database.executeUpdate(sqlLocationVisit, values: nil)
//			} catch {
//				logLastErrorCode(from: database)
//				result = .failure(dbError(from: database))
//				return
//			}
//
//			guard database.commit() else {
//				logLastErrorCode(from: database)
//				result = .failure(dbError(from: database))
//				return
//			}
//
//			let updateDiaryDaysResult = updateDiaryDays(with: database)
//			guard case .success = updateDiaryDaysResult else {
//				logLastErrorCode(from: database)
//				result = .failure(dbError(from: database))
//				return
//			}
		}

		return result
	}

	@discardableResult
	private func updateTraceLocations(with database: FMDatabase) -> EventStore.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
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
					let startDate = Date(timeIntervalSince1970: Double(queryResult.int(forColumn: "startDate")))
					let endDate = Date(timeIntervalSince1970: Double(queryResult.int(forColumn: "endDate")))
					let defaultCheckInLengthInMinutes = Int(queryResult.int(forColumn: "defaultCheckInLengthInMinutes"))

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
	private func updateCheckins(with database: FMDatabase) -> EventStore.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
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
					let traceLocationStart = Date(timeIntervalSince1970: Double(queryResult.int(forColumn: "traceLocationStart")))
					let traceLocationEnd = Date(timeIntervalSince1970: Double(queryResult.int(forColumn: "traceLocationEnd")))
					let traceLocationDefaultCheckInLengthInMinutes = Int(queryResult.int(forColumn: "traceLocationDefaultCheckInLengthInMinutes"))
					let checkinStartDate = Date(timeIntervalSince1970: Double(queryResult.int(forColumn: "checkinStartDate")))
					let checkinEndDate = Date(timeIntervalSince1970: Double(queryResult.int(forColumn: "checkinEndDate")))
					let targetCheckinEndDate = Date(timeIntervalSince1970: Double(queryResult.int(forColumn: "targetCheckinEndDate")))
					let createJournalEntry = queryResult.bool(forColumn: "createJournalEntry")

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
	private func updateTraceTimeIntervalMatches(with database: FMDatabase) -> EventStore.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
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
	private func updateTraceWarningPackageMetadata(with database: FMDatabase) -> EventStore.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
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

	private func logLastErrorCode(from database: FMDatabase) {
		Log.error("[EventStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
	}

	private func dbError(from database: FMDatabase) -> EventStoringError {
		let dbError = SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown
		return .database(dbError)
	}
	// swiftlint:disable:next file_length
}
