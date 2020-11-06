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
import XCTest

final class DayKeyPackageDownloadTest: XCTestCase {
	
	func test_When_NoCachedDayPackages_Then_AllServerDayPackagesAreDownloaded() {
		let store = MockTestStore()
		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()
		packagesStore.open()
		let client = ClientMock()

		client.availableDaysAndHours = DaysAndHours(days: ["2020-10-01", "2020-10-02", "2020-10-03"], hours: [1, 2])

		let countryId = "IT"
		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			client: client,
			store: store,
			countryIds: [countryId]
		)

		let successExpectation = expectation(description: "Package download was successful.")

		keyPackageDownload.startDayPackagesDownload { result in
			switch result {
			case .success:
				let allDayKeys = packagesStore.allDays(country: countryId)
				XCTAssertEqual(allDayKeys, ["2020-10-01", "2020-10-02", "2020-10-03"])
				XCTAssertEqual(packagesStore.hours(for: .formattedToday(), country: countryId).count, 0)
				successExpectation.fulfill()
			case .failure(let error):
				XCTFail("Failure callback is not expected: \(error)")
			}
		}

		waitForExpectations(timeout: 1.0)
	}

	func test_When_CachedDayPackagesAvailable_Then_OnlyServerDeltaPackagesAreDownloaded() throws {
		let store = MockTestStore()

		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()
		packagesStore.open()
		let dummyPackage = SAPDownloadedPackage(keysBin: Data(), signature: Data())
		let countryId = "IT"
		try packagesStore.addFetchedDays(["2020-10-04": dummyPackage, "2020-10-01": dummyPackage], country: countryId, etag: nil)

		let client = ClientMock()
		client.availableDaysAndHours = DaysAndHours(days: ["2020-10-02", "2020-10-01", "2020-10-03", "2020-10-04"], hours: [1, 2])
		client.downloadedPackage = dummyPackage

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			client: client,
			store: store,
			countryIds: ["IT"]
		)

		let successExpectation = expectation(description: "Package download was successful.")

		keyPackageDownload.startDayPackagesDownload { result in
			switch result {
			case .success:
				let allDayKeys = packagesStore.allDays(country: countryId)
				XCTAssertEqual(allDayKeys, ["2020-10-01", "2020-10-02", "2020-10-03", "2020-10-04"])
				XCTAssertEqual(packagesStore.hours(for: .formattedToday(), country: countryId).count, 0)
				successExpectation.fulfill()
			case .failure(let error):
				XCTFail("Failure callback is not expected: \(error)")
			}
		}

		waitForExpectations(timeout: 1.0)
	}

	func test_When_ExpiredCachedDayPackagesAvailable_Then_ExpiredPackagesAreDeleted() throws {
		let store = MockTestStore()

		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()
		packagesStore.open()
		let dummyPackage = SAPDownloadedPackage(keysBin: Data(), signature: Data())
		let countryId = "IT"
		try packagesStore.addFetchedDays(["2020-10-04": dummyPackage, "2020-10-01": dummyPackage], country: countryId, etag: nil)

		let client = ClientMock()
		client.availableDaysAndHours = DaysAndHours(days: ["2020-10-02", "2020-10-03", "2020-10-04"], hours: [1, 2])
		client.downloadedPackage = dummyPackage

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			client: client,
			store: store,
			countryIds: ["IT"]
		)

		let successExpectation = expectation(description: "Package download was successful.")

		keyPackageDownload.startDayPackagesDownload { result in
			switch result {
			case .success:
				let allDayKeys = packagesStore.allDays(country: countryId)
				XCTAssertEqual(allDayKeys, ["2020-10-02", "2020-10-03", "2020-10-04"])
				XCTAssertEqual(packagesStore.hours(for: .formattedToday(), country: countryId).count, 0)
				successExpectation.fulfill()
			case .failure(let error):
				XCTFail("Failure callback is not expected: \(error)")
			}
		}

		waitForExpectations(timeout: 1.0)
	}

	func test_When_ExpectNewDayPackagesIsFalse_Then_NoPackageDownloadIsTriggeredAndSuccessIsCalled() throws {
		let store = MockTestStore()
		store.wasRecentDayKeyDownloadSuccessful = true

		guard let yesterdayDate = Calendar.utcCalendar.date(byAdding: .day, value: -1, to: Date()) else {
			fatalError("Could not create yesterdays date.")
		}
		let yesterdayKeyString = DateFormatter.packagesDateFormatter.string(from: yesterdayDate)
		let countryId = "IT"
		let dummyPackage = SAPDownloadedPackage(keysBin: Data(), signature: Data())

		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()
		packagesStore.open()
		try packagesStore.addFetchedDays(["2020-10-04": dummyPackage, yesterdayKeyString: dummyPackage], country: countryId, etag: nil)

		let client = ClientMock()

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			client: client,
			store: store,
			countryIds: [countryId]
		)

		let successExpectation = expectation(description: "Package download was successful.")

		keyPackageDownload.startDayPackagesDownload { result in
			switch result {
			case .success:
				successExpectation.fulfill()
			case .failure(let error):
				XCTFail("Failure callback is not expected: \(error)")
			}
		}

		waitForExpectations(timeout: 1.0)
	}

	func test_When_DayPackagesDownloadIsRunning_Then_downloadIsRunningErrorReturned() throws {
		let store = MockTestStore()

		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()
		packagesStore.open()
		let dummyPackage = SAPDownloadedPackage(keysBin: Data(), signature: Data())
		let countryId = "IT"
		try packagesStore.addFetchedDays(["2020-10-04": dummyPackage, "2020-10-01": dummyPackage], country: countryId, etag: nil)

		let client = ClientMock()
		client.availableDaysAndHours = DaysAndHours(days: ["2020-10-02", "2020-10-03", "2020-10-04"], hours: [1, 2])
		client.downloadedPackage = dummyPackage

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			client: client,
			store: store,
			countryIds: ["IT"]
		)

		let failureExpectation = expectation(description: "Package download failed.")

		keyPackageDownload.startDayPackagesDownload { _ in }
		keyPackageDownload.startDayPackagesDownload { result in
			switch result {
			case .success:
				XCTFail("Success result is not expected.")
			case .failure(let error):
				XCTAssertEqual(error, .downloadIsRunning)
				failureExpectation.fulfill()
			}
		}

		waitForExpectations(timeout: 1.0)
	}

	func test_When_DayPackagesDownloadFailes_Then_uncompletedPackagesErrorReturned() {
		let store = MockTestStore()

		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()

		let client = ClientMock()
		client.availableDaysAndHours = DaysAndHours(days: ["2020-10-02"], hours: [1])
		client.fetchPackageRequestFailure = .noResponse

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			client: client,
			store: store
		)

		let failureExpectation = expectation(description: "Package download failed.")

		keyPackageDownload.startDayPackagesDownload { result in
			switch result {
			case .success:
				XCTFail("Success result is not expected.")
			case .failure(let error):
				XCTAssertEqual(error, .uncompletedPackages)
				failureExpectation.fulfill()
			}
		}

		waitForExpectations(timeout: 1.0)
	}

	func test_When_AvailableServerDayDataFetchFailes_Then_uncompletedPackagesErrorReturned() {
		let store = MockTestStore()

		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()

		let client = ClientMock()
		client.availableDaysAndHours = DaysAndHours(days: ["2020-10-02"], hours: [1])
		client.availablePackageRequestFailure = .noResponse

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			client: client,
			store: store
		)

		let failureExpectation = expectation(description: "Package download failed.")

		keyPackageDownload.startDayPackagesDownload { result in
			switch result {
			case .success:
				XCTFail("Success result is not expected.")
			case .failure(let error):
				XCTAssertEqual(error, .uncompletedPackages)
				failureExpectation.fulfill()
			}
		}

		waitForExpectations(timeout: 1.0)
	}

	func test_When_PersistDayPackagesToDatabaseFails_Then_unableToWriteDiagnosisKeysErrorReturned() {
		let store = MockTestStore()

		let packagesStore = DownloadedPackagesStoreErrorStub(error: .unknown)

		let client = ClientMock()
		client.availableDaysAndHours = DaysAndHours(days: ["2020-10-02"], hours: [1])

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			client: client,
			store: store
		)

		let failureExpectation = expectation(description: "Package download failed.")

		keyPackageDownload.startDayPackagesDownload { result in
			switch result {
			case .success:
				XCTFail("Success result is not expected.")
			case .failure(let error):
				XCTAssertEqual(error, .unableToWriteDiagnosisKeys)
				failureExpectation.fulfill()
			}
		}

		waitForExpectations(timeout: 1.0)
	}

	func test_When_PersistDayPackagesToDatabaseFailsBecauseOfDiskSpace_Then_noDiskSpaceErrorReturned() {
		let store = MockTestStore()

		let packagesStore = DownloadedPackagesStoreErrorStub(error: .sqlite_full)

		let client = ClientMock()
		client.availableDaysAndHours = DaysAndHours(days: ["2020-10-02"], hours: [1])

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			client: client,
			store: store
		)

		let failureExpectation = expectation(description: "Package download failed.")

		keyPackageDownload.startDayPackagesDownload { result in
			switch result {
			case .success:
				XCTFail("Success result is not expected.")
			case .failure(let error):
				XCTAssertEqual(error, .noDiskSpace)
				failureExpectation.fulfill()
			}
		}

		waitForExpectations(timeout: 1.0)
	}
}
