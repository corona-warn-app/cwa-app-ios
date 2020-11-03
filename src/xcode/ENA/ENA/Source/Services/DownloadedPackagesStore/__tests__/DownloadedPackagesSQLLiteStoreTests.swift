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

@testable import ENA
import FMDB
import XCTest

final class DownloadedPackagesSQLLiteStoreTests: XCTestCase {

	private var store: DownloadedPackagesSQLLiteStoreV1 = .inMemory()

	override func tearDown() {
		super.tearDown()
		store.close()
	}

	func testEmptyEmptyDb() throws {
		store.open()
		XCTAssertNil(store.package(for: "2020-06-13", country: "DE"))
	}

	// Add a package, try to get it, assert that it matches what we put inside
	func testSettingDays() throws {
		store.open()
		let keysBin = Data("keys".utf8)
		let signature = Data("sig".utf8)

		let package = SAPDownloadedPackage(
			keysBin: keysBin,
			signature: signature
		)
		store.set(country: "DE", day: "2020-06-12", package: package)
		let packageOut = store.package(for: "2020-06-12", country: "DE")
		XCTAssertNotNil(packageOut)
		XCTAssertEqual(packageOut?.signature, signature)
		XCTAssertEqual(packageOut?.bin, keysBin)
	}

	//TODO: fix tests

//	func testSettingDaysCompletionCallback() throws {
//		store.open()
//		let keysBin = Data("keys".utf8)
//		let signature = Data("sig".utf8)
//
//		let package = SAPDownloadedPackage(
//			keysBin: keysBin,
//			signature: signature
//		)
//
//		let completionExpectation = expectation(description: "Completion callback")
//
//		store.set(country: "DE", day: "2020-10-06", package: package) { [weak self] error in
//			guard let self = self else { return }
//
//			let packageOut = self.store.package(for: "2020-10-06", country: "DE")
//			XCTAssertNotNil(packageOut)
//			XCTAssertEqual(packageOut?.signature, signature)
//			XCTAssertEqual(packageOut?.bin, keysBin)
//			XCTAssertNil(error)
//			completionExpectation.fulfill()
//		}
//
//		waitForExpectations(timeout: 1)
//	}
//
//	func testSettingDaysCompletionCallbackExpectedNotNil() throws {
//		store.open()
//		let keysBin = Data("keys".utf8)
//		let signature = Data("sig".utf8)
//
//		let package = SAPDownloadedPackage(
//			keysBin: keysBin,
//			signature: signature
//		)
//
//		let completionExpectation = expectation(description: "Completion callback")
//		let mockStore = MockTestStore()
//
//		mockStore.fakeSQLiteError = SQLiteErrorCode.sqlite_full.rawValue
//
//		store.keyValueStore = mockStore
//
//		store.set(country: "DE", day: "2020-10-06", package: package) { error in
//			XCTAssertNotNil(error)
//			completionExpectation.fulfill()
//		}
//
//		waitForExpectations(timeout: 1)
//	}

	// Add a package for a given hour on a given day, try to get it and assert that it matches whatever we put inside
	func testSettingHoursForDay() throws {
		store.open()
		XCTAssertTrue(store.hourlyPackages(for: "2020-06-12", country: "DE").isEmpty)

		let keysBin = Data("keys".utf8)
		let signature = Data("sig".utf8)

		let package = SAPDownloadedPackage(
			keysBin: keysBin,
			signature: signature
		)
		store.set(country: "DE", hour: 9, day: "2020-06-12", package: package)
		let hourlyPackagesDE = store.hourlyPackages(for: "2020-06-12", country: "DE")
		XCTAssertFalse(hourlyPackagesDE.isEmpty)

		store.set(country: "IT", hour: 9, day: "2020-06-12", package: package)
		let hourlyPackagesIT = store.hourlyPackages(for: "2020-06-12", country: "IT")
		XCTAssertFalse(hourlyPackagesIT.isEmpty)
	}

	// Add a package for a given hour on a given day, try to get it and assert that it matches whatever we put inside
	func testHoursAreDeletedIfDayIsAdded() throws {
		store.open()
		XCTAssertTrue(store.hourlyPackages(for: "2020-06-12", country: "DE").isEmpty)

		let keysBin = Data("keys".utf8)
		let signature = Data("sig".utf8)

		let package = SAPDownloadedPackage(
			keysBin: keysBin,
			signature: signature
		)

		// Add hours
		store.set(country: "DE", hour: 1, day: "2020-06-12", package: package)
		store.set(country: "DE", hour: 2, day: "2020-06-12", package: package)
		store.set(country: "DE", hour: 3, day: "2020-06-12", package: package)
		store.set(country: "DE", hour: 4, day: "2020-06-12", package: package)
		store.set(country: "IT", hour: 1, day: "2020-06-12", package: package)
		store.set(country: "IT", hour: 2, day: "2020-06-12", package: package)

		// Assert that hours exist
		let hourlyPackagesDE = store.hourlyPackages(for: "2020-06-12", country: "DE")
		XCTAssertEqual(hourlyPackagesDE.count, 4)

		let hourlyPackagesIT = store.hourlyPackages(for: "2020-06-12", country: "IT")
		XCTAssertEqual(hourlyPackagesIT.count, 2)

		// Now add a full day
		store.set(country: "DE", day: "2020-06-12", package: package)
		XCTAssertTrue(store.hourlyPackages(for: "2020-06-12", country: "DE").isEmpty)

		store.set(country: "IT", day: "2020-06-12", package: package)
		XCTAssertTrue(store.hourlyPackages(for: "2020-06-12", country: "IT").isEmpty)
	}

	func test_ResetRemovesAllKeys() {
		let database = FMDatabase.inMemory()
		let store = DownloadedPackagesSQLLiteStore(database: database, migrator: SerialMigratorFake(), latestVersion: 0)
		store.open()

		let keysBin = Data("keys".utf8)
		let signature = Data("sig".utf8)

		let package = SAPDownloadedPackage(
			keysBin: keysBin,
			signature: signature
		)

		// Add days
		store.set(country: "DE", day: "2020-06-01", package: package)
		store.set(country: "DE", day: "2020-06-02", package: package)
		store.set(country: "DE", day: "2020-06-03", package: package)
		store.set(country: "IT", day: "2020-06-03", package: package)
		store.set(country: "DE", day: "2020-06-04", package: package)
		store.set(country: "DE", day: "2020-06-05", package: package)
		store.set(country: "DE", day: "2020-06-06", package: package)
		store.set(country: "IT", day: "2020-06-06", package: package)
		store.set(country: "DE", day: "2020-06-07", package: package)

		XCTAssertEqual(store.allDays(country: "DE").count, 7)
		XCTAssertEqual(store.allDays(country: "IT").count, 2)

		store.reset()
		store.open()

		XCTAssertEqual(store.allDays(country: "DE").count, 0)
		XCTAssertEqual(store.allDays(country: "IT").count, 0)
		XCTAssertEqual(database.lastErrorCode(), 0)
	}
	
	func test_deleteDayPackage() {
		store.open()

		let keysBin = Data("keys".utf8)
		let signature = Data("sig".utf8)

		let package = SAPDownloadedPackage(
			keysBin: keysBin,
			signature: signature
		)
		
		let countries = ["DE", "IT"]
		let days = ["2020-11-03", "2020-11-02", "2020-11-01", "2020-10-31", "2020-10-30", "2020-10-29", "2020-10-28", "2020-10-27"]

		// Add days DE, IT
		for country in countries {
			for date in days {
				_ = store.set(country: country, day: date, package: package)
			}
		}

		// delete all entries one by one and check result
		for country in countries {
			XCTAssertEqual(store.allDays(country: country).count, days.count)
			var loopCounter = 0
			for date in days {
				store.deleteDayPackage(for: date, country: country)
				loopCounter += 1
				XCTAssertEqual(store.allDays(country: country).count, days.count - loopCounter)
			}
		}
	}
	
	func test_deleteHourPackage() {
		store.open()

		let keysBin = Data("keys".utf8)
		let signature = Data("sig".utf8)

		let package = SAPDownloadedPackage(
			keysBin: keysBin,
			signature: signature
		)

		let countries = ["DE", "IT"]
		let days = ["2020-11-03", "2020-11-02"]
		let hours = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 141, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]

		// Add days DE, IT
		for country in countries {
			for date in days {
				for hour in hours {
					_ = store.set(country: country, hour: hour, day: date, package: package)
				}
			}
		}

		for country in countries {
			XCTAssertEqual(store.hours(for: days[0], country: country).count, hours.count)
		}
		
		store.deleteHourPackage(for: days[0], hour: 2, country: countries[0])
		XCTAssertEqual(store.hours(for: days[0], country: countries[0]).count, hours.count - 1)
		XCTAssertEqual(store.hours(for: days[1], country: countries[0]).count, hours.count)
		XCTAssertEqual(store.hours(for: days[0], country: countries[1]).count, hours.count)
		XCTAssertEqual(store.hours(for: days[1], country: countries[1]).count, hours.count)
		
		store.deleteHourPackage(for: days[1], hour: 2, country: countries[1])
		XCTAssertEqual(store.hours(for: days[1], country: countries[1]).count, hours.count - 1)

	}
}
