//
// 🦠 Corona-Warn-App
//

import FMDB

protocol SerialMigratorProtocol {
	func migrate()
}

final class SerialMigrator: SerialMigratorProtocol {

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

	func migrate() {
		if database.userVersion < latestVersion {
			let userVersion = Int(database.userVersion)

			migrations[userVersion].execute { [weak self] success in
				if success {
					self?.database.userVersion += 1
					migrate()
				} else {
					Log.error("Migration failed from version \(database.userVersion) to version \(database.userVersion += 1)", log: .localData)
					return
				}
			}
		} else {
			return
		}
	}
}
