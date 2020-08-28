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

class Migration0To1Tests: XCTestCase {

	func testMigrationFromStoreVersion0To1() {
		let database = FMDatabase(path: "file::memory:")
		let storeV0 = DownloadedPackagesSQLLiteStoreV0(database: database)
		storeV0.open()

		for index in 0...13 {
			let dummyPackage = SAPDownloadedPackage(keysBin: Data(), signature: Data())
			storeV0.set(day: "\(index)", package: dummyPackage)
		}
		storeV0.close()

		let latestDBVersion = 1
		let migration0To1 = Migration0To1(database: database)
		let migrator = SerialMigrator(latestVersion: latestDBVersion, database: database, migrations: [migration0To1])

		let storeV1 = DownloadedPackagesSQLLiteStore(database: database, migrator: migrator)
		storeV1.open()
	}
}
