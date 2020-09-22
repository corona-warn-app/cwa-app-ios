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

	func testWeOnlyGet14DaysAfterPruning() throws {
		store.open()

		let keysBin = Data("keys".utf8)
		let signature = Data("sig".utf8)

		let package = SAPDownloadedPackage(
			keysBin: keysBin,
			signature: signature
		)

		// Add days
		store.set(country: "DE", day: "2020-06-01", package: package)
		store.set(country: "IT", day: "2020-06-01", package: package)
		store.set(country: "DE", day: "2020-06-02", package: package)
		store.set(country: "DE", day: "2020-06-03", package: package)
		store.set(country: "DE", day: "2020-06-05", package: package)
		store.set(country: "IT", day: "2020-06-05", package: package)
		store.set(country: "DE", day: "2020-06-05", package: package)
		store.set(country: "DE", day: "2020-06-06", package: package)
		store.set(country: "DE", day: "2020-06-07", package: package)
		store.set(country: "DE", day: "2020-06-08", package: package)
		store.set(country: "DE", day: "2020-06-09", package: package)
		store.set(country: "DE", day: "2020-06-10", package: package)
		store.set(country: "DE", day: "2020-06-11", package: package)
		store.set(country: "DE", day: "2020-06-12", package: package)
		store.set(country: "DE", day: "2020-06-13", package: package)
		store.set(country: "DE", day: "2020-06-14", package: package)
		store.set(country: "DE", day: "2020-06-15", package: package)
		store.set(country: "DE", day: "2020-06-16", package: package)
		store.set(country: "DE", day: "2020-06-17", package: package)
		store.set(country: "DE", day: "2020-06-18", package: package)
		store.set(country: "IT", day: "2020-06-18", package: package)
		store.set(country: "DE", day: "2020-06-19", package: package)
		store.set(country: "IT", day: "2020-06-19", package: package)
		store.set(country: "DE", day: "2020-06-20", package: package)
		store.set(country: "IT", day: "2020-06-20", package: package)

		// Assert that we only get 14 packages

		XCTAssertEqual(store.allDays(country: "DE").count, 20)
		XCTAssertEqual(store.allDays(country: "IT").count, 5)
		try store.deleteOutdatedDays(now: "2020-06-20")
		XCTAssertEqual(store.allDays(country: "DE").count, 14)
		XCTAssertEqual(store.allDays(country: "IT").count, 3)
	}

	func testGetLessThan14DaysAfterPruning() throws {
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

		// Assert that we only get 7 packages

		XCTAssertEqual(store.allDays(country: "DE").count, 7)
		XCTAssertEqual(store.allDays(country: "IT").count, 2)
		try store.deleteOutdatedDays(now: "2020-06-07")
		XCTAssertEqual(store.allDays(country: "DE").count, 7)
		XCTAssertEqual(store.allDays(country: "IT").count, 2)
	}
}
