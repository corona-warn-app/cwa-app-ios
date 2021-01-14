//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest

// swiftlint:disable:next type_body_length
class HourKeyPackagesDownloadTests: XCTestCase {

	private lazy var dummyHourResponse: [Int: PackageDownloadResponse] = {
		let dummyPackage = SAPDownloadedPackage(keysBin: Data(), signature: Data())
		let dummyResponse = PackageDownloadResponse(package: dummyPackage, etag: "\"tinfoil\"")
		return [2: dummyResponse, 3: dummyResponse]
	}()
	
	private lazy var dummyDayResponse: [String: PackageDownloadResponse] = {
		let dummyPackage = SAPDownloadedPackage(keysBin: Data(), signature: Data())
		let dummyResponse = PackageDownloadResponse(package: dummyPackage, etag: "\"tinfoil\"")
		return ["placeholderDate": dummyResponse]
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
			wifiClient: client,
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

		waitForExpectations(timeout: .medium)
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
			wifiClient: client,
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

		waitForExpectations(timeout: .medium)
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
			wifiClient: client,
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

		waitForExpectations(timeout: .medium)
	}

	func test_When_ExpectNewHourPackagesIsFalse_Then_NoPackageDownloadIsTriggeredAndSuccessIsCalled() throws {
		let store = MockTestStore()
		store.wasRecentDayKeyDownloadSuccessful = true

		guard let lastHourDate = Calendar.utcCalendar.date(byAdding: .hour, value: -1, to: Date()) else {
			XCTFail("Could not create last hour date.")
			return
		}
		guard let lastHourKey = Int(DateFormatter.packagesHourDateFormatter.string(from: lastHourDate)) else {
			XCTFail("Could not create last hour key from date.")
			return
		}
		
		let countryId = "IT"
		let dummyPackage = PackageDownloadResponse(package: SAPDownloadedPackage(keysBin: Data(), signature: Data()), etag: "\"etag\"")

		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()
		packagesStore.open()
		try packagesStore.addFetchedHours([lastHourKey: dummyPackage], day: .formattedToday(), country: countryId)

		let client = ClientMock()

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			client: client,
			wifiClient: client,
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

		waitForExpectations(timeout: .medium)
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
			wifiClient: client,
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
		
		waitForExpectations(timeout: .medium)
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
			wifiClient: client,
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

		waitForExpectations(timeout: .medium)
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
			wifiClient: client,
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

		waitForExpectations(timeout: .medium)
	}

	func test_When_PersistHourPackagesToDatabaseFails_Then_unableToWriteDiagnosisKeysErrorReturned() {
		let store = MockTestStore()

		let packagesStore = DownloadedPackagesStoreErrorStub(error: DownloadedPackagesSQLLiteStore.StoreError.sqliteError(.unknown))

		let client = ClientMock()
		client.availableDaysAndHours = DaysAndHours(days: ["2020-10-02"], hours: [1])

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			client: client,
			wifiClient: client,
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

		waitForExpectations(timeout: .medium)
	}

	func test_When_PersistHourPackagesToDatabaseFailsBecauseOfDiskSpace_Then_noDiskSpaceErrorReturned() {
		let store = MockTestStore()

		let packagesStore = DownloadedPackagesStoreErrorStub(error: DownloadedPackagesSQLLiteStore.StoreError.sqliteError(.sqlite_full))

		let client = ClientMock()
		client.availableDaysAndHours = DaysAndHours(days: ["2020-10-02"], hours: [1])

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			client: client,
			wifiClient: client,
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

		waitForExpectations(timeout: .medium)
	}

	func test_When_NoNewPackagesFoundOnServer_Then_StatusChangesFrom_Idle_To_CheckingForNewPackages_To_Idle() throws {
		let store = MockTestStore()
		store.wasRecentHourKeyDownloadSuccessful = true

		guard let lastHourDate = Calendar.utcCalendar.date(byAdding: .hour, value: -1, to: Date()) else {
			fatalError("Could not create last hour date.")
		}
		guard let lastHourKey = Int(DateFormatter.packagesHourDateFormatter.string(from: lastHourDate)) else {
			fatalError("Could not create hour key from date.")
		}

		let dummyPackage = SAPDownloadedPackage(keysBin: Data(), signature: Data())
		let dummyResponse = PackageDownloadResponse(package: dummyPackage, etag: "\"etag\"")

		let packagesStore: DownloadedPackagesSQLLiteStoreV2 = .inMemory()
		packagesStore.open()
		let countryId = "IT"
		try packagesStore.addFetchedHours([lastHourKey: dummyResponse], day: .formattedToday(), country: countryId)

		let client = ClientMock()
		client.availableDaysAndHours = DaysAndHours(days: [], hours: [lastHourKey])
		client.downloadedPackage = dummyResponse

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			client: client,
			wifiClient: client,
			store: store,
			countryIds: ["IT"]
		)

		let statusDidChangeExpectation = expectation(description: "Status statusDidChange called twice. 1. dheckingForNewPackages, 2. idle")
		statusDidChangeExpectation.expectedFulfillmentCount = 2
		var numberOfStatusChanges = 0

		keyPackageDownload.statusDidChange = { status in
			if numberOfStatusChanges == 0 {
				XCTAssertEqual(status, .checkingForNewPackages)
			} else if numberOfStatusChanges == 1 {
				XCTAssertEqual(status, .idle)
			}

			numberOfStatusChanges += 1
			statusDidChangeExpectation.fulfill()
		}

		keyPackageDownload.startHourPackagesDownload { _ in }

		waitForExpectations(timeout: .medium)
	}

	func test_When_NewPackagesFoundOnServer_Then_StatusChangesFrom_Idle_To_Downloading_To_CheckingForNewPackages_To_Idle() {
		let store = MockTestStore()

		let packagesStore: DownloadedPackagesSQLLiteStoreV2 = .inMemory()
		packagesStore.open()

		let dummyPackage = SAPDownloadedPackage(keysBin: Data(), signature: Data())
		let dummyResponse = PackageDownloadResponse(package: dummyPackage, etag: "\"etag\"")

		let client = ClientMock()
		client.availableDaysAndHours = DaysAndHours(days: ["2020-10-01", "2020-10-02", "2020-10-03"], hours: [1, 2])
		client.downloadedPackage = dummyResponse

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			client: client,
			wifiClient: client,
			store: store,
			countryIds: ["IT"]
		)
		
		let statusDidChangeExpectation = expectation(description: "Status statusDidChange called three times. 1. dheckingForNewPackages, 2. downloading, 3. idle")
		statusDidChangeExpectation.expectedFulfillmentCount = 3
		var numberOfStatusChanges = 0

		keyPackageDownload.statusDidChange = { status in
			if numberOfStatusChanges == 0 {
				XCTAssertEqual(status, .checkingForNewPackages)
			} else if numberOfStatusChanges == 1 {
				XCTAssertEqual(status, .downloading)
			} else if numberOfStatusChanges == 2 {
				XCTAssertEqual(status, .idle)
			}

			numberOfStatusChanges += 1
			statusDidChangeExpectation.fulfill()
		}

		keyPackageDownload.startHourPackagesDownload { _ in }

		waitForExpectations(timeout: .medium)
	}

	func test_When_DownloadingDayPackage_Then_CleanupHourPackages() throws {
		// Load day package for a particular day will cleanup
		// all hour packages for exactely that day

		let store = MockTestStore()

		let packagesStore: DownloadedPackagesSQLLiteStore = .inMemory()
		packagesStore.open()

		let countryId = "IT"
		// add hour packages for the day to the store
		try packagesStore.addFetchedHours(dummyHourResponse, day: "2020-10-09", country: countryId)

		let client = ClientMock()
		// prepare server response: day package for the day
		client.availableDaysAndHours = DaysAndHours(days: ["2020-10-09"], hours: [])
		client.downloadedPackage = try XCTUnwrap(dummyDayResponse.values.first)

		let keyPackageDownload = KeyPackageDownload(
			downloadedPackagesStore: packagesStore,
			client: client,
			wifiClient: client,
			store: store,
			countryIds: ["IT"]
		)

		let successExpectation = expectation(description: "Package download was successful.")

		keyPackageDownload.startDayPackagesDownload { result in
			switch result {
			case .success:
				let allHourKeys = packagesStore.hours(for: "2020-10-09", country: countryId)
				// verify: no more hour packages for the day in the store
				XCTAssertEqual(allHourKeys, [])
				// verify: day package is in the store
				XCTAssertTrue(packagesStore.allDays(country: "IT").contains("2020-10-09"))
				successExpectation.fulfill()
			case .failure(let error):
				XCTFail("Failure callback is not expected: \(error)")
			}
		}

		keyPackageDownload.startHourPackagesDownload { _ in }

		waitForExpectations(timeout: .medium)
	}
}
