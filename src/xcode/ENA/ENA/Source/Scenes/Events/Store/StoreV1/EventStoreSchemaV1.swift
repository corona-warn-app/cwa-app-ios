////
// 🦠 Corona-Warn-App
//

import Foundation
import FMDB

class EventStoreSchemaV1: SchemaProtocol {

	// MARK: - Init

	init(databaseQueue: FMDatabaseQueue) {
		self.databaseQueue = databaseQueue
	}

	// MARK: - Protocol SchemaProtocol

	@discardableResult
	func create() -> Result<Void, SQLiteErrorCode> {
		var result: Result<Void, SQLiteErrorCode> = .success(())

		databaseQueue.inDatabase { database in
			let sql = """

				CREATE TABLE IF NOT EXISTS Checkin (
					id INTEGER PRIMARY KEY,
					traceLocationGUID TEXT NOT NULL,
					traceLocationVersion INTEGER NOT NULL,
					traceLocationType INTEGER NOT NULL,
					traceLocationDescription TEXT NOT NULL CHECK (LENGTH(name) <= \(maxTextLength)),
					traceLocationAddress TEXT NOT NULL CHECK (LENGTH(name) <= \(maxTextLength),
					traceLocationStartDate INTEGER,
					traceLocationEndDate INTEGER,
					traceLocationDefaultCheckInLengthInMinutes INTEGER,
					traceLocationSignature TEXT NOT NULL,
					checkinStartDate INTEGER NOT NULL,
					checkinEndDate INTEGER,
					targetCheckinEndDate INTEGER,
					createJournalEntry INTEGER NOT NULL
				);

				CREATE TABLE IF NOT EXISTS TraceLocation (
					guid TEXT PRIMARY KEY,
					version INTEGER NOT NULL,
					type INTEGER NOT NULL,
					description TEXT NOT NULL CHECK (LENGTH(name) <= \(maxTextLength)),
					address TEXT NOT NULL CHECK (LENGTH(name) <= \(maxTextLength)),
					startDate INTEGER,
					endDate INTEGER,
					defaultCheckInLengthInMinutes INTEGER,
					signature TEXT NOT NULL
				);

				CREATE TABLE IF NOT EXISTS TraceTimeIntervalMatch (
					id INTEGER PRIMARY KEY,
					checkinId INTEGER NOT NULL,
					traceWarningPackageId INTEGER NOT NULL,
					traceLocationGUID TEXT NOT NULL,
					transmissionRiskLevel INTEGER NOT NULL,
					startIntervalNumber INTEGER NOT NULL,
					endIntervalNumber INTEGER NOT NULL
				);

				CREATE TABLE IF NOT EXISTS TraceWarningPackageMetadata (
					id INTEGER PRIMARY KEY,
					region TEXT NOT NULL,
					eTag TEXT NOT NULL
				);
			"""

			guard database.executeStatements(sql) else {
				Log.error("[SQLite] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
				result = .failure(SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown)
				return
			}

			database.userVersion = 1
			result = .success(())
		}

		return result
	}

	// MARK: - Private

	private let databaseQueue: FMDatabaseQueue
	private let maxTextLength = 100
}
