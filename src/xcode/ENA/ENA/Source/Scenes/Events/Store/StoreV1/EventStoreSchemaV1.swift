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
				CREATE TABLE IF NOT EXISTS Event (
					id TEXT PRIMARY KEY,
					type INTEGER NOT NULL,
					description STRING NOT NULL CHECK (LENGTH(name) <= \(maxTextLength)),
					address STRING NOT NULL CHECK (LENGTH(name) <= \(maxTextLength)),
					start INTEGER,
					end INTEGER,
					defaultCheckInLengthInMinutes INTEGER,
					signature TEXT NOT NULL
				);

				CREATE TABLE IF NOT EXISTS Checkin (
					id INTEGER PRIMARY KEY,
					eventId TEXT NOT NULL,
					eventType INTEGER NOT NULL,
					eventDescription STRING NOT NULL CHECK (LENGTH(name) <= \(maxTextLength)),
					eventAddress STRING NOT NULL CHECK (LENGTH(name) <= \(maxTextLength),
					eventStart INTEGER,
					eventEnd INTEGER,
					eventDefaultCheckInLengthInMinutes INTEGER,
					eventSignature TEXT NOT NULL,
					checkinStart INTEGER NOT NULL,
					checkinEnd INTEGER NOT NULL
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
	private let maxTextLength = 150
}
