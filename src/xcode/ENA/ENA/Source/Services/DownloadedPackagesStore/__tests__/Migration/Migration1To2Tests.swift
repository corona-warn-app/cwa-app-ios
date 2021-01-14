//
// 🦠 Corona-Warn-App
//

import XCTest
import FMDB

@testable import ENA

final class Migration1To2Tests: XCTestCase {

	func testMigrationFromStoreVersion1To2() {
		let database = FMDatabase.inMemory()

		let tableName = "Z_DOWNLOADED_PACKAGE"
		let rowCount = 14

		// --- init V1
		let migrator1 = SerialMigrator(
			latestVersion: 1,
			database: database,
			migrations: [Migration0To1(database: database)]
		)

		let storeV1 = DownloadedPackagesSQLLiteStoreV1(database: database, migrator: migrator1, latestVersion: 1)
		storeV1.open()

		for index in 0..<rowCount {
			let dummyPackage = SAPDownloadedPackage(keysBin: Data(), signature: Data())
			storeV1.set(country: "DE", day: "\(index)", package: dummyPackage)
		}

		XCTAssertTrue(database.tableExists(tableName))
		XCTAssertEqual(database.numberOfRows(for: tableName), rowCount)
		XCTAssertEqual(database.numberOfColumns(for: tableName), 5)

		let migrator2 = SerialMigrator(
			latestVersion: 2,
			database: database,
			migrations: [Migration0To1(database: database), Migration1To2(database: database)]
		)

		// --- migrate to V2

		let storeV2 = DownloadedPackagesSQLLiteStoreV2(
			database: database,
			migrator: migrator2,
			latestVersion: 2
		)
		storeV2.open()

		XCTAssertTrue(database.tableExists(tableName))
		XCTAssertEqual(database.numberOfRows(for: tableName), rowCount)

		// check for the new columns
		XCTAssertEqual(database.numberOfColumns(for: tableName), 7)
		XCTAssertTrue(database.columnExists("Z_ETAG", inTableWithName: tableName))
		XCTAssertTrue(database.columnExists("Z_HASH", inTableWithName: tableName))

		// check content structure
		XCTAssertEqual(numberOfDEItems(for: database), rowCount)

		let dummyPackage = SAPDownloadedPackage(keysBin: Data(), signature: Data())
		storeV1.set(country: "IT", day: "14", package: dummyPackage)

		XCTAssertEqual(database.numberOfRows(for: tableName), rowCount.advanced(by: 1))
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
