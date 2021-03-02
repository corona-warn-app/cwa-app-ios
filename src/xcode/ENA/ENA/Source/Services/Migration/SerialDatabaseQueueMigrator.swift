////
// 🦠 Corona-Warn-App
//

import Foundation
import FMDB

class SerialDatabaseQueueMigrator: SerialMigratorProtocol {
	private let queue: FMDatabaseQueue
	private let latestVersion: Int
	private let migrations: [Migration]

	init(
		queue: FMDatabaseQueue,
		latestVersion: Int,
		migrations: [Migration]
	) {
		self.queue = queue
		self.latestVersion = latestVersion
		self.migrations = migrations
	}

	func migrate() throws {
		var migrationsToExecute = [Migration]()

		queue.inDatabase { database in
			var userVersion = database.userVersion

			while userVersion < latestVersion {
				let nextVersion = userVersion + 1
				if let migration = migrations.first(where: { $0.version == nextVersion }) {
					migrationsToExecute.append(migration)
				}
				userVersion = nextVersion
			}
		}

		for migration in migrationsToExecute {
			try migration.execute()
		}

		queue.inDatabase { database in
			database.userVersion = UInt32(latestVersion)
		}
	}
}
