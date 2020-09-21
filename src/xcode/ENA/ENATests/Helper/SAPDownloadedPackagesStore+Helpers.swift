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
