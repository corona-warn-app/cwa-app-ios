//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import FMDB

protocol SerialMigratorProtocol {
	func migrate() throws
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

	func migrate() throws {
		if database.userVersion < latestVersion {
			let userVersion = Int(database.userVersion)
			Log.info("Migrating database from v\(userVersion) to v\(latestVersion)!", log: .localData)

			do {
				try migrations[userVersion].execute()
				self.database.userVersion += 1
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
