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

import XCTest
import FMDB

@testable import ENA

#if INTEROP

class Migration0To1Tests: XCTestCase {

	func testMigrationFromStoreVersion0To1() {
		let database = FMDatabase.inMemory()
		let storeV0 = DownloadedPackagesSQLLiteStoreV0(database: database)
		storeV0.open()

		for index in 0...13 {
			let dummyPackage = SAPDownloadedPackage(keysBin: Data(), signature: Data())
			storeV0.set(day: "\(index)", package: dummyPackage)
		}

		XCTAssertTrue(database.tableExists("Z_DOWNLOADED_PACKAGE"))
		XCTAssertEqual(database.numberOfRows(for: "Z_DOWNLOADED_PACKAGE"), 14)
		XCTAssertEqual(database.numberOfColumns(for: "Z_DOWNLOADED_PACKAGE"), 4)

		let latestDBVersion = 1
		let migration0To1 = Migration0To1(database: database)

		let migrator = SerialMigrator(
			latestVersion: latestDBVersion,
			database: database,
			migrations: [migration0To1]
		)

		let storeV1 = DownloadedPackagesSQLLiteStoreV1(
			database: database,
			migrator: migrator,
			latestVersion: latestDBVersion
		)

		storeV1.open()

		XCTAssertTrue(database.tableExists("Z_DOWNLOADED_PACKAGE"))
		XCTAssertEqual(database.numberOfRows(for: "Z_DOWNLOADED_PACKAGE"), 14)
		XCTAssertEqual(database.numberOfColumns(for: "Z_DOWNLOADED_PACKAGE"), 5)
		XCTAssertEqual(numberOfDEItems(for: database), 14)

		let dummyPackage = SAPDownloadedPackage(keysBin: Data(), signature: Data())
		storeV1.set(country: "IT", day: "14", package: dummyPackage)

		XCTAssertEqual(database.numberOfRows(for: "Z_DOWNLOADED_PACKAGE"), 15)
	}

	private func numberOfDEItems(for database: FMDatabase) -> Int {
		let sql =
		"""
			SELECT
				*
			FROM
				Z_DOWNLOADED_PACKAGE
			WHERE
				Z_COUNTRY = 'DE'
		;
		"""

		guard let result = database.executeQuery(sql, withParameterDictionary: nil) else {
			return 0
		}

		var numberOfRows = 0
		while result.next() {
			numberOfRows += 1
		}
		result.close()
		return numberOfRows
	}
}

#endif
