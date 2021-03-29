////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import FMDB

// swiftlint:disable:next type_body_length
class EventStore: SecureSQLStore, EventStoringProviding {

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

	// MARK: - Protocol SecureSQLStore

	let databaseQueue: FMDatabaseQueue
	let key: String
	let schema: StoreSchemaProtocol
	let migrator: SerialMigratorProtocol
	let logIdentifier = "EventStore"
	let sqlSettings = """
				PRAGMA locking_mode=EXCLUSIVE;
				PRAGMA auto_vacuum=2;
				PRAGMA journal_mode=WAL;
			"""

	// MARK: - Protocol EventStoring

	@discardableResult
	func createTraceLocation(_ traceLocation: TraceLocation) -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Add TraceLocation.", log: .localData)

			let createTraceLocationQuery = CreateTraceLocationQuery(
				traceLocation: traceLocation,
				maxTextLength: maxTextLength
			)
			result = executeTraceLocationQuery(createTraceLocationQuery, in: database)
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func updateTraceLocation(_ traceLocation: TraceLocation) -> Result<Void, SecureSQLStoreError> {

		var result: SecureSQLStore.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Update TraceLocation.", log: .localData)

			let updateTraceLocationQuery = UpdateTraceLocationQuery(traceLocation: traceLocation, maxTextLength: maxTextLength)
			result = executeTraceLocationQuery(updateTraceLocationQuery, in: database)
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func deleteTraceLocation(id: Data) -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Remove TraceLocation.", log: .localData)

			let deleteTraceLocationQuery = DeleteTraceLocationQuery(id: id)
			result = executeTraceLocationQuery(deleteTraceLocationQuery, in: database)
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func deleteAllTraceLocations() -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Remove all TraceLocations.", log: .localData)

			let deleteAllTraceLocationsQuery = DeleteAllTraceLocationsQuery()
			result = executeTraceLocationQuery(deleteAllTraceLocationsQuery, in: database)
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func createCheckin(_ checkin: Checkin) -> SecureSQLStore.IdResult {
		var result: SecureSQLStore.IdResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Create Checkin.", log: .localData)

			let createCheckinQuery = CreateCheckinQuery(checkin: checkin, maxTextLength: maxTextLength)
			let queryResult = executeCheckinQuery(createCheckinQuery, in: database)

			switch queryResult {
			case .success:
				result = .success(Int(database.lastInsertRowId))
			case .failure(let error):
				result = .failure(error)
			}
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func updateCheckin(_ checkin: Checkin) -> Result<Void, SecureSQLStoreError> {
		var result: SecureSQLStore.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Update Checkin with id: \(checkin.id).", log: .localData)

			let updateCheckinQuery = UpdateCheckinQuery(checkin: checkin, maxTextLength: maxTextLength)
			result = executeCheckinQuery(updateCheckinQuery, in: database)
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func deleteCheckin(id: Int) -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Remove Checkin with id: \(id).", log: .localData)

			let deleteCheckinQuery = DeleteCheckinQuery(id: id)
			result = executeCheckinQuery(deleteCheckinQuery, in: database)
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func deleteAllCheckins() -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Remove all Checkins.", log: .localData)

			let deleteCheckinsQuery = DeleteCheckinsQuery()
			result = executeCheckinQuery(deleteCheckinsQuery, in: database)
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func createTraceTimeIntervalMatch(_ match: TraceTimeIntervalMatch) -> SecureSQLStore.IdResult {
		var result: SecureSQLStore.IdResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Add TraceTimeIntervalMatch.", log: .localData)

			let query = CreateTraceTimeIntervalMatchQuery(match: match)
			let queryResult = executeTraceTimeIntervalMatchQuery(query, in: database)

			switch queryResult {
			case .success:
				result = .success(Int(database.lastInsertRowId))
			case .failure(let error):
				result = .failure(error)
			}
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func deleteTraceTimeIntervalMatch(id: Int) -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Remove all TraceTimeIntervalMatches.", log: .localData)

			let query = DeleteTraceTimeIntervalMatchQuery(id: id)
			result = executeTraceTimeIntervalMatchQuery(query, in: database)
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func createTraceWarningPackageMetadata(_ metadata: TraceWarningPackageMetadata) -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Add TraceWarningPackageMetadata.", log: .localData)

			let query = CreateTraceWarningPackageMetadataQuery(metadata: metadata)
			result = executeTraceWarningPackageMetadataQuery(query, in: database)
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func deleteTraceWarningPackageMetadata(id: Int) -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Remove TraceWarningPackageMetadata with id: \(id).", log: .localData)

			let query = DeleteTraceWarningPackageMetadataQuery(id: id)
			result = executeTraceWarningPackageMetadataQuery(query, in: database)
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func deleteAllTraceWarningPackageMetadata() -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Remove all TraceWarningPackageMetadata.", log: .localData)

			let query = DeleteAllTraceWarningPackageMetadataQuery()
			result = executeTraceWarningPackageMetadataQuery(query, in: database)
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	func cleanup() -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult = .success(())

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

	@discardableResult
	func reset() -> SecureSQLStore.VoidResult {
		let dropTablesResult = dropTables()
		if case let .failure(error) = dropTablesResult {
			return .failure(error)
		}

		let openAndSetupResult = openAndSetup()
		if case .failure = openAndSetupResult {
			return openAndSetupResult
		}

		let updatePublishersResult = updatePublishers()
		if case .failure(let error) = updatePublishersResult {
			return .failure(error)
		}

		return .success(())
	}

	// MARK: - Protocol EventProviding

	private(set) var traceLocationsPublisher = CurrentValueSubject<[TraceLocation], Never>([])
	private(set) var checkinsPublisher = CurrentValueSubject<[Checkin], Never>([])
	private(set) var traceTimeIntervalMatchesPublisher = OpenCombine.CurrentValueSubject<[TraceTimeIntervalMatch], Never>([])
	private(set) var traceWarningPackageMetadatasPublisher = OpenCombine.CurrentValueSubject<[TraceWarningPackageMetadata], Never>([])

	// MARK: - Private

	private let maxTextLength = 100

	private func registerToDidBecomeActiveNotification() {
		NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	@objc
	private func didBecomeActiveNotification(_ notification: Notification) {
		cleanup()
	}

	private func updatePublishers() -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

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
	private func updateTraceLocations(with database: FMDatabase) -> SecureSQLStore.VoidResult {
		Log.info("[EventStore] Update TraceLocations publisher.", log: .localData)

		let sql = """
				SELECT * FROM TraceLocation;
			"""

		do {
			let queryResult = try database.executeQuery(sql, values: [])
			var traceLocations = [TraceLocation]()

			while queryResult.next() {
				guard let description = queryResult.string(forColumn: "description"),
					  let address = queryResult.string(forColumn: "address") else {
					fatalError("[EventStore] SQL column is NOT NULL. Nil was not expected.")
				}

				// Persisting empty Data to a BLOB field leads to retrieving nil when reading it.
				// Because of that, we map nil to empty Data. Because "id", "cryptographicSeed" and "cnMasterPublicKey" are defined as NOT NULL, there should never be nil stored.
				// For more information about that problem, please see the issue opened here: https://github.com/ccgus/fmdb/issues/73
				let id = queryResult.data(forColumn: "id") ?? Data()
				let cryptographicSeed = queryResult.data(forColumn: "cryptographicSeed") ?? Data()
				let cnMainPublicKey = queryResult.data(forColumn: "cnMainPublicKey") ?? Data()

				let version = Int(queryResult.int(forColumn: "version"))
				let type = TraceLocationType(rawValue: Int(queryResult.int(forColumn: "type"))) ?? .locationTypeUnspecified

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

				let traceLocation = TraceLocation(
					id: id,
					version: version,
					type: type,
					description: description,
					address: address,
					startDate: startDate,
					endDate: endDate,
					defaultCheckInLengthInMinutes: defaultCheckInLengthInMinutes,
					cryptographicSeed: cryptographicSeed,
					cnMainPublicKey: cnMainPublicKey
				)

				traceLocations.append(traceLocation)
			}

			traceLocationsPublisher.send(traceLocations)
		} catch {
			logLastErrorCode(from: database)
			return .failure(dbError(from: database))
		}

		return .success(())
	}

	@discardableResult
	private func updateCheckins(with database: FMDatabase) -> SecureSQLStore.VoidResult {
		Log.info("[EventStore] Update checkins publisher.", log: .localData)

		let sql = """
				SELECT * FROM Checkin;
			"""

		do {
			let queryResult = try database.executeQuery(sql, values: [])
			var checkins = [Checkin]()

			while queryResult.next() {
				guard let traceLocationDescription = queryResult.string(forColumn: "traceLocationDescription"),
					  let traceLocationAddress = queryResult.string(forColumn: "traceLocationAddress") else {
					fatalError("[EventStore] SQL column is NOT NULL. Nil was not expected.")
				}

				// Persisting empty Data to a BLOB field leads to retrieving nil when reading it.
				// Because of that, we map nil to empty Data. Because "traceLocationId", "traceLocationIdHash", "cryptographicSeed" and "cnMasterPublicKey" are defined as NOT NULL, there should never be nil stored.
				// For more information about that problem, please see the issue opened here: https://github.com/ccgus/fmdb/issues/73
				let traceLocationId = queryResult.data(forColumn: "traceLocationId") ?? Data()
				let traceLocationIdHash = queryResult.data(forColumn: "traceLocationIdHash") ?? Data()
				let cryptographicSeed = queryResult.data(forColumn: "cryptographicSeed") ?? Data()
				let cnMainPublicKey = queryResult.data(forColumn: "cnMainPublicKey") ?? Data()

				let id = Int(queryResult.int(forColumn: "id"))
				let traceLocationType = TraceLocationType(rawValue: Int(queryResult.int(forColumn: "traceLocationType"))) ?? .locationTypeUnspecified
				let traceLocationVersion = Int(queryResult.int(forColumn: "traceLocationVersion"))
				let checkinStartDate = Date(timeIntervalSince1970: Double(queryResult.int(forColumn: "checkinStartDate")))
				let checkinEndDate = Date(timeIntervalSince1970: Double(queryResult.int(forColumn: "checkinEndDate")))
				let checkinCompleted = queryResult.bool(forColumn: "checkinCompleted")
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

				let checkin = Checkin(
					id: id,
					traceLocationId: traceLocationId,
					traceLocationIdHash: traceLocationIdHash,
					traceLocationVersion: traceLocationVersion,
					traceLocationType: traceLocationType,
					traceLocationDescription: traceLocationDescription,
					traceLocationAddress: traceLocationAddress,
					traceLocationStartDate: traceLocationStart,
					traceLocationEndDate: traceLocationEnd,
					traceLocationDefaultCheckInLengthInMinutes: traceLocationDefaultCheckInLengthInMinutes,
					cryptographicSeed: cryptographicSeed,
					cnMainPublicKey: cnMainPublicKey,
					checkinStartDate: checkinStartDate,
					checkinEndDate: checkinEndDate,
					checkinCompleted: checkinCompleted,
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
	private func updateTraceTimeIntervalMatches(with database: FMDatabase) -> SecureSQLStore.VoidResult {
		Log.info("[EventStore] Update TraceTimeIntervalMatches publisher.", log: .localData)

		let sql = """
				SELECT * FROM TraceTimeIntervalMatch;
			"""

		do {
			let queryResult = try database.executeQuery(sql, values: [])
			var traceTimeIntervalMatches = [TraceTimeIntervalMatch]()

			while queryResult.next() {

				let id = Int(queryResult.int(forColumn: "id"))
				let checkinId = Int(queryResult.int(forColumn: "checkinId"))
				let traceWarningPackageId = Int(queryResult.int(forColumn: "traceWarningPackageId"))
				let transmissionRiskLevel = Int(queryResult.int(forColumn: "transmissionRiskLevel"))
				let startIntervalNumber = Int(queryResult.int(forColumn: "startIntervalNumber"))
				let endIntervalNumber = Int(queryResult.int(forColumn: "endIntervalNumber"))

				// Persisting empty Data to a BLOB field leads to retrieving nil when reading it.
				// Because of that, we map nil to empty Data. Because "traceLocationId" is defined as NOT NULL, there should never be nil stored.
				// For more information about that problem, please see the issue opened here: https://github.com/ccgus/fmdb/issues/73
				let traceLocationId = queryResult.data(forColumn: "traceLocationId") ?? Data()

				let traceTimeIntervalMatch = TraceTimeIntervalMatch(
					id: id,
					checkinId: checkinId,
					traceWarningPackageId: traceWarningPackageId,
					traceLocationId: traceLocationId,
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
	private func updateTraceWarningPackageMetadata(with database: FMDatabase) -> SecureSQLStore.VoidResult {
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

	private func executeTraceLocationQuery(_ query: StoreQueryProtocol, in database: FMDatabase) -> SecureSQLStore.VoidResult {
		guard query.execute(in: database) else {
			logLastErrorCode(from: database)
			return .failure(dbError(from: database))
		}

		let updateTraceLocationsResult = updateTraceLocations(with: database)
		guard case .success = updateTraceLocationsResult else {
			logLastErrorCode(from: database)
			return .failure(dbError(from: database))
		}

		return .success(())
	}

	private func executeCheckinQuery(_ query: StoreQueryProtocol, in database: FMDatabase) -> SecureSQLStore.VoidResult {
		guard query.execute(in: database) else {
			logLastErrorCode(from: database)
			return .failure(dbError(from: database))
		}

		let updateCheckinsResult = updateCheckins(with: database)
		guard case .success = updateCheckinsResult else {
			logLastErrorCode(from: database)
			return .failure(dbError(from: database))
		}

		return .success(())
	}

	private func executeTraceTimeIntervalMatchQuery(
		_ query: StoreQueryProtocol,
		in database: FMDatabase
	) -> SecureSQLStore.VoidResult {

		guard query.execute(in: database) else {
			logLastErrorCode(from: database)
			return .failure(dbError(from: database))
		}

		let updateTraceTimeIntervalMatchesResult = updateTraceTimeIntervalMatches(with: database)
		guard case .success = updateTraceTimeIntervalMatchesResult else {
			logLastErrorCode(from: database)
			return .failure(dbError(from: database))
		}

		return .success(())
	}

	private func executeTraceWarningPackageMetadataQuery(
		_ query: StoreQueryProtocol,
		in database: FMDatabase
	) -> SecureSQLStore.VoidResult {

		guard query.execute(in: database) else {
			logLastErrorCode(from: database)
			return .failure(dbError(from: database))
		}

		let updateTraceWarningPackageMetadataResult = updateTraceWarningPackageMetadata(with: database)
		guard case .success = updateTraceWarningPackageMetadataResult else {
			logLastErrorCode(from: database)
			return .failure(dbError(from: database))
		}

		return .success(())
	}

	private func dropTables() -> SecureSQLStore.VoidResult {
		var result: SecureSQLStore.VoidResult?

		databaseQueue.inDatabase { database in
			let sql = """
					PRAGMA journal_mode=OFF;
					DROP TABLE Checkin;
					DROP TABLE TraceLocation;
					DROP TABLE TraceTimeIntervalMatch;
					DROP TABLE TraceWarningPackageMetadata;
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

	// swiftlint:disable:next file_length
}
