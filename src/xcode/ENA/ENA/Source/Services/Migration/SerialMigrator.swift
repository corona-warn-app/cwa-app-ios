//
// 🦠 Corona-Warn-App
//

import FMDB

class SerialMigrator: SerialMigratorProtocol {

	private let latestVersion: Int
	private let database: FMDatabase
	private let migrations: [Migration]

	init(
		latestVersion: Int,
		database: FMDatabase,
		migrations: [Migration]
	) {
		self.latestVersion = latestVersion
		self.database = database
		self.migrations = migrations
	}

	func migrate() throws {
		if database.userVersion < latestVersion {
			let userVersion = Int(database.userVersion)
			Log.info("Migrating database from v\(userVersion) to v\(latestVersion)!", log: .localData)

			do {
				let nextVersion = self.database.userVersion + 1
				let migration = migrations.first { $0.version == nextVersion }
				try migration?.execute()

				self.database.userVersion = nextVersion
				try migrate()
			} catch {
				Log.error("Migration failed from version \(database.userVersion) to version \(database.userVersion.advanced(by: 1))", log: .localData)
				throw error
			}
		} else {
			Log.debug("No database migration needed.", log: .localData)
		}
	}
}
