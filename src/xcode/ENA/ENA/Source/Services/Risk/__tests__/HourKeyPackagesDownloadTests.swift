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

class HourKeyPackagesDownloadTests: XCTestCase {

	private lazy var dummyHourResponse: [Int: PackageDownloadResponse] = {
		let dummyPackage = SAPDownloadedPackage(keysBin: Data(), signature: Data())
		let dummyResponse = PackageDownloadResponse(package: dummyPackage, etag: "\"tinfoil\"")
		return [2: dummyResponse, 3: dummyResponse]
	}()
	
	func test_When_NoCachedHourPackages_Then_AllServerHourPackagesAreDownloaded() {
		let store = MockTestStore()
		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()
		packagesStore.open()
		let client = ClientMock()

		client.availableDaysAndHours = DaysAndHours(days: ["2020-10-01", "2020-10-02"], hours: [1, 2, 3])

		let countryId = "IT"
		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			client: client,
			store: store,
			countryIds: [countryId]
		)

		let successExpectation = expectation(description: "Package download was successful.")

		keyPackageDownload.startHourPackagesDownload { result in
			switch result {
			case .success:
				let allHourKeys = packagesStore.hours(for: .formattedToday(), country: countryId)
				XCTAssertEqual(allHourKeys, [1, 2, 3])
				XCTAssertEqual(packagesStore.allDays(country: countryId).count, 0)
				successExpectation.fulfill()
			case .failure(let error):
				XCTFail("Failure callback is not expected: \(error)")
			}
		}

		waitForExpectations(timeout: 1.0)
	}

	func test_When_CachedHourPackagesAvailable_Then_OnlyServerDeltaPackagesAreDownloaded() throws {
		let store = MockTestStore()

		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()
		packagesStore.open()

		let countryId = "IT"
		try packagesStore.addFetchedHours(dummyHourResponse, day: .formattedToday(), country: countryId)

		let client = ClientMock()
		client.availableDaysAndHours = DaysAndHours(days: ["2020-10-01", "2020-10-02"], hours: [1, 2, 3, 4])
		client.downloadedPackage = try XCTUnwrap(dummyHourResponse.values.first)

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			client: client,
			store: store,
			countryIds: ["IT"]
		)

		let successExpectation = expectation(description: "Package download was successful.")

		keyPackageDownload.startHourPackagesDownload { result in
			switch result {
			case .success:
				let allHourKeys = packagesStore.hours(for: .formattedToday(), country: countryId)
				XCTAssertEqual(allHourKeys, [1, 2, 3, 4])
				XCTAssertEqual(packagesStore.allDays(country: countryId).count, 0)
				successExpectation.fulfill()
			case .failure(let error):
				XCTFail("Failure callback is not expected: \(error)")
			}
		}

		waitForExpectations(timeout: 1.0)
	}

	func test_When_ExpiredCachedHourPackagesAvailable_Then_ExpiredPackagesAreDeleted() throws {
		let store = MockTestStore()

		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()
		packagesStore.open()

		let countryId = "IT"
		try packagesStore.addFetchedHours(dummyHourResponse, day: .formattedToday(), country: countryId)

		let client = ClientMock()
		client.availableDaysAndHours = DaysAndHours(days: ["2020-10-01", "2020-10-02"], hours: [2, 3, 4])
		client.downloadedPackage = try XCTUnwrap(dummyHourResponse.values.first)

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			client: client,
			store: store,
			countryIds: ["IT"]
		)

		let successExpectation = expectation(description: "Package download was successful.")

		keyPackageDownload.startHourPackagesDownload { result in
			switch result {
			case .success:
				let allHourKeys = packagesStore.hours(for: .formattedToday(), country: countryId)
				XCTAssertEqual(allHourKeys, [2, 3, 4])
				XCTAssertEqual(packagesStore.allDays(country: countryId).count, 0)
				successExpectation.fulfill()
			case .failure(let error):
				XCTFail("Failure callback is not expected: \(error)")
			}
		}

		waitForExpectations(timeout: 1.0)
	}

	func test_When_ExpectNewHourPackagesIsFalse_Then_NoPackageDownloadIsTriggeredAndSuccessIsCalled() throws {
		let store = MockTestStore()
		store.wasRecentDayKeyDownloadSuccessful = true

		guard let lastHourDate = Calendar.utcCalendar.date(byAdding: .hour, value: -1, to: Date()) else {
			fatalError("Could not create last hour date.")
		}
		let lastHourKey = Int(DateFormatter.packagesDateFormatter.string(from: lastHourDate)) ?? -1
		let countryId = "IT"
		let dummyPackage = PackageDownloadResponse(package: SAPDownloadedPackage(keysBin: Data(), signature: Data()), etag: "\"etag\"")

		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()
		packagesStore.open()
		try packagesStore.addFetchedHours([lastHourKey: dummyPackage], day: .formattedToday(), country: countryId)

		let client = ClientMock()

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			client: client,
			store: store,
			countryIds: [countryId]
		)

		let successExpectation = expectation(description: "Package download was successful.")

		keyPackageDownload.startHourPackagesDownload { result in
			switch result {
			case .success:
				successExpectation.fulfill()
			case .failure(let error):
				XCTFail("Failure callback is not expected: \(error)")
			}
		}

		waitForExpectations(timeout: 1.0)
	}

	func test_When_HourPackagesDownloadIsRunning_Then_downloadIsRunningErrorReturned() throws {
		let store = MockTestStore()

		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()
		packagesStore.open()
		let dummyPackage = PackageDownloadResponse(package: SAPDownloadedPackage(keysBin: Data(), signature: Data()), etag: "\"etag\"")
		let countryId = "IT"
		try packagesStore.addFetchedDays(["2020-10-04": dummyPackage, "2020-10-01": dummyPackage], country: countryId)

		let client = ClientMock()
		client.availableDaysAndHours = DaysAndHours(days: ["2020-10-02", "2020-10-03", "2020-10-04"], hours: [1, 2])
		client.downloadedPackage = try XCTUnwrap(dummyHourResponse.values.first)

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			client: client,
			store: store,
			countryIds: ["IT"]
		)

		let failureExpectation = expectation(description: "Package download failed.")

		keyPackageDownload.startHourPackagesDownload { _ in }
		keyPackageDownload.startHourPackagesDownload { result in
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

	func test_When_HourPackagesDownloadFailes_Then_uncompletedPackagesErrorReturned() {
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

		keyPackageDownload.startHourPackagesDownload { result in
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

	func test_When_AvailableServerHourDataFetchFailes_Then_uncompletedPackagesErrorReturned() {
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

		keyPackageDownload.startHourPackagesDownload { result in
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

	func test_When_PersistHourPackagesToDatabaseFails_Then_unableToWriteDiagnosisKeysErrorReturned() {
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

		keyPackageDownload.startHourPackagesDownload { result in
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

	func test_When_PersistHourPackagesToDatabaseFailsBecauseOfDiskSpace_Then_noDiskSpaceErrorReturned() {
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

		keyPackageDownload.startHourPackagesDownload { result in
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
