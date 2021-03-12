////
// 🦠 Corona-Warn-App
//

import FMDB

enum SecureSQLStoreError: Error {
	case database(SQLiteErrorCode)
	case timeout
	case migration
}

protocol SecureSQLStore {
	typealias IdResult = Result<Int, SecureSQLStoreError>
	typealias VoidResult = Result<Void, SecureSQLStoreError>

	var databaseQueue: FMDatabaseQueue { get }
	var key: String { get }
	var schema: StoreSchemaProtocol { get }
	var migrator: SerialMigratorProtocol { get }
}

extension SecureSQLStore {
	func openAndSetup() -> SecureSQLStore.VoidResult {
		var errorResult: SecureSQLStore.VoidResult?
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

		return setupSchema(with: Int(userVersion))
	}

	func setupSchema(with userVersion: Int) -> SecureSQLStore.VoidResult {
		// If the version is zero then this means this is a fresh database "i.e no previous app was installed".
		// If the version is zero we create the latest schema, else we execute a migration.
		if userVersion == 0 {
			return schema.create()
		} else {
			return migrate()
		}
	}

	func migrate() -> SecureSQLStore.VoidResult {
		var migrationError: MigrationError?
		do {
			try migrator.migrate()
		} catch {
			migrationError = MigrationError.general(description: error.localizedDescription)
		}

		if migrationError != nil {
			return .failure(.migration)
		} else {
			return .success(())
		}
	}

	func logLastErrorCode(from database: FMDatabase) {
		Log.error("[EventStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
	}

	func dbError(from database: FMDatabase) -> SecureSQLStoreError {
		let dbError = SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown
		return .database(dbError)
	}
}
