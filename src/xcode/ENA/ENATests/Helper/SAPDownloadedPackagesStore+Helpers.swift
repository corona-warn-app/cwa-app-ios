//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import FMDB

extension FMDatabase {
	class func inMemory() -> FMDatabase {
		FMDatabase(path: "file::memory:")
	}

	func numberOfRows(for table: String) -> Int {
		let sql =
			"""
			SELECT
				*
			FROM
				\(table)
			;
			"""

		guard let result = executeQuery(sql, withParameterDictionary: nil) else {
			return 0
		}

		var numberOfRows = 0
		while result.next() {
			numberOfRows += 1
		}
		result.close()
		return numberOfRows
	}

	func numberOfColumns(for table: String) -> Int {
		let sql =
			"""
			SELECT
				*
			FROM
				\(table)
			;
			"""

		guard let result = executeQuery(sql, withParameterDictionary: nil) else {
			return 0
		}
		return Int(result.columnCount)
	}
}

extension DownloadedPackagesSQLLiteStore {
	class func inMemory() -> DownloadedPackagesSQLLiteStore {
		return DownloadedPackagesSQLLiteStore(database: .inMemory(), migrator: SerialMigratorFake(), latestVersion: 0)
	}
}
