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

class Migration0To1: Migration {

	private let database: FMDatabase

	init(database: FMDatabase) {
		self.database = database
	}

	func execute(completed: (Bool) -> Void) {
		let sql = """
			BEGIN TRANSACTION;

			ALTER
				TABLE Z_DOWNLOADED_PACKAGE
			ADD
				Z_COUNTRY INTEGER;

			UPDATE
				Z_DOWNLOADED_PACKAGE
			SET
				Z_COUNTRY = "DE";

			ALTER TABLE
				Z_DOWNLOADED_PACKAGE
			RENAME TO
				Z_DOWNLOADED_PACKAGE_OLD;

			PRAGMA locking_mode=EXCLUSIVE;
			PRAGMA auto_vacuum=2;
			PRAGMA journal_mode=WAL;

			CREATE TABLE
				Z_DOWNLOADED_PACKAGE (
				Z_BIN BLOB NOT NULL,
				Z_SIGNATURE BLOB NOT NULL,
				Z_DAY TEXT NOT NULL,
				Z_HOUR INTEGER,
				Z_COUNTRY STRING NOT NULL,
				PRIMARY KEY (
					Z_COUNTRY,
					Z_DAY,
					Z_HOUR
				)
			);

			INSERT INTO
				Z_DOWNLOADED_PACKAGE
			SELECT * FROM
				Z_DOWNLOADED_PACKAGE_OLD;

			UPDATE
				Z_DOWNLOADED_PACKAGE
			SET
				Z_COUNTRY = "DE";

			DROP
				TABLE Z_DOWNLOADED_PACKAGE_OLD;

			COMMIT;
		"""

		let success = database.executeStatements(sql)
		completed(success)
	}
}
