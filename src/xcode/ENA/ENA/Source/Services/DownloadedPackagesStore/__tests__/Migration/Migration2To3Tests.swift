//
// 🦠 Corona-Warn-App
//

import XCTest
import FMDB

@testable import ENA

final class Migration2To3Tests: CWATestCase {

	func testMigrationFromStoreVersion2To3() throws {
		let database = FMDatabase.inMemory()

		let tableName = "Z_DOWNLOADED_PACKAGE"
		let rowCount = 14

		// --- init V2
		let storeV2 = DownloadedPackagesSQLLiteStoreV2(database: database, migrator: SerialMigratorFake(), latestVersion: 1)
		storeV2.open()

		for index in 0..<rowCount {
			let dummyPackage = SAPDownloadedPackage(keysBin: Data(), signature: Data())
			try storeV2.set(country: "DE", day: "\(index)", etag: nil, package: dummyPackage)
		}

		XCTAssertTrue(database.tableExists(tableName))
		XCTAssertEqual(database.numberOfRows(for: tableName), rowCount)
		XCTAssertEqual(database.numberOfColumns(for: tableName), 5)

		let migrator3 = SerialMigrator(
			latestVersion: 3,
			database: database,
			migrations: [
				Migration0To1(database: database),
				Migration1To2(database: database),
				Migration2To3(database: database)
			]
		)

		// --- migrate to V2

		let storeV3 = DownloadedPackagesSQLLiteStoreV2(
			database: database,
			migrator: migrator3,
			latestVersion: 3
		)
		storeV3.open()

		XCTAssertTrue(database.tableExists(tableName))
		XCTAssertEqual(database.numberOfRows(for: tableName), rowCount)

		// check for the new columns
		XCTAssertEqual(database.numberOfColumns(for: tableName), 8)
		XCTAssertTrue(database.columnExists("Z_CHECKED_FOR_EXPOSURES", inTableWithName: tableName))

		// check content structure
		XCTAssertEqual(numberOfDEItems(for: database), rowCount)
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
