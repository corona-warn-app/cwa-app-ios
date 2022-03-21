//
// 🦠 Corona-Warn-App
//

@testable import ENA
import FMDB
import XCTest

// swiftlint:disable type_body_length
final class DownloadedPackagesSQLLiteStoreTests: CWATestCase {

	private var store: DownloadedPackagesSQLLiteStore = .inMemory()

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
		try store.set(country: "DE", day: "2020-06-12", etag: nil, package: package)
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
		try store.set(country: "DE", hour: 9, day: "2020-06-12", etag: nil, package: package)
		let hourlyPackagesDE = store.hourlyPackages(for: "2020-06-12", country: "DE")
		XCTAssertFalse(hourlyPackagesDE.isEmpty)

		try store.set(country: "IT", hour: 9, day: "2020-06-12", etag: nil, package: package)
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
		try store.set(country: "DE", hour: 1, day: "2020-06-12", etag: nil, package: package)
		try store.set(country: "DE", hour: 2, day: "2020-06-12", etag: nil, package: package)
		try store.set(country: "DE", hour: 3, day: "2020-06-12", etag: nil, package: package)
		try store.set(country: "DE", hour: 4, day: "2020-06-12", etag: nil, package: package)
		try store.set(country: "IT", hour: 1, day: "2020-06-12", etag: nil, package: package)
		try store.set(country: "IT", hour: 2, day: "2020-06-12", etag: nil, package: package)

		// Assert that hours exist
		let hourlyPackagesDE = store.hourlyPackages(for: "2020-06-12", country: "DE")
		XCTAssertEqual(hourlyPackagesDE.count, 4)

		let hourlyPackagesIT = store.hourlyPackages(for: "2020-06-12", country: "IT")
		XCTAssertEqual(hourlyPackagesIT.count, 2)

		// Now add a full day
		try store.set(country: "DE", day: "2020-06-12", etag: nil, package: package)
		XCTAssertTrue(store.hourlyPackages(for: "2020-06-12", country: "DE").isEmpty)

		try store.set(country: "IT", day: "2020-06-12", etag: nil, package: package)
		XCTAssertTrue(store.hourlyPackages(for: "2020-06-12", country: "IT").isEmpty)
	}

	func test_ResetRemovesAllKeys() throws {
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
		try store.set(country: "DE", day: "2020-06-01", etag: nil, package: package)
		try store.set(country: "DE", day: "2020-06-02", etag: nil, package: package)
		try store.set(country: "DE", day: "2020-06-03", etag: nil, package: package)
		try store.set(country: "IT", day: "2020-06-03", etag: nil, package: package)
		try store.set(country: "DE", day: "2020-06-04", etag: nil, package: package)
		try store.set(country: "DE", day: "2020-06-05", etag: nil, package: package)
		try store.set(country: "DE", day: "2020-06-06", etag: nil, package: package)
		try store.set(country: "IT", day: "2020-06-06", etag: nil, package: package)
		try store.set(country: "DE", day: "2020-06-07", etag: nil, package: package)

		XCTAssertEqual(store.allDays(country: "DE").count, 7)
		XCTAssertEqual(store.allDays(country: "IT").count, 2)

		store.reset()
		store.open()

		XCTAssertEqual(store.allDays(country: "DE").count, 0)
		XCTAssertEqual(store.allDays(country: "IT").count, 0)
		XCTAssertEqual(database.lastErrorCode(), 0)
	}
	
	func test_deleteDayPackage() throws {
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
				try store.set(country: country, day: date, etag: nil, package: package)
			}
		}

		// delete the packages one by one
		for country in countries {
			XCTAssertEqual(store.allDays(country: country).count, days.count)
			var deleteCounter = 0
			for date in days {
				store.deleteDayPackage(for: date, country: country)
				deleteCounter += 1
				XCTAssertEqual(store.allDays(country: country).count, days.count - deleteCounter)
			}
		}
	}
	
	func test_deleteHourPackage() throws {
		store.open()

		let keysBin = Data("keys".utf8)
		let signature = Data("sig".utf8)

		let package = SAPDownloadedPackage(
			keysBin: keysBin,
			signature: signature
		)

		let countries = ["DE", "IT"]
		let days = ["2020-11-03", "2020-11-02"]
		let hours = [Int].init(1...24)

		// Add days DE, IT
		for country in countries {
			for date in days {
				for hour in hours {
					try store.set(country: country, hour: hour, day: date, etag: nil, package: package)
				}
			}
		}
		// delete the packages one by one
		for country in countries {
			for date in days {
				var deleteCounter = 0
				for hour in hours {
					store.deleteHourPackage(for: date, hour: hour, country: country)
					deleteCounter += 1
					XCTAssertEqual(store.hours(for: date, country: country).count, hours.count - deleteCounter)
				}
			}
		}
	}

	func test_deleteWithCloseOpenDB() throws {
		let unitTestStore: DownloadedPackagesStore = DownloadedPackagesSQLLiteStore(fileName: "unittest")

		let keysBin = Data("keys".utf8)
		let signature = Data("sig".utf8)

		let package = SAPDownloadedPackage(
			keysBin: keysBin,
			signature: signature
		)

		try unitTestStore.set(country: "DE", hour: 1, day: "2020-11-04", etag: nil, package: package)
		try unitTestStore.set(country: "DE", hour: 2, day: "2020-11-04", etag: nil, package: package)
		try unitTestStore.set(country: "DE", day: "2020-11-03", etag: nil, package: package)
		try unitTestStore.set(country: "DE", day: "2020-11-02", etag: nil, package: package)
		
		XCTAssertEqual(unitTestStore.hourlyPackages(for: "2020-11-04", country: "DE").count, 2)
		XCTAssertEqual(unitTestStore.hours(for: "2020-11-04", country: "DE").count, 2)
		XCTAssertNotNil(unitTestStore.package(for: "2020-11-03", country: "DE"))
		XCTAssertNotNil(unitTestStore.package(for: "2020-11-02", country: "DE"))
		
		unitTestStore.deleteDayPackage(for: "2020-11-02", country: "DE")
		unitTestStore.deleteHourPackage(for: "2020-11-04", hour: 1, country: "DE")
		
		unitTestStore.close()
		unitTestStore.open()

		XCTAssertEqual(unitTestStore.hours(for: "2020-11-04", country: "DE").count, 1)
		unitTestStore.deleteHourPackage(for: "2020-11-04", hour: 2, country: "DE")
		XCTAssertEqual(unitTestStore.hours(for: "2020-11-04", country: "DE").count, 0)
		
		XCTAssertNotNil(unitTestStore.package(for: "2020-11-03", country: "DE"))
		unitTestStore.deleteDayPackage(for: "2020-11-03", country: "DE")
		XCTAssertNil(unitTestStore.package(for: "2020-11-03", country: "DE"))
	}

	func testFetchByETag() throws {
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
		let etag = "\"66ac17747b947b61a066369384896c79\""
		try store.set(country: "DE", day: "2020-06-01", etag: etag, package: package)
		try store.set(country: "DE", day: "2020-06-02", etag: etag, package: package)
		try store.set(country: "DE", day: "2020-06-03", etag: etag, package: package)
		try store.set(country: "IT", day: "2020-06-03", etag: etag, package: package)
		try store.set(country: "DE", day: "2020-06-04", etag: etag, package: package)
		try store.set(country: "DE", day: "2020-06-05", etag: nil, package: package)
		try store.set(country: "DE", day: "2020-06-06", etag: nil, package: package)
		try store.set(country: "IT", day: "2020-06-06", etag: nil, package: package)
		try store.set(country: "DE", day: "2020-06-07", etag: nil, package: package)

		XCTAssertEqual(store.allDays(country: "DE").count, 7)
		XCTAssertEqual(store.allDays(country: "IT").count, 2)

		let packages = try XCTUnwrap(store.packages(with: etag))
		XCTAssertEqual(packages.count, 5)
	}

	func testFetchByMultipleETags() throws {
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
		let etag = "\"66ac17747b947b61a066369384896c79\""
		let etag2 = "\"d41d8cd98f00b204e9800998ecf8427e\""
		try store.set(country: "DE", day: "2020-06-01", etag: etag, package: package)
		try store.set(country: "DE", day: "2020-06-02", etag: etag, package: package)
		try store.set(country: "DE", day: "2020-06-03", etag: etag, package: package)
		try store.set(country: "IT", day: "2020-06-03", etag: etag, package: package)
		try store.set(country: "DE", day: "2020-06-04", etag: etag, package: package)
		try store.set(country: "DE", day: "2020-06-05", etag: etag2, package: package)
		try store.set(country: "DE", day: "2020-06-06", etag: etag2, package: package)
		try store.set(country: "IT", day: "2020-06-06", etag: etag2, package: package)
		try store.set(country: "DE", day: "2020-06-07", etag: nil, package: package)

		XCTAssertEqual(store.allDays(country: "DE").count, 7)
		XCTAssertEqual(store.allDays(country: "IT").count, 2)

		let packages1 = try XCTUnwrap(store.packages(with: etag))
		XCTAssertEqual(packages1.count, 5)

		let packages2 = try XCTUnwrap(store.packages(with: etag2))
		XCTAssertEqual(packages2.count, 3)

		let packages3 = try XCTUnwrap(store.packages(with: [etag, etag2]))
		XCTAssertEqual(packages3.count, 8)
	}

	func testDeleteByHash() throws {
		let database = FMDatabase.inMemory()
		let store = DownloadedPackagesSQLLiteStore(database: database, migrator: SerialMigratorFake(), latestVersion: 0)
		store.open()

		var package: SAPDownloadedPackage {
			let noise = Data("fake\(Int.random(in: 0..<Int.max))".utf8)
			return SAPDownloadedPackage(keysBin: noise, signature: Data("sig".utf8))
		}

		// Add days
		let etag = "\"66ac17747b947b61a066369384896c79\""
		try store.set(country: "DE", day: "2020-06-01", etag: etag, package: package)
		try store.set(country: "DE", day: "2020-06-02", etag: etag, package: package)
		try store.set(country: "DE", day: "2020-06-03", etag: etag, package: package)
		try store.set(country: "IT", day: "2020-06-03", etag: etag, package: package)
		try store.set(country: "DE", day: "2020-06-04", etag: etag, package: package)
		try store.set(country: "DE", day: "2020-06-05", etag: nil, package: package)
		try store.set(country: "DE", day: "2020-06-06", etag: nil, package: package)
		try store.set(country: "IT", day: "2020-06-06", etag: nil, package: package)
		try store.set(country: "DE", day: "2020-06-07", etag: nil, package: package)

		XCTAssertEqual(store.allDays(country: "DE").count, 7)
		XCTAssertEqual(store.allDays(country: "IT").count, 2)

		// fetch packages without etag
		var packages = try XCTUnwrap(store.packages(with: nil))
		XCTAssertEqual(packages.count, 4)

		// test: delete single package
		let last = try XCTUnwrap(packages.popLast()) // "DE" @ 2020-06-07
		XCTAssertEqual(packages.count, 3)
		try store.delete(package: last)
		XCTAssertEqual(store.allDays(country: "DE").count, 6)
		XCTAssertEqual(store.allDays(country: "IT").count, 2)

		// test: delete multiple packages
		try store.delete(packages: packages)
		XCTAssertEqual(store.allDays(country: "DE").count, 4)
		XCTAssertEqual(store.allDays(country: "IT").count, 1)
	}

	func testPackageStoreValidation() throws {
		let database = FMDatabase.inMemory()
		let store = DownloadedPackagesSQLLiteStore(database: database, migrator: SerialMigratorFake(), latestVersion: 0)
		store.open()

		let keyValueStore = MockTestStore()
		keyValueStore.wasRecentDayKeyDownloadSuccessful = true
		keyValueStore.wasRecentHourKeyDownloadSuccessful = true

		store.keyValueStore = keyValueStore

		// dummy data
		var package: SAPDownloadedPackage {
			let noise = Data("fake\(Int.random(in: 0..<Int.max))".utf8)
			return SAPDownloadedPackage(keysBin: noise, signature: Data("sig".utf8))
		}
		let etag = "\"66ac17747b947b61a066369384896c79\""
		let revokedEtag = "\"d41d8cd98f00b204e9800998ecf8427e\""

		// validate empty store and revokation list
		XCTAssertNoThrow(try store.validateCachedKeyPackages(revokationList: []))
		XCTAssertNoThrow(try store.validateCachedKeyPackages(revokationList: [revokedEtag]))

		// Add some data
		try store.set(country: "DE", day: "2020-06-01", etag: etag, package: package)
		try store.set(country: "DE", day: "2020-06-02", etag: etag, package: package)

		XCTAssertNoThrow(try store.validateCachedKeyPackages(revokationList: [revokedEtag]))
		XCTAssertEqual(store.allDays(country: "DE").count, 2)

		// add some more data
		try store.set(country: "DE", day: "2020-06-03", etag: revokedEtag, package: package)
		try store.set(country: "IT", day: "2020-06-03", etag: revokedEtag, package: package)
		try store.set(country: "DE", day: "2020-06-04", etag: etag, package: package)
		try store.set(country: "DE", day: "2020-06-05", etag: nil, package: package)
		try store.set(country: "DE", day: "2020-06-06", etag: nil, package: package)
		try store.set(country: "IT", day: "2020-06-06", etag: nil, package: package)
		try store.set(country: "DE", day: "2020-06-07", etag: nil, package: package)

		XCTAssertEqual(store.allDays(country: "DE").count, 7)
		XCTAssertEqual(store.allDays(country: "IT").count, 2)
		XCTAssertNoThrow(try store.validateCachedKeyPackages(revokationList: [revokedEtag]))
		// 2+4 new DE packages expected; 1 more removed
		XCTAssertEqual(store.allDays(country: "DE").count, 6)
		XCTAssertEqual(store.allDays(country: "IT").count, 1)

		XCTAssertFalse(keyValueStore.wasRecentDayKeyDownloadSuccessful)
		XCTAssertFalse(keyValueStore.wasRecentHourKeyDownloadSuccessful)
	}

	func testPackageStoreValidationOnSet() throws {
		let database = FMDatabase.inMemory()
		let store = DownloadedPackagesSQLLiteStore(database: database, migrator: SerialMigratorFake(), latestVersion: 0)

		let etag = "\"66ac17747b947b61a066369384896c79\""
		let revokedEtag = "\"d41d8cd98f00b204e9800998ecf8427e\""

		store.revokationList = [revokedEtag]
		store.open()

		// dummy data
		var package: SAPDownloadedPackage {
			let noise = Data("fake\(Int.random(in: 0..<Int.max))".utf8)
			return SAPDownloadedPackage(keysBin: noise, signature: Data("sig".utf8))
		}

		// Add some data
		try store.set(country: "DE", day: "2020-06-01", etag: etag, package: package)
		try store.set(country: "DE", day: "2020-06-02", etag: etag, package: package)

		XCTAssertEqual(store.allDays(country: "DE").count, 2)

		// add some more data
		XCTAssertThrowsError(try store.set(country: "DE", day: "2020-06-03", etag: revokedEtag, package: package))
		try store.set(country: "IT", day: "2020-06-06", etag: nil, package: package)
		try store.set(country: "DE", day: "2020-06-07", etag: nil, package: package)

		XCTAssertEqual(store.allDays(country: "DE").count, 3)
		XCTAssertEqual(store.allDays(country: "IT").count, 1)

		// 2 different 'set' implementations, so let's cover the 2nd as well
		XCTAssertThrowsError(try store.set(country: "IT", hour: 1, day: "2020-06-03", etag: revokedEtag, package: package))
		try store.set(country: "IT", hour: 1, day: "2020-06-04", etag: etag, package: package)
		try store.set(country: "IT", hour: 1, day: "2020-06-05", etag: nil, package: package)

		XCTAssertEqual(store.hours(for: "2020-06-03", country: "IT").count, 0)
		XCTAssertEqual(store.hours(for: "2020-06-04", country: "IT").count, 1)
		XCTAssertEqual(store.hours(for: "2020-06-05", country: "IT").count, 1)
	}

	func testPackageStoreEvilData() throws {
		let database = FMDatabase.inMemory()
		let store = DownloadedPackagesSQLLiteStore(database: database, migrator: SerialMigratorFake(), latestVersion: 0)

		// tags
		let etag = "\"66ac17747b947b61a066369384896c79\""
		let evil = "1;DROP TABLE Z_DOWNLOADED_PACKAGE"

		store.open()

		// dummy data
		var package: SAPDownloadedPackage {
			let noise = Data("fake\(Int.random(in: 0..<Int.max))".utf8)
			return SAPDownloadedPackage(keysBin: noise, signature: Data("sig".utf8))
		}

		// Test day & hour packages
		try store.set(country: "DE", day: "2020-06-01", etag: evil, package: package)
		try store.set(country: "DE", hour: 1, day: "2020-06-02", etag: evil, package: package)
		try store.set(country: "DE", day: "2020-06-03", etag: etag, package: package)
		try store.set(country: "DE", hour: 1, day: "2020-06-04", etag: etag, package: package)

		let evilETagPackages = try XCTUnwrap(store.packages(with: evil))
		XCTAssertEqual(evilETagPackages.count, 2)
		XCTAssertEqual(store.hours(for: "2020-06-02", country: "DE").count, 1)
		XCTAssertEqual(store.hours(for: "2020-06-04", country: "DE").count, 1)
	}
	
	func test_MarkPackagesAsCheckedForExposures() throws {
		let database = FMDatabase.inMemory()
		let store = DownloadedPackagesSQLLiteStore(database: database, migrator: SerialMigratorFake(), latestVersion: 0)
		store.open()

		// Add days
		let dayPackage1 = randomPackage()
		let dayPackage2 = randomPackage()
		let dayPackage3 = randomPackage()
		try store.set(country: "DE", day: "2020-06-01", etag: nil, package: dayPackage1)
		try store.set(country: "DE", day: "2020-06-02", etag: nil, package: dayPackage2)
		try store.set(country: "DE", day: "2020-06-03", etag: nil, package: dayPackage3)

		// Add hours
		let hourPackage1 = randomPackage()
		let hourPackage2 = randomPackage()
		let hourPackage3 = randomPackage()
		try store.set(country: "DE", hour: 1, day: "2020-06-4", etag: nil, package: hourPackage1)
		try store.set(country: "DE", hour: 2, day: "2020-06-4", etag: nil, package: hourPackage2)
		try store.set(country: "DE", hour: 3, day: "2020-06-4", etag: nil, package: hourPackage3)

		try store.markPackagesAsCheckedForExposures([
			dayPackage1.fingerprint,
			dayPackage2.fingerprint,
			hourPackage1.fingerprint,
			hourPackage2.fingerprint
		])
		
		XCTAssertEqual(store.hourlyPackagesNotCheckedForExposure(for: "2020-06-4", country: "DE").count, 1)
		XCTAssertEqual(store.allDaysNotCheckedForExposure(country: "DE").count, 1)
	}
	
	private func randomPackage() -> SAPDownloadedPackage {
		SAPDownloadedPackage(
			keysBin: Data(String.getRandomString(of: 5).utf8),
			signature: Data(String.getRandomString(of: 5).utf8)
		)
	}
}
